"""Exp 2 - Fig. 13: SAT attack on RKC/MKC-locked benchmarks.

Threat model = the paper's: the attacker's netlist exposes K1,K2 of each
key-controlled circuit as ordinary (static) key inputs; the oracle is the
activated chip. 6 circuits x 4 schemes x {10,12,14,16} locked bits x 10 seeds.
RKC and MKC are applied to the same sites for a given (circuit, bits, seed).
"""
from collections import defaultdict

from common import BENCH, BITS, SEEDS, STYLE, bench, mean, new_axes, pmap, save, write_csv
from rkc.attacks import equivalent, error_rate, sat_attack
from rkc.kcc import SCHEMES, scheme_name
from rkc.lock import choose_sites, lock, tie_key


def run(job):
    c, bits, seed = job
    o = bench(c)
    sites = choose_sites(o, bits // 2, seed)
    out = []
    for s in SCHEMES:
        L = lock(o, s, sites, "static")
        a = sat_attack(L.netlist, o)
        row = {"circuit": c, "scheme": scheme_name(s), "bits": bits, "seed": seed,
               "iterations": a.iterations, "time_s": round(a.time, 4),
               "outcome": "all keys eliminated", "err_patterns": "", "hd_pct": "",
               "w_removed": L.removed_w}
        if a.key is not None:
            eq, _ = equivalent(tie_key(L.netlist, a.key), o)
            e, hd = error_rate(L.netlist, a.key, o)
            row.update(outcome="equivalent key" if eq else "wrong key",
                       err_patterns=round(e, 4), hd_pct=round(hd, 3))
        out.append(row)
    return out


if __name__ == "__main__":
    jobs = [(c, b, s) for c in BENCH for b in BITS for s in SEEDS]
    rows = [r for rs in pmap(run, jobs) for r in rs]
    write_csv("exp2_sat_attack.csv", rows)

    agg = defaultdict(list)
    for r in rows:
        agg[(r["scheme"], r["bits"])].append(r)
    summ = []
    for (sch, bits), rs in sorted(agg.items()):
        n = len(rs)
        wk = [r for r in rs if r["outcome"] == "wrong key"]
        summ.append({"scheme": sch, "bits": bits, "runs": n,
                     "avg_iterations": round(mean(r["iterations"] for r in rs), 2),
                     "max_iterations": max(r["iterations"] for r in rs),
                     "avg_time_s": round(mean(r["time_s"] for r in rs), 3),
                     "all_keys_eliminated": sum(r["outcome"] == "all keys eliminated" for r in rs),
                     "wrong_key": len(wk),
                     "equivalent_key": sum(r["outcome"] == "equivalent key" for r in rs),
                     "wrong_key_avg_err_patterns": round(mean(r["err_patterns"] for r in wk), 3) if wk else ""})
    write_csv("exp2_sat_attack_summary.csv", summ)
    for s in summ:
        print(s)

    fig, (a1, a2) = new_axes(2)
    for sch, (col, mk) in STYLE.items():
        pts = [s for s in summ if s["scheme"] == sch]
        a1.plot([p["bits"] for p in pts], [p["avg_iterations"] for p in pts], color=col, marker=mk, lw=2, ms=7, label=sch)
        a2.plot([p["bits"] for p in pts], [p["avg_time_s"] for p in pts], color=col, marker=mk, lw=2, ms=7, label=sch)
    for ax, t, yl in ((a1, "SAT attack: DIP iterations until termination", "avg. iterations"),
                      (a2, "SAT attack: run time until termination", "avg. time (s)")):
        ax.set_title(t, fontsize=10, loc="left", color="#0b0b0b")
        ax.set_xlabel("locked bits", fontsize=9, color="#52514e")
        ax.set_ylabel(yl, fontsize=9, color="#52514e")
        ax.set_xticks(BITS)
        ax.set_ylim(bottom=0)
        ax.legend(frameon=False, fontsize=9)
    save(fig, "fig13_sat_attack.png")
