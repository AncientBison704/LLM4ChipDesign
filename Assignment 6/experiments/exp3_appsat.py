"""Exp 3 - Table 6: AppSAT on c1355 locked with 16 bits.

Paper configuration: 50 random queries after every 12 DIP iterations,
settlement threshold 5. Same static-key threat model as Exp 2.
Also reported: the same run with error estimation every 2 DIPs (d=2), because
with d=12 the DIP loop usually ends before the first estimation round.
"""
from collections import defaultdict

from common import SEEDS, bench, mean, pmap, write_csv
from rkc.attacks import appsat, equivalent, error_rate
from rkc.kcc import SCHEMES, scheme_name
from rkc.lock import choose_sites, lock, tie_key


def run(job):
    seed, d = job
    o = bench("c1355")
    sites = choose_sites(o, 8, seed)
    out = []
    for s in SCHEMES:
        L = lock(o, s, sites, "static")
        a = appsat(L.netlist, o, d=d, n_random=50, settle=5, seed=seed)
        row = {"scheme": scheme_name(s), "d": d, "seed": seed, "iterations": a.iterations,
               "random_queries": a.random_queries, "time_s": round(a.time, 4),
               "note": "No key (all eliminated)", "err_patterns": "", "trace": "; ".join(a.notes)}
        if a.key is not None:
            eq, _ = equivalent(tie_key(L.netlist, a.key), o)
            row.update(note="Equivalent key" if eq else "Wrong Key",
                       err_patterns=round(error_rate(L.netlist, a.key, o)[0], 4))
        out.append(row)
    return out


if __name__ == "__main__":
    rows = [r for rs in pmap(run, [(s, d) for d in (12, 2) for s in SEEDS]) for r in rs]
    write_csv("exp3_appsat.csv", rows)
    agg = defaultdict(list)
    for r in rows:
        agg[(r["d"], r["scheme"])].append(r)
    summ = []
    for (d, sch), rs in agg.items():
        wk = [r for r in rs if r["note"] == "Wrong Key"]
        summ.append({"d": d, "scheme": sch,
                     "avg_runtime_s": round(mean(r["time_s"] for r in rs), 3),
                     "avg_iterations": round(mean(r["iterations"] for r in rs), 1),
                     "wrong_key": len(wk),
                     "no_key": sum(r["note"].startswith("No key") for r in rs),
                     "equivalent_key": sum(r["note"] == "Equivalent key" for r in rs),
                     "wrong_key_avg_err_patterns": round(mean(r["err_patterns"] for r in wk), 3) if wk else ""})
    write_csv("exp3_appsat_summary.csv", summ)
    for s in summ:
        print(s)
