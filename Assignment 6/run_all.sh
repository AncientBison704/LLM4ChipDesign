#!/usr/bin/env bash
# Reproduce every result in results/. ~2 min for attacks, ~25 min for synthesis (2 cores).
set -euo pipefail
cd "$(dirname "$0")"
python3 -m pytest -q tests
python3 experiments/exp1_kcc_tables.py
python3 experiments/exp2_sat_attack.py
python3 experiments/exp3_appsat.py
python3 experiments/exp5_netlist_aware.py
python3 experiments/exp6_bruteforce.py
python3 experiments/exp4_overhead.py   # set OVERHEAD_SEEDS=3 for a quicker run
python3 experiments/exp4b_local_area.py
