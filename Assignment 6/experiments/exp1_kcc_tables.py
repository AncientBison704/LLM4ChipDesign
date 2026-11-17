"""Exp 1 - Tables 1-4 / Figs 4, 6, 9, 11: exhaustive check of all 24
key-controlled circuits against the properties the paper claims.

For every circuit:
  dyn_ok        correct for ALL circuit inputs when the LUT memory drives K1,K2
  min_wrong     min over the 4 static keys of #wrong input patterns (paper: >= 1)
  integrity     output depends on every one of K1, K2, A, B(, C)
  irrelevant    static keys under which the output is constant 0
                ("completely irrelevant minterms", gray cells in the figures)
"""
import itertools

from common import RESULTS, write_csv
from rkc.kcc import (GATES, SCHEMES, TABLES, circuit_inputs, dynamic_key,
                     eval_sop, scheme_name, sop, truth_table)
import os


def depends_on_all(scheme, gate):
    terms, xs = sop(scheme, gate), ["K1", "K2"] + circuit_inputs(scheme)
    dep = set()
    for vals in itertools.product((0, 1), repeat=len(xs)):
        env = dict(zip(xs, vals))
        for v in xs:
            if eval_sop(terms, env) != eval_sop(terms, {**env, v: 1 - env[v]}):
                dep.add(v)
    return dep == set(xs)


rows, md = [], ["# Truth tables of the 24 key-controlled circuits\n",
                "Cell = locked output. `*` marks an output that differs from the original "
                "gate/topology. The column used by the LUT memory for each input pattern is "
                "listed in the last row-group (`dyn`).\n"]
for s in SCHEMES:
    for g in GATES:
        tt, xs = truth_table(s, g), circuit_inputs(s)
        pats = list(tt[(0, 0)])
        dyn_ok = all(tt[dynamic_key(s, dict(zip(xs, v)))][v][0] == tt[(0, 0)][v][1] for v in pats)
        wrong = {k: sum(a != b for a, b in r.values()) for k, r in tt.items()}
        irrelevant = [f"{k[0]}{k[1]}" for k, r in tt.items() if all(a == 0 for a, _ in r.values())]
        terms = sop(s, g)
        rows.append({
            "scheme": scheme_name(s), "gate": g if s[0] == "RKC" else "AND-" + g,
            "expression": TABLES[s][g],
            "dyn_ok": dyn_ok,
            "wrong_K00": wrong[(0, 0)], "wrong_K01": wrong[(0, 1)],
            "wrong_K10": wrong[(1, 0)], "wrong_K11": wrong[(1, 1)],
            "min_wrong": min(wrong.values()), "n_patterns": len(pats),
            "integrity": depends_on_all(s, g),
            "irrelevant_keys": " ".join(irrelevant) or "-",
            "terms": len(terms), "literals": sum(len(t) for t in terms),
        })
        md.append(f"\n## {scheme_name(s)} / {rows[-1]['gate']}:  `Y = {TABLES[s][g]}`\n")
        md.append("| " + "".join(xs) + " | orig | K=00 | K=01 | K=10 | K=11 | dyn key |")
        md.append("|---|---|---|---|---|---|---|")
        for v in pats:
            o = tt[(0, 0)][v][1]
            cells = [f"{tt[k][v][0]}{'*' if tt[k][v][0] != o else ''}"
                     for k in [(0, 0), (0, 1), (1, 0), (1, 1)]]
            dk = dynamic_key(s, dict(zip(xs, v)))
            md.append(f"| {''.join(map(str, v))} | {o} | " + " | ".join(cells) + f" | {dk[0]}{dk[1]} |")

write_csv("exp1_kcc_properties.csv", rows)
with open(os.path.join(RESULTS, "exp1_truth_tables.md"), "w") as f:
    f.write("\n".join(md) + "\n")

print(f"\n{'scheme':8} {'gate':9} dyn  minwrong integ irrelevant  expr")
for r in rows:
    print(f"{r['scheme']:8} {r['gate']:9} {str(r['dyn_ok']):5} {r['min_wrong']}/{r['n_patterns']}"
          f"      {str(r['integrity']):5} {r['irrelevant_keys']:10} {r['expression']}")
assert all(r["dyn_ok"] for r in rows), "a KCC is wrong under the dynamic key"
assert all(r["min_wrong"] >= 1 for r in rows), "a static key unlocks a KCC"
print("\nAll 24 circuits: correct under the LUT-driven key, and no static key is correct.")
print("Circuits lacking input integrity:", [(r["scheme"], r["gate"]) for r in rows if not r["integrity"]] or "none")
