"""RKC / MKC locking of a gate-level netlist, plus an RLL (XOR) baseline.

Three views of the same locked design are produced:

``static``   The key-controlled circuits only; K1/K2 of every site are exposed
             as free key inputs ``keyinput<2i>`` / ``keyinput<2i+1>``. This is the
             model the paper's SAT / AppSAT experiments attack (one static key).
``full``     Key-controlled circuits + the LUT-based tamper-proof memory
             (one 2:1 MUX per key line, select = circuit input). The memory
             *cells* are the key inputs. ``storage="2x"`` uses two cells per
             key line (correct contents 0,1); ``storage="1x"`` uses one cell
             and an inverter (correct content 0), as described in Sec. 4.1.
``activated`` ``full`` with the correct cell contents tied in. Must be
             equivalent to the original circuit.
"""
from __future__ import annotations

import random
from dataclasses import dataclass, field

from .kcc import GATES, key_select, sop
from .netlist import Netlist


@dataclass
class Site:
    x: str                    # gate being replaced (its output net keeps the name)
    gate: str                 # type of x
    w: str | None             # AND gate feeding x (MKC topology)
    a: str                    # circuit inputs
    b: str
    c: str | None
    w_independent: bool = False


@dataclass
class Locked:
    netlist: Netlist
    correct_key: dict[str, int] = field(default_factory=dict)
    sites: list[Site] = field(default_factory=list)
    removed_w: int = 0


def find_sites(nl: Netlist):
    """All AND-X topologies: X is a 2-input gate of the six supported types with
    one fanin driven by a 2-input AND gate W. (RKC locks X; MKC locks W+X.)"""
    fo = nl.fanout_count()
    sites = []
    for x in nl.topo():
        t, ins = nl.gates[x]
        if t not in GATES or len(ins) != 2 or ins[0] == ins[1]:
            continue
        for pos in (0, 1):
            w = ins[pos]
            if w in nl.gates and nl.gates[w][0] == "AND" and len(nl.gates[w][1]) == 2:
                a, b = nl.gates[w][1]
                c = ins[1 - pos]
                if len({a, b, c}) == 3:
                    sites.append(Site(x, t, w, a, b, c, fo[w] == 1 and w not in nl.outputs))
                    break
    return sites


def choose_sites(nl: Netlist, n_sites: int, seed: int):
    """Random, non-overlapping selection (no chosen X is the W of another site)."""
    rng = random.Random(seed)
    cand = find_sites(nl)
    rng.shuffle(cand)
    chosen, xs, ws = [], set(), set()
    for s in cand:
        if s.x in ws or s.w in xs or s.w in ws:
            continue
        chosen.append(s)
        xs.add(s.x)
        ws.add(s.w)
        if len(chosen) == n_sites:
            return chosen
    raise ValueError(f"{nl.name}: only {len(chosen)} usable AND-X sites, need {n_sites}")


def _emit_sop(nl: Netlist, out, terms, binding, tag):
    """Instantiate a sum-of-products with AND/OR/NOT gates driving net ``out``."""
    inv = {}

    def lit(v, pos):
        n = binding[v]
        if pos:
            return n
        if v not in inv:
            inv[v] = f"{tag}_n{v}"
            nl.add_gate(inv[v], "NOT", [n])
        return inv[v]

    prods = []
    for i, t in enumerate(terms):
        ls = [lit(v, p) for v, p in t]
        if len(ls) == 1:
            prods.append(ls[0])
        else:
            nl.add_gate(f"{tag}_p{i}", "AND", ls)
            prods.append(f"{tag}_p{i}")
    nl.add_gate(out, "OR" if len(prods) > 1 else "BUF", prods)


def lock(orig: Netlist, scheme, sites, view="static", storage="2x") -> Locked:
    """Apply ``scheme`` = ("RKC"|"MKC", 2|4) at the given sites."""
    kind, _m = scheme
    nl = orig.copy(f"{orig.name}_{kind}m{_m}_{view}")
    res = Locked(nl, sites=list(sites))
    fo = orig.fanout_count()
    for i, s in enumerate(sites):
        tag = f"kcc{i}"
        if kind == "RKC":
            # replace X(in0, in1); A/B follow the netlist fanin order of X
            a, b = orig.gates[s.x][1]
            binding = {"A": a, "B": b}
        else:
            binding = {"A": s.a, "B": s.b, "C": s.c}
        nl.remove_gate(s.x)
        # key lines
        klines = []
        for j, sel in enumerate(key_select(scheme)):
            kname = f"keyinput{2 * i + j}"
            if view == "static":
                nl.add_input(kname)
                res.correct_key[kname] = None       # no static correct value exists
                klines.append(kname)
                continue
            line = f"{tag}_K{j + 1}"
            if storage == "2x":
                c0, c1 = f"keyinput{4 * i + 2 * j}", f"keyinput{4 * i + 2 * j + 1}"
                nl.add_input(c0), nl.add_input(c1)
                res.correct_key[c0], res.correct_key[c1] = 0, 1
                nl.add_gate(line, "MUX", [binding[sel], c0, c1])
            else:
                c0 = kname
                nl.add_input(c0)
                res.correct_key[c0] = 0
                nl.add_gate(f"{line}_inv", "NOT", [c0])
                nl.add_gate(line, "MUX", [binding[sel], c0, f"{line}_inv"])
            klines.append(line)
        binding["K1"], binding["K2"] = klines
        _emit_sop(nl, s.x, sop(scheme, s.gate), binding, tag)
        # MKC absorbs W when it is independent (Sec. 4.2, Fig. 12)
        if kind == "MKC" and fo[s.w] == 1 and s.w not in orig.outputs and s.w in nl.gates:
            nl.remove_gate(s.w)
            res.removed_w += 1
    nl.topo()
    return res


def tie_key(locked: Netlist, key: dict[str, int], name=None) -> Netlist:
    """Hard-wire key inputs to constants (returns a key-free netlist)."""
    nl = locked.copy(name or locked.name + "_tied")
    nl.keys = []
    src = nl.inputs[0]
    nl.add_gate("__n_src", "NOT", [src])
    nl.add_gate("__const0", "AND", [src, "__n_src"])
    nl.add_gate("__const1", "NOT", ["__const0"])
    for k in locked.keys:
        nl.add_gate(k, "BUF", ["__const1" if key[k] else "__const0"])
    nl.topo()
    return nl


def lock_rll(orig: Netlist, n_bits: int, seed: int) -> Locked:
    """Random XOR/XNOR key-gate insertion (EPIC-style). Used only to sanity-check
    the attack implementations on a scheme they are known to break."""
    rng = random.Random(seed)
    nl = orig.copy(f"{orig.name}_rll")
    res = Locked(nl)
    targets = rng.sample([g for g in orig.topo() if g not in orig.outputs], n_bits)
    for i, g in enumerate(targets):
        k, bit = f"keyinput{i}", rng.randint(0, 1)
        t, ins = nl.gates[g]
        nl.remove_gate(g)
        nl.add_gate(f"{g}__pre", t, ins)
        nl.add_input(k)
        nl.add_gate(g, "XNOR" if bit else "XOR", [f"{g}__pre", k])
        res.correct_key[k] = bit
    nl.topo()
    return res
