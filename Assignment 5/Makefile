# Convenience wrapper around build.sh
.PHONY: all trojan baseline exploit clean
all:
	./build.sh

trojan:
	python3 scripts/gen_mem.py
	python3 insert_trojan.py

baseline: trojan
	mkdir -p out
	iverilog -g2012 -o out/baseline.vvp rtl/les_crypto.v tb/tb_baseline.v
	cd rtl && vvp ../out/baseline.vvp

exploit: trojan
	mkdir -p out
	iverilog -g2012 -o out/exploit.vvp rtl/les_crypto_trojan.v tb/tb_exploit.v
	cd rtl && vvp ../out/exploit.vvp

clean:
	rm -rf out rtl/*.vcd
