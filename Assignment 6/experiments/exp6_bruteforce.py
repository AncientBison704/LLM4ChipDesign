"""Exp 6 - Eqs. (1)-(3): brute-force attempt counts claimed in Sec. 4.3.

b_max   = 2^k
N_p     = sum_{i=2}^{2^k} (2^k)! / (2^k - i)!
N_total = b_max + N_p = (2^k)! * sum_{i=1}^{2^k} 1 / (2^k - i)!
"""
from math import factorial, log2

from common import write_csv

rows = []
for k in (1, 2, 3, 4, 5, 6):
    n = 2 ** k
    bmax = n
    np_ = sum(factorial(n) // factorial(n - i) for i in range(2, n + 1))
    closed = sum(factorial(n) // factorial(n - i) for i in range(1, n + 1))
    assert bmax + np_ == closed
    rows.append({"k_bits": k, "b_max": bmax, "N_p": np_, "N_total": closed,
                 "log2_N_total": round(log2(closed), 1)})
    print(rows[-1])
write_csv("exp6_bruteforce.csv", rows)
