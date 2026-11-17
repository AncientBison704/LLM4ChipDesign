"""Key-controlled circuit (KCC) library: Tables 1-4 of the paper, verbatim.

Each entry is the sum-of-products expression printed in the paper for the
circuit that replaces a gate (RKC) or an AND-X two-gate topology (MKC).
Variables: K1, K2 are the two key lines; A, B (and C for MKC) are the
"circuit inputs". A trailing apostrophe means complement.

RKC replaces   Y = X(A, B)
MKC replaces   W = AND(A, B);  Y = X(W, C)

The key lines are NOT static. They are driven by the LUT-based tamper-proof
memory, a 2:1 MUX per key line whose select is a circuit input (Fig. 2b/2c):

    m = 2 : K1 = MUX(A; 0, 1)   K2 = MUX(A; 0, 1)     (KC1=00 for A=0, KC2=11 for A=1)
    m = 4 : K1 = MUX(A; 0, 1)   K2 = MUX(B; 0, 1)     (KC = AB)
"""
from __future__ import annotations

import itertools
import re

GATES = ["AND", "NAND", "OR", "NOR", "XOR", "XNOR"]

TABLES = {
    ("RKC", 2): {  # Table 1
        "AND":  "K1'A + K2B",
        "NAND": "K1'A' + K1K2B'",
        "OR":   "K2A + K1'K2'B",
        "NOR":  "K1'B' + K2A'",
        "XOR":  "K1'B + K2AB'",
        "XNOR": "K1'B' + K2AB",
    },
    ("RKC", 4): {  # Table 2
        "AND":  "K1B + K2A",
        "NAND": "K1'A' + K1K2'B'",
        "OR":   "K2B + K1K2'A",
        "NOR":  "K1'B' + K2'A'",
        "XOR":  "K1'B + K2'A",
        "XNOR": "K1'B' + K2A",
    },
    ("MKC", 2): {  # Table 3 (AND-X topologies)
        "AND":  "K1'A + K2BC",
        "NAND": "K1'A' + K1C' + K2B'",
        "OR":   "K1'C + K2B + AC",
        "NOR":  "K1'C' + K2AB'C'",
        "XOR":  "K1'C + K2BC' + AB'C",
        "XNOR": "K1'C' + K2B'C' + ABC",
    },
    ("MKC", 4): {  # Table 4 (AND-X topologies)
        "AND":  "K1'AB + K2AC",
        "NAND": "K1'A' + K1B' + K2C'",
        "OR":   "K1'C + K2A + B'C",
        "NOR":  "K1'C' + K2A'B' + B'C'",
        "XOR":  "K1'C + K2AC' + B'C",
        "XNOR": "K1'C' + K2AC + B'C'",
    },
}

SCHEMES = [("RKC", 2), ("RKC", 4), ("MKC", 2), ("MKC", 4)]


def scheme_name(s):
    return f"{s[0]}-m{s[1]}"


_LIT = re.compile(r"(K1|K2|A|B|C)('?)")


def parse_sop(expr: str):
    """'K1\\'A + K2B' -> [[('K1', False), ('A', True)], [('K2', True), ('B', True)]]
    Each literal is (variable, polarity) with polarity True = uncomplemented."""
    terms = []
    for t in expr.split("+"):
        t = t.strip().replace(" ", "")
        lits = [(m[1], m[2] == "") for m in _LIT.finditer(t)]
        if "".join(v + ("" if p else "'") for v, p in lits) != t:
            raise ValueError(f"cannot parse term {t!r}")
        terms.append(lits)
    return terms


def sop(scheme, gate):
    return parse_sop(TABLES[scheme][gate])


def eval_sop(terms, env: dict) -> int:
    return int(any(all(env[v] == int(p) for v, p in t) for t in terms))


def gate_fn(gate, a, b):
    r = {"AND": a & b, "NAND": a & b, "OR": a | b, "NOR": a | b, "XOR": a ^ b, "XNOR": a ^ b}[gate]
    return r ^ 1 if gate in ("NAND", "NOR", "XNOR") else r


def original_fn(scheme, gate, env):
    """Function of the replaced gate / topology."""
    if scheme[0] == "RKC":
        return gate_fn(gate, env["A"], env["B"])
    return gate_fn(gate, env["A"] & env["B"], env["C"])


def circuit_inputs(scheme):
    return ["A", "B"] if scheme[0] == "RKC" else ["A", "B", "C"]


def key_select(scheme):
    """Which circuit input selects each key-line MUX: (sel for K1, sel for K2)."""
    return ("A", "A") if scheme[1] == 2 else ("A", "B")


def dynamic_key(scheme, env):
    """Key combination delivered by the LUT memory for this circuit-input pattern."""
    s1, s2 = key_select(scheme)
    return env[s1], env[s2]


def truth_table(scheme, gate):
    """rows[(k1,k2)][inputs tuple] = (locked output, original output)."""
    terms, xs = sop(scheme, gate), circuit_inputs(scheme)
    rows = {}
    for k1, k2 in itertools.product((0, 1), repeat=2):
        rows[(k1, k2)] = {}
        for vals in itertools.product((0, 1), repeat=len(xs)):
            env = dict(zip(xs, vals), K1=k1, K2=k2)
            rows[(k1, k2)][vals] = (eval_sop(terms, env), original_fn(scheme, gate, env))
    return rows
