"""Oracle-guided attacks written from scratch on top of PySAT:

* ``sat_attack``  - Subramanyan et al., HOST 2015 (DIP loop).
* ``appsat``      - Shamsi et al., HOST 2017 (DIP loop + periodic random-query
                    error estimation, reinforcement and early settlement).
* ``equivalent``  - SAT-based combinational equivalence check.

The oracle is any key-free netlist (the activated chip).
"""
from __future__ import annotations

import random
import time
from dataclasses import dataclass, field

from pysat.solvers import Solver

from .netlist import Netlist


class Cnf:
    """Tseitin encoder with constant folding. Literal ``T`` is the constant 1."""

    def __init__(self, solver_name="g4"):
        self.s = Solver(name=solver_name)
        self.n = 1
        self.T = 1
        self.s.add_clause([1])

    def new(self):
        self.n += 1
        return self.n

    def add(self, cl):
        self.s.add_clause(cl)

    def const(self, b):
        return self.T if b else -self.T

    def is_const(self, lit):
        return abs(lit) == self.T

    # gate primitives -------------------------------------------------------
    def AND(self, lits):
        T, out = self.T, []
        for l in lits:
            if l == -T:
                return -T
            if l != T:
                out.append(l)
        out = list(dict.fromkeys(out))
        if any(-l in out for l in out):
            return -T
        if not out:
            return T
        if len(out) == 1:
            return out[0]
        z = self.new()
        for l in out:
            self.add([-z, l])
        self.add([z] + [-l for l in out])
        return z

    def OR(self, lits):
        return -self.AND([-l for l in lits])

    def XOR(self, a, b):
        T = self.T
        if abs(a) == T:
            return b if a == -T else -b
        if abs(b) == T:
            return a if b == -T else -a
        if a == b:
            return -T
        if a == -b:
            return T
        z = self.new()
        self.add([-z, a, b]); self.add([-z, -a, -b]); self.add([z, -a, b]); self.add([z, a, -b])
        return z

    def MUX(self, s, d0, d1):
        T = self.T
        if s == T:
            return d1
        if s == -T:
            return d0
        if d0 == d1:
            return d0
        return self.OR([self.AND([s, d1]), self.AND([-s, d0])])

    def gate(self, typ, x):
        if typ == "AND":
            return self.AND(x)
        if typ == "NAND":
            return -self.AND(x)
        if typ == "OR":
            return self.OR(x)
        if typ == "NOR":
            return -self.OR(x)
        if typ in ("XOR", "XNOR"):
            r = x[0]
            for l in x[1:]:
                r = self.XOR(r, l)
            return r if typ == "XOR" else -r
        if typ == "NOT":
            return -x[0]
        if typ == "BUF":
            return x[0]
        if typ == "MUX":
            return self.MUX(*x)
        raise ValueError(typ)

    def circuit(self, nl: Netlist, binding: dict[str, int]) -> list[int]:
        """Encode ``nl`` with inputs/keys bound to literals; return output literals."""
        v = dict(binding)
        for g in nl.topo():
            t, ins = nl.gates[g]
            v[g] = self.gate(t, [v[i] for i in ins])
        return [v[o] for o in nl.outputs]

    def differ(self, ya, yb):
        return self.OR([self.XOR(a, b) for a, b in zip(ya, yb)])


def query(oracle: Netlist, x: dict[str, int]) -> list[int]:
    return oracle.eval_outputs(x, 1)


def equivalent(a: Netlist, b: Netlist):
    """CEC of two key-free netlists with identical PI/PO lists.
    Returns (True, None) or (False, counterexample input dict)."""
    assert a.inputs == b.inputs and len(a.outputs) == len(b.outputs)
    c = Cnf()
    xs = {i: c.new() for i in a.inputs}
    d = c.differ(c.circuit(a, xs), c.circuit(b, xs))
    if c.is_const(d):
        ok = d == -c.T
        c.s.delete()
        return (ok, None if ok else {i: 0 for i in a.inputs})
    if c.s.solve(assumptions=[d]):
        m = set(c.s.get_model())
        cex = {i: int(v in m) for i, v in xs.items()}
        c.s.delete()
        return False, cex
    c.s.delete()
    return True, None


def error_rate(locked: Netlist, key: dict[str, int], oracle: Netlist, n=4096, seed=0):
    """Random-simulation estimate: (fraction of patterns with any wrong output,
    mean output Hamming distance in %)."""
    rng = random.Random(seed)
    mask = (1 << n) - 1
    x = {i: rng.getrandbits(n) for i in oracle.inputs}
    yo = oracle.eval_outputs(x, n)
    yl = locked.eval_outputs({**x, **{k: (mask if key[k] else 0) for k in locked.keys}}, n)
    anyd, hd = 0, 0
    for p, q in zip(yo, yl):
        d = p ^ q
        anyd |= d
        hd += bin(d).count("1")
    return bin(anyd).count("1") / n, 100.0 * hd / (n * len(yo))


@dataclass
class AttackResult:
    outcome: str = ""              # "unsat" | "key"
    key: dict | None = None
    iterations: int = 0            # number of DIPs
    time: float = 0.0
    random_queries: int = 0
    notes: list = field(default_factory=list)


class _Engine:
    """Shared machinery: miter over two key copies + accumulated I/O constraints."""

    def __init__(self, locked: Netlist, oracle: Netlist):
        self.locked, self.oracle = locked, oracle
        c = self.c = Cnf()
        self.x = {i: c.new() for i in locked.inputs}
        self.ka = {k: c.new() for k in locked.keys}
        self.kb = {k: c.new() for k in locked.keys}
        ya = c.circuit(locked, {**self.x, **self.ka})
        yb = c.circuit(locked, {**self.x, **self.kb})
        self.diff = c.differ(ya, yb)

    def find_dip(self):
        c = self.c
        if c.is_const(self.diff) and self.diff == -c.T:
            return None
        if not c.s.solve(assumptions=[self.diff]):
            return None
        m = set(c.s.get_model())
        return {i: int(v in m) for i, v in self.x.items()}

    def add_io(self, x, y):
        """Constrain both key copies to reproduce oracle output y on input x."""
        c = self.c
        xb = {i: c.const(b) for i, b in x.items()}
        for kv in (self.ka, self.kb):
            for lit, bit in zip(c.circuit(self.locked, {**xb, **kv}), y):
                c.add([lit if bit else -lit])

    def extract_key(self):
        """A key consistent with every recorded I/O pair, or None if none exists."""
        if not self.c.s.solve():
            return None
        m = set(self.c.s.get_model())
        return {k: int(v in m) for k, v in self.ka.items()}

    def close(self):
        self.c.s.delete()


def sat_attack(locked: Netlist, oracle: Netlist, max_iter=10_000) -> AttackResult:
    t0 = time.perf_counter()
    e, r = _Engine(locked, oracle), AttackResult()
    while r.iterations < max_iter:
        dip = e.find_dip()
        if dip is None:
            break
        r.iterations += 1
        e.add_io(dip, query(oracle, dip))
    r.key = e.extract_key()
    r.outcome = "key" if r.key is not None else "unsat"
    e.close()
    r.time = time.perf_counter() - t0
    return r


def appsat(locked: Netlist, oracle: Netlist, d=12, n_random=50, settle=5,
           seed=0, max_iter=10_000) -> AttackResult:
    """AppSAT. Every ``d`` DIPs: take a key consistent with the constraints so
    far, test it on ``n_random`` random oracle queries, add the failing queries
    as constraints, and stop once ``settle`` consecutive rounds show no error."""
    t0 = time.perf_counter()
    rng = random.Random(seed)
    e, r, settled = _Engine(locked, oracle), AttackResult(), 0
    while r.iterations < max_iter:
        dip = e.find_dip()
        if dip is None:
            r.notes.append("exact termination (no DIP left)")
            break
        r.iterations += 1
        e.add_io(dip, query(oracle, dip))
        if r.iterations % d:
            continue
        cand = e.extract_key()
        if cand is None:
            r.notes.append("constraints unsatisfiable at error-estimation round")
            break
        mask = (1 << n_random) - 1
        x = {i: rng.getrandbits(n_random) for i in oracle.inputs}
        yo = oracle.eval_outputs(x, n_random)
        yl = locked.eval_outputs({**x, **{k: (mask if cand[k] else 0) for k in locked.keys}}, n_random)
        bad = 0
        for p, q in zip(yo, yl):
            bad |= p ^ q
        r.random_queries += n_random
        fails = [j for j in range(n_random) if bad >> j & 1]
        r.notes.append(f"round@{r.iterations}: error {len(fails)}/{n_random}")
        if not fails:
            settled += 1
            if settled >= settle:
                r.notes.append("settled")
                break
        else:
            settled = 0
            for j in fails:
                xj = {i: x[i] >> j & 1 for i in x}
                e.add_io(xj, [y >> j & 1 for y in yo])
    r.key = e.extract_key()
    r.outcome = "key" if r.key is not None else "unsat"
    e.close()
    r.time = time.perf_counter() - t0
    return r
