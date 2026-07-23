# Open challenge problems

These are invitations to break, extend, or transfer the framework.  
Label issues: `new-domain`, `improvement`, `contradiction`, or `philosophy-challenge`.

**Stress-Test 2026:** [`WORKSHOP_STRESS_TEST_2026.md`](WORKSHOP_STRESS_TEST_2026.md) · board map: [`ISSUE_BOARD.md`](ISSUE_BOARD.md)

## C1 — Systematic false early warnings

**Find** a dynamical system (deterministic or stochastic) where τₛ produces **systematic false-positive** early-warning signals (alerts without subsequent critical transition under a pre-agreed endpoint definition).

Success criterion: reproducible pipeline + public data/code + clear baseline comparison.

## C2 — New mathematical relation

**Derive** a new mathematical result linking τₛ (or RECD increments) to another complexity measure **not** already stated in the current papers (e.g. transfer entropy bounds, RQA invariants, Lyapunov proxies, TDA summaries).

Success criterion: proof sketch or formal statement + numerical check; PR against `papers/` or Lean module.

## C3 — Domain transfer

**Apply** RECD to a fully different domain (high-frequency markets, EEG, artificial neural networks, power grids, …) and **publish whether it confirms or refutes** the operational ontology.

Success criterion: follows `EXPERIMENTAL_PROTOCOL.md`; reports both positive and negative findings.

**Synthetic starters (not hits):** [`CROSS_DOMAIN.md`](CROSS_DOMAIN.md) · `notebooks/06_cross_domain_c3.py` · tracking issue [#4](https://github.com/johelpadilla/systemic-tau-formal/issues/4).

## Philosophy challenge (optional track)

Critique the 4-level architecture’s claim to avoid Baron’s Trilemma (infinite regress / circularity / dogmatism) without collapsing into one of the three horns. Label: `philosophy-challenge`.
