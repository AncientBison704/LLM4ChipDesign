"""Exp 4b - area overhead without whole-circuit re-synthesis noise.

exp4_overhead.py re-synthesises the entire benchmark, so ABC restructures logic
far away from the 5-8 locked sites and the result is noisy. Here the growth is
the sum, over the locked sites, of (mapped KCC area - mapped area of what it
replaces), using the stand-alone numbers in results/exp4_per_topology_area.csv.
Needs exp4_overhead.py to have been run once (for that CSV and base areas).
"""
import csv
import os
from collections import defaultdict

from common import BENCH, BITS, RESULTS, SEEDS, STYLE, bench, mean, new_axes, save, write_csv
from rkc.kcc import SCHEMES, scheme_name
from rkc.lock import choose_sites

per = {(r["scheme"], r["gate"]): r for r in csv.DictReader(open(os.path.join(RESULTS, "exp4_per_topology_area.csv")))}
base = {r["circuit"]: float(r["base_um2"]) for r in csv.DictReader(open(os.path.join(RESULTS, "exp4_overhead.csv")))}
gate_area = {g: float(per[("RKC-m2", g)]["orig_um2"]) for g in ("AND", "NAND", "OR", "NOR")}

rows = []
for c in BENCH:
    o = bench(c)
    for bits in BITS:
        for seed in SEEDS:
            sites = choose_sites(o, bits // 2, seed)
            for s in SCHEMES:
                n = scheme_name(s)
                for col, label in (("kcc_um2", "kcc"), ("kcc+mux_um2", "kcc+mux")):
                    g = 0.0
                    for st in sites:
                        if s[0] == "RKC":
                            g += float(per[(n, st.gate)][col]) - gate_area[st.gate]
                        elif st.w_independent:      # W absorbed into the MKC
                            p = per[(n, "AND-" + st.gate)]
                            g += float(p[col]) - float(p["orig_um2"])
                        else:                       # W stays, only X is replaced
                            g += float(per[(n, "AND-" + st.gate)][col]) - gate_area[st.gate]
                    rows.append({"circuit": c, "scheme": n, "bits": bits, "seed": seed, "accounting": label,
                                 "growth_um2": round(g, 3), "growth_pct": round(100 * g / base[c], 4)})
write_csv("exp4b_local_area.csv", rows)

agg = defaultdict(list)
for r in rows:
    agg[(r["accounting"], r["scheme"], r["bits"])].append(r)
summ = [{"accounting": a, "scheme": s, "bits": b,
         "avg_growth_pct": round(mean(r["growth_pct"] for r in rs), 4),
         "avg_growth_um2": round(mean(r["growth_um2"] for r in rs), 3)}
        for (a, s, b), rs in sorted(agg.items())]
write_csv("exp4b_local_area_summary.csv", summ)
t7 = []
for a in ("kcc", "kcc+mux"):
    row = {"accounting": a}
    for s in STYLE:
        g = {x["bits"]: x["avg_growth_um2"] for x in summ if x["accounting"] == a and x["scheme"] == s}
        row[s] = round((g[16] - g[10]) / 6, 4)
    t7.append(row)
    print("per-bit area growth (um^2/bit, NanGate45, local):", row)
write_csv("exp4b_table7_area_per_bit.csv", t7)

fig, axes = new_axes(2)
for ax, a in zip(axes, ("kcc", "kcc+mux")):
    for s, (col, mk) in STYLE.items():
        pts = [x for x in summ if x["accounting"] == a and x["scheme"] == s]
        ax.plot([p["bits"] for p in pts], [p["avg_growth_pct"] for p in pts], color=col, marker=mk, lw=2, ms=7, label=s)
    ax.set_title(f"Average area growth (local), accounting = {a}", fontsize=10, loc="left", color="#0b0b0b")
    ax.set_xlabel("locked bits", fontsize=9, color="#52514e")
    ax.set_ylabel("area growth (%)", fontsize=9, color="#52514e")
    ax.set_xticks(BITS)
    ax.set_ylim(bottom=0)
    ax.legend(frameon=False, fontsize=9)
save(fig, "fig14a_area_overhead_local.png")
