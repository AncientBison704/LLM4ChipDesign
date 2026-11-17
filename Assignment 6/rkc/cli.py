"""Lock a .bench netlist and (optionally) attack it.

  python -m rkc.cli benchmarks/c1355.bench --scheme RKC-m2 --bits 16 --seed 0 \
         --view static -o locked.bench --attack sat
"""
import argparse

from .attacks import appsat, equivalent, error_rate, sat_attack
from .lock import choose_sites, lock, tie_key
from .netlist import read_bench, write_bench, write_verilog


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("bench")
    p.add_argument("--scheme", default="RKC-m2", choices=["RKC-m2", "RKC-m4", "MKC-m2", "MKC-m4"])
    p.add_argument("--bits", type=int, default=16, help="locked bits (2 per site)")
    p.add_argument("--seed", type=int, default=0)
    p.add_argument("--view", default="static", choices=["static", "full"],
                   help="static: K1/K2 are key inputs; full: include LUT key memory")
    p.add_argument("--storage", default="2x", choices=["2x", "1x"])
    p.add_argument("-o", "--out", help="output .bench or .v")
    p.add_argument("--attack", choices=["sat", "appsat"])
    a = p.parse_args()

    orig = read_bench(a.bench)
    scheme = (a.scheme[:3], int(a.scheme[-1]))
    L = lock(orig, scheme, choose_sites(orig, a.bits // 2, a.seed), a.view, a.storage)
    print(f"{orig.name}: {orig.stats()} -> locked {L.netlist.stats()}  "
          f"sites={[s.x + ':' + s.gate for s in L.sites]}  W absorbed={L.removed_w}")
    if a.view == "full":
        print("correct memory contents:", L.correct_key)
        print("activated == original:", equivalent(tie_key(L.netlist, L.correct_key), orig)[0])
    if a.out:
        (write_verilog if a.out.endswith(".v") else write_bench)(L.netlist, a.out)
        print("wrote", a.out)
    if a.attack:
        r = (sat_attack if a.attack == "sat" else appsat)(L.netlist, orig)
        print(f"{a.attack}: {r.iterations} DIPs, {r.time:.3f}s, outcome={r.outcome}")
        if r.key:
            eq = equivalent(tie_key(L.netlist, r.key), orig)[0]
            e, hd = error_rate(L.netlist, r.key, orig)
            print(f"  key={''.join(str(r.key[k]) for k in L.netlist.keys)} equivalent={eq} "
                  f"wrong-pattern rate={e:.3f} HD={hd:.2f}%")


if __name__ == "__main__":
    main()
