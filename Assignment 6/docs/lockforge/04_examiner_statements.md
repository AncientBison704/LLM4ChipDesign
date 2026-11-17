# Stage 4b - LLM-as-Examiner statements

Written by LLM-A from the paper. An examiner agent (LLM-B / LLM-C) that has seen
**only the code** answers True/False for each. Pass mark: 8 of 10.
The answer key is at the bottom; do not show it to the examiner.

1. The scheme inserts extra XOR/XNOR key gates on existing wires and leaves every original gate in place.
2. Each locked site adds exactly two key lines.
3. For the m=2 variants, both key lines of a site are selected by the same circuit input.
4. For the m=4 variants, the two key lines of a site are selected by two different circuit inputs.
5. The RKC-m2 replacement for an AND gate is `K1'A + K2B`.
6. For every key-controlled circuit there is one constant value of (K1, K2) that makes it equal to the original gate for all inputs.
7. An MKC targets a two-gate topology whose first gate is always an AND.
8. When the intermediate AND output of an MKC site also feeds other gates, the AND gate is still deleted.
9. With the correct memory contents and the MUX-based memory included, the locked circuit is functionally identical to the original.
10. The MKC-m4 replacement for the AND-NAND topology is `K1'A' + K1B' + K2C'`.

---

Answer key: 1 F, 2 T, 3 T, 4 T, 5 T, 6 F, 7 T, 8 F, 9 T, 10 T
