# Contributing

Thank you for stress-testing Systemic Tau / RECD.

## Ground rules

1. Use epistemic labels (`[TEOREMA]`, `[CONJETURA]`, …) — see `docs/EPISTEMIC_LABELS.md`.
2. Do not claim a Lean theorem is proved if it still has `sorry`.
3. Empirical reports follow `docs/EXPERIMENTAL_PROTOCOL.md`.

## Local checks

```bash
export PATH="$HOME/.elan/bin:$PATH"
cd lean && lake build
cd ../python && pip install -e ".[dev]" && pytest -q
```

## Issues

| Label | Use for |
|-------|---------|
| `contradiction` | Failed prediction / internal clash |
| `improvement` | Clearer proofs, docs, API |
| `new-domain` | Domain transfer experiments |
| `philosophy-challenge` | Ontology / Polo / trilemma critique |
| `workshop` | Stress-Test 2026 logistics / track reports |
| `open-goal` | Tracked formal open problem |

Templates: `.github/ISSUE_TEMPLATE/`.  
Board map: `docs/ISSUE_BOARD.md`.  
Workshop brief: `docs/WORKSHOP_STRESS_TEST_2026.md`.

## Pull requests

- Keep formal vs empirical changes separable when possible.
- Update `STATUS.md` if you discharge a `sorry` or add a lemma.
- Regenerate golden fixture if constants change:

```bash
cd python && python scripts/export_golden.py
```
