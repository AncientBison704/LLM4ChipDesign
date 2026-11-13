#!/usr/bin/env python3
# Regenerate the S-box memory init files for the RTL from the reference model.
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from les_ref import SBOX, INV_SBOX

def write_mem(path, data):
    with open(path, "w") as f:
        f.write("\n".join(f"{b:02x}" for b in data) + "\n")

write_mem(os.path.join(ROOT, "rtl", "sbox.mem"),  SBOX)
write_mem(os.path.join(ROOT, "rtl", "isbox.mem"), INV_SBOX)
print("wrote rtl/sbox.mem and rtl/isbox.mem")
