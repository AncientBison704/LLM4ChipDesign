"""Gate-level netlist: ISCAS .bench I/O, bit-parallel simulation, Verilog export.

A netlist is a set of primary inputs, key inputs (any input whose name starts
with ``keyinput``), outputs, and gates ``name -> (type, [fanin names])``.
Supported gate types: AND NAND OR NOR XOR XNOR NOT BUF MUX.
MUX fanins are ordered ``(sel, d0, d1)`` and compute ``d1 if sel else d0``.
"""
from __future__ import annotations

import re
from collections import Counter

GATE_TYPES = {"AND", "NAND", "OR", "NOR", "XOR", "XNOR", "NOT", "BUF", "MUX"}
_ALIASES = {"BUFF": "BUF", "INV": "NOT"}
KEY_PREFIX = "keyinput"


class Netlist:
    def __init__(self, name="top"):
        self.name = name
        self.inputs: list[str] = []   # primary inputs (no keys)
        self.keys: list[str] = []     # key inputs
        self.outputs: list[str] = []
        self.gates: dict[str, tuple[str, list[str]]] = {}
        self._topo = None

    # ---------------------------------------------------------------- build
    def add_input(self, n):
        (self.keys if n.startswith(KEY_PREFIX) else self.inputs).append(n)
        self._topo = None

    def add_gate(self, out, typ, ins):
        typ = _ALIASES.get(typ.upper(), typ.upper())
        if typ not in GATE_TYPES:
            raise ValueError(f"unsupported gate type {typ}")
        if out in self.gates:
            raise ValueError(f"net {out} driven twice")
        self.gates[out] = (typ, list(ins))
        self._topo = None

    def remove_gate(self, out):
        del self.gates[out]
        self._topo = None

    def copy(self, name=None):
        c = Netlist(name or self.name)
        c.inputs, c.keys, c.outputs = list(self.inputs), list(self.keys), list(self.outputs)
        c.gates = {k: (t, list(i)) for k, (t, i) in self.gates.items()}
        return c

    # ------------------------------------------------------------- analysis
    def topo(self):
        """Gate names in topological order (raises on combinational loops)."""
        if self._topo is not None:
            return self._topo
        order, state = [], {}
        for root in self.gates:
            if root in state:
                continue
            stack = [(root, iter(self.gates[root][1]))]
            state[root] = 1
            while stack:
                node, it = stack[-1]
                for f in it:
                    if f in self.gates:
                        s = state.get(f)
                        if s == 1:
                            raise ValueError(f"combinational loop through {f}")
                        if s is None:
                            state[f] = 1
                            stack.append((f, iter(self.gates[f][1])))
                            break
                    elif f not in self._srcs():
                        raise ValueError(f"undriven net {f}")
                else:
                    state[node] = 2
                    order.append(node)
                    stack.pop()
        self._topo = order
        return order

    def _srcs(self):
        return set(self.inputs) | set(self.keys)

    def fanout_count(self):
        fo = Counter(f for _, ins in self.gates.values() for f in ins)
        for o in self.outputs:
            fo[o] += 1
        return fo

    def stats(self):
        return {"PI": len(self.inputs), "KEY": len(self.keys), "PO": len(self.outputs),
                "gates": len(self.gates)}

    # ----------------------------------------------------------- simulation
    def simulate(self, values: dict[str, int], width: int = 1) -> dict[str, int]:
        """Bit-parallel simulation. ``values`` maps every input/key to an int
        carrying ``width`` patterns (bit i = pattern i). Returns all net values."""
        mask = (1 << width) - 1
        v = dict(values)
        for g in self.topo():
            typ, ins = self.gates[g]
            x = [v[i] for i in ins]
            v[g] = eval_gate(typ, x, mask)
        return v

    def eval_outputs(self, values, width=1):
        v = self.simulate(values, width)
        return [v[o] for o in self.outputs]


def eval_gate(typ, x, mask):
    if typ in ("AND", "NAND"):
        r = mask
        for a in x:
            r &= a
        return r if typ == "AND" else r ^ mask
    if typ in ("OR", "NOR"):
        r = 0
        for a in x:
            r |= a
        return r if typ == "OR" else r ^ mask
    if typ in ("XOR", "XNOR"):
        r = 0
        for a in x:
            r ^= a
        return r if typ == "XOR" else r ^ mask
    if typ == "NOT":
        return x[0] ^ mask
    if typ == "BUF":
        return x[0]
    if typ == "MUX":
        s, d0, d1 = x
        return (d1 & s) | (d0 & (s ^ mask))
    raise ValueError(typ)


# -------------------------------------------------------------------- I/O
_RE_IO = re.compile(r"^\s*(INPUT|OUTPUT)\s*\(\s*([^)\s]+)\s*\)", re.I)
_RE_GATE = re.compile(r"^\s*([^\s=]+)\s*=\s*(\w+)\s*\(([^)]*)\)")


def read_bench(path, name=None) -> Netlist:
    nl = Netlist(name or path.split("/")[-1].rsplit(".", 1)[0])
    with open(path) as f:
        for line in f:
            line = line.split("#", 1)[0]
            m = _RE_IO.match(line)
            if m:
                if m[1].upper() == "INPUT":
                    nl.add_input(m[2])
                else:
                    nl.outputs.append(m[2])
                continue
            m = _RE_GATE.match(line)
            if m:
                nl.add_gate(m[1], m[2], [s.strip() for s in m[3].split(",") if s.strip()])
    nl.topo()
    return nl


def write_bench(nl: Netlist, path):
    with open(path, "w") as f:
        f.write(f"# {nl.name}\n")
        for i in nl.inputs + nl.keys:
            f.write(f"INPUT({i})\n")
        for o in nl.outputs:
            f.write(f"OUTPUT({o})\n")
        for g in nl.topo():
            t, ins = nl.gates[g]
            f.write(f"{g} = {t}({', '.join(ins)})\n")


def _v(n):
    """Escape a net name for Verilog."""
    return n if re.fullmatch(r"[A-Za-z_]\w*", n) else "\\" + n + " "


def write_verilog(nl: Netlist, path, module=None):
    ops = {"AND": "&", "NAND": "&", "OR": "|", "NOR": "|", "XOR": "^", "XNOR": "^"}
    ports = nl.inputs + nl.keys + [o + "__po" for o in nl.outputs]
    with open(path, "w") as f:
        f.write(f"module {module or nl.name}({', '.join(_v(p) for p in ports)});\n")
        for i in nl.inputs + nl.keys:
            f.write(f"  input {_v(i)};\n")
        for o in nl.outputs:
            f.write(f"  output {_v(o + '__po')};\n")
        for g in nl.gates:
            f.write(f"  wire {_v(g)};\n")
        for g in nl.topo():
            t, ins = nl.gates[g]
            a = [_v(i) for i in ins]
            if t in ops:
                e = f" {ops[t]} ".join(a)
                if t in ("NAND", "NOR", "XNOR"):
                    e = f"~({e})"
            elif t == "NOT":
                e = f"~{a[0]}"
            elif t == "BUF":
                e = a[0]
            else:  # MUX
                e = f"{a[0]} ? {a[2]} : {a[1]}"
            f.write(f"  assign {_v(g)} = {e};\n")
        for o in nl.outputs:
            f.write(f"  assign {_v(o + '__po')} = {_v(o)};\n")
        f.write("endmodule\n")
