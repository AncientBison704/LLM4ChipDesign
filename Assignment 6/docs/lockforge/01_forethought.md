# Stage 1 - Forethought (LLM-A, paper only)

Paper: W. Wang, L. Zhao, S. Cai, "Replacement-Based Key-Controlled Circuits: A New
Lightweight Logic-Locking Technique to Prevent the SAT Attack and Its Variants",
Appl. Sci. 2026, 16, 925. https://doi.org/10.3390/app16020925

## Overview (agent's own words)

Conventional locking gives every key input one fixed correct value, and the SAT
attack finds it. This paper (building on GateLock) instead makes the key that
reaches the logic *depend on circuit inputs*. A gate `Y = X(A,B)` is replaced by a
small "key-controlled circuit" (KCC) over `K1,K2,A,B`. `K1,K2` come from a
LUT-style tamper-proof memory: one 2:1 MUX per key line, select = a circuit input,
data = stored cells. The input space of the gate is split into `m` sets, and each
set is unlocked by a different key combination. The KCC is built from a K-map with
don't-cares, filled so that (i) it is cheap, (ii) it depends on all of its inputs,
and (iii) no single static `(K1,K2)` reproduces the gate on every input. RKC
replaces one gate, MKC replaces a two-gate `AND -> X` topology, each for `m=2` and
`m=4`, giving 4 schemes x 6 gate types = 24 circuits (Tables 1-4).

## Concepts the code must realise

| # | Concept | Paper location |
|---|---|---|
| C1 | Replacement, not insertion: the gate/topology is removed and the KCC drives the same net | Sec. 4.1, Fig. 2 |
| C2 | Two key lines `K1,K2` per KCC; "locked bits" = number of key lines = 2 x sites | Sec. 5.2 |
| C3 | RKC-m2 expressions for AND/NAND/OR/NOR/XOR/XNOR | Table 1 |
| C4 | RKC-m4 expressions | Table 2 |
| C5 | MKC-m2 expressions for AND-X topologies (`W=AND(A,B); Y=X(W,C)`) | Table 3 |
| C6 | MKC-m4 expressions | Table 4 |
| C7 | LUT memory: `m=2` -> both key MUXes selected by `A` (KC1=00, KC2=11); `m=4` -> K1 by `A`, K2 by `B` (KC=AB) | Sec. 4.1, 4.2 |
| C8 | Storage options: 2x (two cells per key line) or 1x (one cell + inverter) | Sec. 4.1 |
| C9 | MKC absorbs `W` only if `W` is independent (fanout 1); otherwise only `X` is replaced | Sec. 4.2, Fig. 12 |
| C10 | Security property: for every static `(K1,K2)`, at least one circuit-input pattern is wrong; under the LUT-driven key all patterns are right | Figs. 4, 6, 9, 11 |
| C11 | Random site selection; RKC and MKC applied to the same sites for a given key size | Sec. 5.2 |

## Things the paper leaves implicit (resolved by the agent)

* The schematics (Figs. 2, 3, 5, 7, 8, 10) are images. The MUX wiring was inferred
  from the text (`KC` values per input set) and then *proved* by exhaustive
  evaluation: with `K1=K2=A` (m=2) or `K1=A, K2=B` (m=4) all 24 expressions equal
  the original function.
* Which signals are `A,B,C` in an MKC: only `W=AND(A,B)`, `Y=X(W,C)` makes all
  twelve Table 3/4 expressions correct.
* Attack threat model: Sec. 5.2 does not say what the attacker's netlist contains.
  The reported outcomes ("all keys eliminated" / "wrong key") are only possible if
  `K1,K2` are exposed as ordinary static key inputs, so that is the model used for
  the reproduction. The alternative (attacker sees the MUXes) is Exp 5.

## Expected artefacts

1. Locking tool: `.bench` in, locked `.bench`/Verilog out, for all four schemes.
2. Exhaustive truth-table verification of Tables 1-4 (property C10).
3. SAT attack sweep = Fig. 13 (6 circuits, 10-16 bits, 10 seeds).
4. AppSAT on c1355/16 bits = Table 6.
5. Area overhead vs locked bits = Fig. 14a / Table 7 / Fig. 15a (open-source flow).
6. Brute-force counts = Eqs. (1)-(3).
