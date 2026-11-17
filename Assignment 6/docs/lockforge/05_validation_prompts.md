# Stage 4 - Validation prompts (LLM-B / LLM-C, code only)

LockForge requires the Judge and Examiner to be agents that have **not** seen the
paper or the implementation session. Start a fresh chat for each, upload only
`rkc/*.py`, `tests/test_core.py` and `docs/lockforge/03_checklist.yaml`, and paste
the prompt. Record the raw replies under `docs/lockforge/validation/`.

## Judge prompt

> You are reviewing a Python implementation of a logic-locking scheme. You have not
> seen the paper. (1) Read the code and explain, in your own words, what the locking
> scheme does: what is replaced, where the keys come from, and what makes it resist
> a SAT attack. (2) Using the attached YAML checklist, give B, C, S, R in [0,1] and
> a penalty P (minor 1, major 2, severe 3 per critical omission), each with a
> one-line justification that cites a file and function.
> (3) Report score = max(1, 10*(0.4B + 0.3C + 0.2S + 0.1R) - P).

Compare the Judge's explanation with `01_forethought.md`. Pass mark: score >= 8.

## Examiner prompt

> You have only the attached code. For each statement answer True or False and cite
> the line(s) of code that decide it. Do not guess from general knowledge of logic
> locking; if the code does not decide a statement, say "undetermined".
> (paste statements 1-10 from `04_examiner_statements.md`, without the answer key)

Pass mark: 8 of 10 correct.
