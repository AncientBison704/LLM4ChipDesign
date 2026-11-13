#!/usr/bin/env python3
# Empirically pin down the exact round function from the known pair.
from les_ref import SBOX, INV_SBOX, ror32, rol32, sub_bytes, K
import itertools

PT, CT = 0x59C359C3, 0x9CD84392
BOXES = {"S": SBOX, "Sinv": INV_SBOX}
ROTS = {"ror8": lambda x: ror32(x, 8), "rol8": lambda x: rol32(x, 8), "none": lambda x: x}

def make_round(box, rot, order):
    b = BOXES[box]; r = ROTS[rot]
    sb = lambda x: sub_bytes(x, b)
    ops = {"S": sb, "R": r, "X": lambda x: x ^ K}
    def rnd(x):
        for o in order:
            x = ops[o](x)
        return x
    return rnd

def run(rnd, x, n):
    for _ in range(n):
        x = rnd(x)
    return x

hits = []
for box in BOXES:
    for rot in ROTS:
        for order in itertools.permutations("SRX"):
            rnd = make_round(box, rot, order)
            for n in range(1, 9):
                if run(rnd, PT, n) == CT:
                    hits.append((box, rot, "".join(order), n))
print("matches f(PT)=CT  (box, rot, order S=sbox R=rotate X=xorK, rounds):")
for h in hits:
    print("  ", h)
if not hits:
    print("   none")
