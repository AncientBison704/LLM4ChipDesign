#!/usr/bin/env bash
# =====================================================================
#  One-command pipeline: AI-generated Trojan insertion -> simulation.
#
#    1. regenerate S-box memories          (scripts/gen_mem.py)
#    2. AST-insert the Trojan into baseline (insert_trojan.py, Pyverilog)
#    3. compile + run baseline regression   (tb/tb_baseline.v)
#    4. compile + run exploit demonstration (tb/tb_exploit.v)
#
#  Requires: iverilog/vvp, python3 with pyverilog.  Exits non-zero on any
#  test failure so it can gate CI.
# =====================================================================
set -euo pipefail
cd "$(dirname "$0")"

echo "== [1/4] regenerate S-box memories =="
python3 scripts/gen_mem.py

echo "== [2/4] AST-insert Trojan (baseline -> les_crypto_trojan.v) =="
python3 insert_trojan.py

mkdir -p out

echo "== [3/4] baseline regression =="
iverilog -g2012 -o out/baseline.vvp rtl/les_crypto.v tb/tb_baseline.v
( cd rtl && vvp ../out/baseline.vvp ) | tee out/baseline.log
grep -q "ALL TESTS PASS" out/baseline.log

echo "== [4/4] exploit demonstration =="
iverilog -g2012 -o out/exploit.vvp rtl/les_crypto_trojan.v tb/tb_exploit.v
( cd rtl && vvp ../out/exploit.vvp ) | tee out/exploit.log
grep -q "ALL CHECKS PASS" out/exploit.log

rm -f parser.out parsetab.py   # PLY/Pyverilog scratch

echo ""
echo "== PIPELINE OK: baseline preserved, key exfiltrated in simulation =="
echo "   waveforms: rtl/baseline.vcd, rtl/exploit.vcd"
