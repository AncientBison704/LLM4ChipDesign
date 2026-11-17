"""Exp 5 (beyond the paper) - what if the attacker's netlist includes the
LUT-based key memory?

The paper's attack experiments expose K1/K2 as free static key inputs. But the
MUXes that derive K1/K2 from the circuit inputs are part of the fabricated
netlist; only the memory *cells* are secret. Here the cells are the key inputs
(``view="full"``) and the same SAT attack is run.

Also: (a) sanity check that the attack code breaks plain XOR locking (RLL),
(b) scaling of the netlist-aware attack with the number of locked bits.
"""
from collections import defaultdict

from common import BENCH, SEEDS, bench, mean, pmap, write_csv
from rkc.attacks import equivalent, sat_attack
from rkc.kcc import SCHEMES, scheme_name
from rkc.lock import choose_sites, lock, lock_rll, tie_key


def run(job):
    c, bits, seed, storage = job
    o = bench(c)
    out = []
    if storage == "rll":
        L = lock_rll(o, bits, seed)
        a = sat_attack(L.netlist, o)
        eq = a.key is not None and equivalent(tie_key(L.netlist, a.key), o)[0]
        return [{"circuit": c, "scheme": "RLL (XOR)", "storage": "-", "locked_bits": bits,
                 "memory_cells": bits, "seed": seed, "iterations": a.iterations,
                 "time_s": round(a.time, 4), "key_found": a.key is not None, "equivalent": eq}]
    sites = choose_sites(o, bits // 2, seed)
    for s in SCHEMES:
        L = lock(o, s, sites, "full", storage)
        a = sat_attack(L.netlist, o)
        eq = a.key is not None and equivalent(tie_key(L.netlist, a.key), o)[0]
        out.append({"circuit": c, "scheme": scheme_name(s), "storage": storage, "locked_bits": bits,
                    "memory_cells": len(L.netlist.keys), "seed": seed, "iterations": a.iterations,
                    "time_s": round(a.time, 4), "key_found": a.key is not None, "equivalent": eq})
    return out


if __name__ == "__main__":
    jobs = [(c, 16, s, st) for c in BENCH for s in SEEDS for st in ("2x", "1x", "rll")]
    jobs += [(c, b, s, "2x") for c in ("des", "i8") for b in (32, 64, 128) for s in SEEDS[:5]]
    rows = [r for rs in pmap(run, jobs) for r in rs]
    write_csv("exp5_netlist_aware.csv", rows)
    agg = defaultdict(list)
    for r in rows:
        agg[(r["scheme"], r["storage"], r["locked_bits"])].append(r)
    summ = []
    for (sch, st, bits), rs in sorted(agg.items()):
        summ.append({"scheme": sch, "storage": st, "locked_bits": bits, "runs": len(rs),
                     "circuits": " ".join(sorted({r["circuit"] for r in rs})),
                     "key_recovered_and_equivalent": sum(r["equivalent"] for r in rs),
                     "avg_iterations": round(mean(r["iterations"] for r in rs), 1),
                     "max_iterations": max(r["iterations"] for r in rs),
                     "avg_time_s": round(mean(r["time_s"] for r in rs), 3),
                     "max_time_s": max(r["time_s"] for r in rs)})
    write_csv("exp5_netlist_aware_summary.csv", summ)
    for s in summ:
        print(s)
