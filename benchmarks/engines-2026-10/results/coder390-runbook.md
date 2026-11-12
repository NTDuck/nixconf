# Coder390 C x ctx sweep — runbook (2026-11-11)

Artifact: /home/ayin/models/q27-bench/downloads/coder390/coder390_qwen3_8_27b.ninfer
(dense ~19G + 5L dflash2 draft, recipe qwen3_8_27b, engine 0.17.2, NINFER_SPEC=dflash2,
NINFER_FALLBACK=off — OOM at startup = cell does not exist).

Run (from benchmarks/engines-2026-10/, GPU free — stop turbo first):
  python3 sweep_coder390.py              # full 10-cell ladder
  python3 sweep_coder390.py --cells ashalliants-coder390-65k-c6:65536:6   # one cell

Cells ladder C downward at each ctx until startup fits; the first START-FAIL
at a ctx marks that ctx's max concurrency. Results append to
results/cells.jsonl (bench.run_cell convention, same as sweep_turbo).

Post-sweep: fold winning peaks into ninfer/default.nix SHAPES row
(qwen3.8-27b-coder390), replacing the UNMEASURED bounds-only values, and
update the unit default if the champion differs from C6x65k.
