"""Shared helpers for the experiment scripts."""
from __future__ import annotations

import csv
import os
import sys
from multiprocessing import Pool

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)

from rkc.kcc import SCHEMES, scheme_name  # noqa: E402
from rkc.netlist import read_bench  # noqa: E402

BENCH = ["c1355", "c5315", "c7552", "des", "i7", "i8"]
BITS = [10, 12, 14, 16]
SEEDS = list(range(10))
RESULTS = os.path.join(ROOT, "results")
os.makedirs(RESULTS, exist_ok=True)

_cache = {}


def bench(name):
    if name not in _cache:
        _cache[name] = read_bench(os.path.join(ROOT, "benchmarks", name + ".bench"))
    return _cache[name]


def write_csv(name, rows):
    path = os.path.join(RESULTS, name)
    with open(path, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    print("wrote", os.path.relpath(path, ROOT))
    return path


def pmap(fn, jobs, procs=None):
    with Pool(procs or os.cpu_count()) as p:
        return p.map(fn, jobs, chunksize=4)


def mean(xs):
    xs = list(xs)
    return sum(xs) / len(xs) if xs else float("nan")


# chart style: fixed colour + marker per scheme (identity never colour-alone)
STYLE = {
    "RKC-m2": ("#2a78d6", "o"),
    "RKC-m4": ("#eb6834", "s"),
    "MKC-m2": ("#1baf7a", "^"),
    "MKC-m4": ("#eda100", "D"),
}


def new_axes(ncols=1, w=5.2, h=3.6):
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    fig, axes = plt.subplots(1, ncols, figsize=(w * ncols, h), facecolor="#fcfcfb")
    for ax in ([axes] if ncols == 1 else axes):
        ax.set_facecolor("#fcfcfb")
        for s in ("top", "right"):
            ax.spines[s].set_visible(False)
        for s in ("left", "bottom"):
            ax.spines[s].set_color("#c3c2b7")
        ax.grid(axis="y", color="#e6e5e0", linewidth=0.8)
        ax.set_axisbelow(True)
        ax.tick_params(colors="#52514e", labelsize=9)
    return fig, axes


def save(fig, name):
    path = os.path.join(RESULTS, name)
    fig.tight_layout()
    fig.savefig(path, dpi=160)
    print("wrote", os.path.relpath(path, ROOT))
