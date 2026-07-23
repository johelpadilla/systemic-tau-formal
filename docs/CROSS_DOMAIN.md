# Cross-domain track (C3) — starter kits

**Label:** synthetic demos here are `[OPERACIONAL]`.  
Field / market / clinical / SCADA results are `[EMPÍRICO]` only with license + protocol.

## Purpose

Lower the cost of attempting **challenge C3** (domain transfer) without pretending that synthetic panels *are* those domains.

| Generator | Module | Synthetic story | Known break |
|-----------|--------|-----------------|-------------|
| Multi-asset returns | `finance_like_returns` | Factor model correlation break | `t_break` |
| Multi-channel oscillators | `eeg_like_channels` | Phase-locked → independent | `t_desync` |
| Nodal load proxies | `grid_like_loads` | Common diurnal + asymmetric shock | `t_event` |

Code: `python/core/synthetic.py`  
Summary helper: `python/core/report.py` (`pipeline_report`)  
CLI: `notebooks/06_cross_domain_c3.py`

## How to run

```bash
cd python && pip install -e ".[dev]" && pytest -q tests/test_cross_domain.py
cd .. && python notebooks/06_cross_domain_c3.py
```

## What counts as a real C3 hit

Not this starter kit alone. A hit requires:

1. Real domain data with **license** and citation  
2. Pre-registered endpoint (protocol)  
3. Report per `EXPERIMENTAL_PROTOCOL.md` §7  
4. Explicit **confirm or refute** of P1–P4 / operational ontology  
5. GitHub issue label `new-domain` (tracking: issue #4)

## Related

- Challenge text: [`CHALLENGES.md`](CHALLENGES.md)  
- Workshop tracks: [`WORKSHOP_STRESS_TEST_2026.md`](WORKSHOP_STRESS_TEST_2026.md)  
- Falsifiable list: [`FALSIFIABLE_PREDICTIONS.md`](FALSIFIABLE_PREDICTIONS.md)
