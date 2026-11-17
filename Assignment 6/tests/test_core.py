"""Smoke / behaviour tests (LockForge "B" and "S" checks). Run: pytest -q"""
import os
import sys

import pytest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)

from rkc.attacks import equivalent, error_rate, sat_attack  # noqa: E402
from rkc.kcc import GATES, SCHEMES, circuit_inputs, dynamic_key, truth_table  # noqa: E402
from rkc.lock import choose_sites, lock, lock_rll, tie_key  # noqa: E402
from rkc.netlist import read_bench  # noqa: E402

ALL = [(s, g) for s in SCHEMES for g in GATES]


@pytest.fixture(scope="module")
def c1355():
    return read_bench(os.path.join(ROOT, "benchmarks", "c1355.bench"))


@pytest.mark.parametrize("scheme,gate", ALL)
def test_kcc_correct_under_lut_key(scheme, gate):
    tt, xs = truth_table(scheme, gate), circuit_inputs(scheme)
    for v, (_, orig) in tt[(0, 0)].items():
        assert tt[dynamic_key(scheme, dict(zip(xs, v)))][v][0] == orig


@pytest.mark.parametrize("scheme,gate", ALL)
def test_no_static_key_unlocks_kcc(scheme, gate):
    for rows in truth_table(scheme, gate).values():
        assert any(locked != orig for locked, orig in rows.values())


def test_lut_memory_partitions():
    # m=2: two key combinations (00 / 11); m=4: four
    for s in SCHEMES:
        xs = circuit_inputs(s)
        keys = {dynamic_key(s, dict(zip(xs, v))) for v in truth_table(s, "AND")[(0, 0)]}
        assert len(keys) == s[1]


@pytest.mark.parametrize("scheme", SCHEMES)
@pytest.mark.parametrize("storage", ["2x", "1x"])
def test_activated_circuit_equals_original(c1355, scheme, storage):
    sites = choose_sites(c1355, 8, seed=3)
    L = lock(c1355, scheme, sites, "full", storage)
    assert len(L.netlist.keys) == (32 if storage == "2x" else 16)
    assert equivalent(tie_key(L.netlist, L.correct_key), c1355)[0]


@pytest.mark.parametrize("scheme", SCHEMES)
def test_static_view_has_2_keys_per_site_and_wrong_keys_corrupt(c1355, scheme):
    L = lock(c1355, scheme, choose_sites(c1355, 8, seed=3), "static")
    assert len(L.netlist.keys) == 16
    for bit in (0, 1):
        assert error_rate(L.netlist, {k: bit for k in L.netlist.keys}, c1355)[0] > 0


def test_mkc_absorbs_independent_and_gate():
    o = read_bench(os.path.join(ROOT, "benchmarks", "i8.bench"))
    sites = [s for s in choose_sites(o, 40, seed=0) if s.w_independent][:4]
    assert sites
    L = lock(o, ("MKC", 2), sites, "static")
    assert L.removed_w == len(sites) and all(s.w not in L.netlist.gates for s in sites)
    R = lock(o, ("RKC", 2), sites, "static")
    assert all(s.w in R.netlist.gates for s in sites)


def test_sat_attack_breaks_rll(c1355):
    L = lock_rll(c1355, 16, seed=1)
    a = sat_attack(L.netlist, c1355)
    assert a.outcome == "key" and equivalent(tie_key(L.netlist, a.key), c1355)[0]


@pytest.mark.parametrize("scheme", SCHEMES)
def test_netlist_aware_attack_recovers_function(c1355, scheme):
    L = lock(c1355, scheme, choose_sites(c1355, 8, seed=3), "full")
    a = sat_attack(L.netlist, c1355)
    assert a.outcome == "key" and equivalent(tie_key(L.netlist, a.key), c1355)[0]
