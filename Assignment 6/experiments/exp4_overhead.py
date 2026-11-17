"""Exp 4 - Figs. 14a / 15a and Table 7 (area rows): hardware overhead.

The paper uses Synopsys DC + TSMC 28 nm (both proprietary). Substitute:
Yosys + ABC mapped to the open NanGate 45 nm library, so absolute um^2 are not
comparable; the reproduced quantities are area growth in % and ratios/ordering.
Power is NOT reproduced (no open signoff-grade power flow was available).

Two accountings are reported:
  kcc      key-controlled circuits only, K1/K2 as ports (what the paper's
           tiny per-bit numbers appear to measure)
  kcc+mux  additionally the 2:1 MUXes of the LUT key memory (cells are ports;
           the storage cells themselves are not counted)

Usage: python experiments/exp4_overhead.py [path/to/liberty.lib]
"""
import os
import re
import subprocess
import sys
import tempfile
import urllib.request
from collections import defaultdict

from common import BENCH, BITS, ROOT, SEEDS, STYLE, bench, mean, new_axes, pmap, save, write_csv
from rkc.kcc import GATES, SCHEMES, circuit_inputs, key_select, scheme_name, sop
from rkc.lock import _emit_sop, choose_sites, lock
from rkc.netlist import Netlist, write_verilog

LIB_URL = ("https://raw.githubusercontent.com/The-OpenROAD-Project/OpenROAD-flow-scripts/"
           "master/flow/platforms/nangate45/lib/NangateOpenCellLibrary_typical.lib")
LIB = os.path.abspath(sys.argv[1]) if len(sys.argv) > 1 else os.path.join(ROOT, "lib", "nangate45_typical.lib")
N_SEEDS = int(os.environ.get("OVERHEAD_SEEDS", len(SEEDS)))


def ensure_lib():
    if not os.path.exists(LIB):
        os.makedirs(os.path.dirname(LIB), exist_ok=True)
        print("downloading NanGate45 liberty ->", LIB)
        urllib.request.urlretrieve(LIB_URL, LIB)


def area(nl: Netlist) -> float:
    # yowasp-yosys (WASI) cannot open files under /tmp by absolute path, so run inside the dir
    with tempfile.TemporaryDirectory() as d:
        v = os.path.join(d, "top.v")
        write_verilog(nl, v, module="top")
        script = f"read_verilog top.v; synth -top top; abc -liberty {LIB}; tee -o stat.txt stat -liberty {LIB}"
        # stdout after the ABC pass is lost under WASI, so the report goes to a file
        subprocess.run(["yowasp-yosys", "-q", "-p", script], capture_output=True, text=True, check=True, cwd=d)
        out = open(os.path.join(d, "stat.txt")).read()
    return float(re.findall(r"Chip area for module '\\top':\s*([\d.eE+-]+)", out)[-1])


def run(job):
    c, bits, seed = job
    o = bench(c)
    sites = choose_sites(o, bits // 2, seed)
    out = []
    for s in SCHEMES:
        for view, label in (("static", "kcc"), ("full", "kcc+mux")):
            out.append({"circuit": c, "scheme": scheme_name(s), "bits": bits, "seed": seed,
                        "accounting": label, "area_um2": round(area(lock(o, s, sites, view).netlist), 3)})
    return out


def base(c):
    return c, round(area(bench(c)), 3)


def single(scheme, gate, with_mux):
    """Stand-alone locking circuit for one gate / topology."""
    nl = Netlist("top")
    xs = circuit_inputs(scheme)
    for x in xs:
        nl.add_input(x)
    binding = {x: x for x in xs}
    for j, sel in enumerate(key_select(scheme)):
        if with_mux:
            nl.add_input(f"keyinput{2 * j}"), nl.add_input(f"keyinput{2 * j + 1}")
            nl.add_gate(f"K{j + 1}", "MUX", [sel, f"keyinput{2 * j}", f"keyinput{2 * j + 1}"])
            binding[f"K{j + 1}"] = f"K{j + 1}"
        else:
            nl.add_input(f"keyinput{j}")
            binding[f"K{j + 1}"] = f"keyinput{j}"
    _emit_sop(nl, "Y", sop(scheme, gate), binding, "k")
    nl.outputs = ["Y"]
    return nl


def original(scheme, gate):
    nl = Netlist("top")
    for x in circuit_inputs(scheme):
        nl.add_input(x)
    if scheme[0] == "RKC":
        nl.add_gate("Y", gate, ["A", "B"])
    else:
        nl.add_gate("W", "AND", ["A", "B"])
        nl.add_gate("Y", gate, ["W", "C"])
    nl.outputs = ["Y"]
    return nl


def run_single(job):
    s, g = job
    a0 = area(original(s, g))
    return {"scheme": scheme_name(s), "gate": g if s[0] == "RKC" else "AND-" + g,
            "orig_um2": round(a0, 3),
            "kcc_um2": round(area(single(s, g, False)), 3),
            "kcc+mux_um2": round(area(single(s, g, True)), 3)}


if __name__ == "__main__":
    ensure_lib()
    # ---- Fig. 15a analogue: per-topology relative area
    per = pmap(run_single, [(s, g) for s in SCHEMES for g in GATES])
    for r in per:
        r["rel_kcc_um2"] = round(r["kcc_um2"] - r["orig_um2"], 3)
        r["rel_kcc+mux_um2"] = round(r["kcc+mux_um2"] - r["orig_um2"], 3)
    write_csv("exp4_per_topology_area.csv", per)

    # ---- Fig. 14a / Table 7 analogue: benchmark-level growth
    base_area = dict(pmap(base, BENCH))
    rows = [r for rs in pmap(run, [(c, b, s) for c in BENCH for b in BITS for s in range(N_SEEDS)]) for r in rs]
    for r in rows:
        r["base_um2"] = base_area[r["circuit"]]
        r["growth_um2"] = round(r["area_um2"] - r["base_um2"], 3)
        r["growth_pct"] = round(100 * r["growth_um2"] / r["base_um2"], 4)
    write_csv("exp4_overhead.csv", rows)

    agg = defaultdict(list)
    for r in rows:
        agg[(r["accounting"], r["scheme"], r["bits"])].append(r)
    summ = [{"accounting": a, "scheme": s, "bits": b,
             "avg_growth_pct": round(mean(r["growth_pct"] for r in rs), 4),
             "avg_growth_um2": round(mean(r["growth_um2"] for r in rs), 3)}
            for (a, s, b), rs in sorted(agg.items())]
    write_csv("exp4_overhead_summary.csv", summ)

    t7 = []
    for a in ("kcc", "kcc+mux"):
        row = {"accounting": a}
        for s in STYLE:
            g = {x["bits"]: x["avg_growth_um2"] for x in summ if x["accounting"] == a and x["scheme"] == s}
            row[s] = round((g[16] - g[10]) / 6, 4)
        t7.append(row)
        print("per-bit area growth (um^2/bit, NanGate45):", row)
    write_csv("exp4_table7_area_per_bit.csv", t7)

    fig, axes = new_axes(2)
    for ax, a in zip(axes, ("kcc", "kcc+mux")):
        for s, (col, mk) in STYLE.items():
            pts = [x for x in summ if x["accounting"] == a and x["scheme"] == s]
            ax.plot([p["bits"] for p in pts], [p["avg_growth_pct"] for p in pts], color=col, marker=mk, lw=2, ms=7, label=s)
        ax.set_title(f"Average area growth, accounting = {a}", fontsize=10, loc="left", color="#0b0b0b")
        ax.set_xlabel("locked bits", fontsize=9, color="#52514e")
        ax.set_ylabel("area growth (%)", fontsize=9, color="#52514e")
        ax.set_xticks(BITS)
        ax.axhline(0, color="#c3c2b7", lw=1)
        ax.legend(frameon=False, fontsize=9)
    save(fig, "fig14a_area_overhead.png")
