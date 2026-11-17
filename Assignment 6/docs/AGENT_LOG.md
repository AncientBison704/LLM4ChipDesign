# Agent interaction log

Agent: Claude (Anthropic), model `claude-fable-5-2`, running as a tool-using agent
(file read/write, shell, web fetch) in a cloud sandbox with 2 CPU cores, no GPU.
Date: 16 Nov 2026. One session, one human prompt. Workflow: LockForge
(arXiv:2511.18531), with the caveat in the last section.

> Note for the grader: this file is the agent's own account of the session. The
> full chat transcript should be exported and added next to it as
> `docs/transcript.*` for a verbatim record.

## 1. Human prompt (verbatim)

The paper PDF (`applsci-16-00925-v2.pdf`) was attached, followed by the assignment
text and:

> I am using this paper:
>
> Replacement-Based Key-Controlled Circuits: A New Lightweight Logic-Locking
> Technique to Prevent the SAT Attack and Its Variants
>
> Please help me out with this.

No further human prompts were given during the run. Everything below was decided
by the agent.

## 2. What the agent did, by LockForge stage

### Forethought
* Extracted the PDF text (`pdftotext -layout`) and read all 28 pages.
* Read rows 1-2 of the course spreadsheet: "follow the LockForge workflow",
  Python preferred, no GPU. Looked up the LockForge paper for the stage definitions
  and the scoring rubric.
* Wrote the concept list (`docs/lockforge/01_forethought.md`, C1-C11).
* Noticed the paper never states the attacker's netlist model. Reasoned that the
  reported outcomes ("all keys eliminated" or "wrong key") can only occur if K1/K2
  are static key inputs, and planned a second experiment for the other model.

### Implementation
* `rkc/kcc.py`: typed in Tables 1-4, wrote an SOP parser and truth-table generator.
* `rkc/netlist.py`, `rkc/lock.py`, `rkc/attacks.py`: netlist, locking, SAT attack,
  AppSAT, equivalence checking.
* First smoke test (c1355, i7, des; 16 bits): all 24 expressions correct under the
  inferred MUX wiring on the first try; activated circuits SAT-equivalent to the
  originals; RLL broken by the attack; RKC/MKC static view gives UNSAT or wrong key.

### Refinement (3 iterations, see errors below)
* Added the SAT-based classification of returned keys (wrong vs equivalent) instead
  of trusting random simulation.
* Added the `full` view with 2x and 1x storage and the netlist-aware attack.
* Added AppSAT with d=2 after seeing that d=12 rarely reaches an estimation round.
* Added site-level area accounting after seeing that whole-circuit re-synthesis was
  dominated by ABC restructuring noise.
* Filled in `docs/lockforge/03_checklist.yaml` (self-score 8.0/10).

### Validation
* 67 pytest checks pass.
* Examiner statements and Judge/Examiner prompts are written
  (`docs/lockforge/04_*.md`, `05_*.md`). **The independent code-only Judge and
  Examiner agents have not been run.** A single agent did forethought,
  implementation and self-evaluation, so LockForge's role isolation is not yet met.

## 3. Errors and how they were handled

| # | Error / obstacle | Resolution |
|---|---|---|
| 1 | `ModuleNotFoundError: No module named 'pysat'` | `pip install python-sat` |
| 2 | Original benchmark host (bitbucket, HOST'15 repo) unreachable from the sandbox (HTTP 000, network allowlist) | Found the same `.bench` files in a GitHub mirror (`gatelabdavis/RANE`); checked PI/PO/gate counts against Table 5 |
| 3 | Table 5 mismatch: paper lists i7 = 1581 gates, des = 6437, c7552 = 3513; files have 1315, 6473, 3512 | Kept the files. 1581 is the i7 file's line count, 6437 looks like a digit swap. Documented in README |
| 4 | Benchmarks contain no XOR/XNOR gates, so 8 of the 24 circuits can never be instantiated | Verified those exhaustively at truth-table level only; documented |
| 5 | `apt-get install yosys`: package not found | Used `yowasp-yosys` (WebAssembly build from PyPI) |
| 6 | No Synopsys DC / TSMC 28 nm | Yosys + ABC + NanGate45; report growth and ratios, not absolute area; power dropped |
| 7 | Yosys: `ERROR: File '/tmp/.../top.v' not found` (WASI sandbox cannot open absolute /tmp paths) | Run Yosys with `cwd` set to the temp dir and a relative file name |
| 8 | Yosys area regex raised `IndexError`: stdout after the ABC pass is lost under WASI | Write the report with `tee -o stat.txt stat -liberty ...` and parse the file |
| 9 | Full area sweep (1920 synthesis runs) exceeded the 10 min foreground limit | Let it finish in the background (about 27 min); added `OVERHEAD_SEEDS` to shorten it |
| 10 | Whole-circuit area numbers noisy (c1355 +10-18% for 8 gates, some circuits shrink) | Kept them, and added `exp4b_local_area.py` (per-site accounting) |
| 11 | AppSAT iteration counts (3-10) do not match Table 6 (17-24) | Not resolvable from the paper (site choice and iteration counting unspecified). Reported as a discrepancy |
| 12 | `gh` token in the sandbox invalid | Repo delivered as an archive; pushing and inviting collaborators left to the human |

## 4. Judgement calls the paper does not settle

* MUX wiring and A/B/C roles: inferred, then proven by exhaustive evaluation.
* Non-independent `W` (Fig. 12): interpreted as "replace only X, keep W, still feed
  the MKC from W's inputs".
* Site pool: 2-input gates with a 2-input AND fanin, so RKC and MKC can share sites.
* AppSAT details not in this paper (what "settlement" counts): followed the AppSAT
  paper: a round with zero failing random queries counts toward settlement, failing
  queries are added as constraints.
* "Locked bits" in the `full` view: still counted as 2 per site, though the 2x
  memory has 4 cells per site.

## 5. Findings the agent flagged as going beyond the paper

1. With the key-memory MUXes in the attacker's netlist, the SAT attack recovers an
   equivalent key every time (600/600 runs).
2. One static-key run (1/960) returned a key that is functionally correct for the
   whole circuit, because the per-gate guarantee does not lift to circuit level.
3. Negative per-gate area overhead was not observed for any circuit.

## 6. Suggested follow-up prompts (not yet run)

* Fresh agent, code only: Judge prompt in `docs/lockforge/05_validation_prompts.md`.
* Fresh agent, code only: Examiner prompt with the 10 statements.
* "Implement GateLock and CAS-Lock in `rkc/lock.py` and add them to exp4."
