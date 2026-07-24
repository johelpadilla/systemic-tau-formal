# Public issue board (scrutiny map)

Use GitHub issues as the board of record. This file is the static map.

**Live board:** https://github.com/johelpadilla/systemic-tau-formal/issues

### Seeded tracking issues (v0.1.5 era)

| # | Title |
|---|--------|
| [#1](https://github.com/johelpadilla/systemic-tau-formal/issues/1) | Workshop invitation |
| [#2](https://github.com/johelpadilla/systemic-tau-formal/issues/2) | C1 false early warnings |
| [#3](https://github.com/johelpadilla/systemic-tau-formal/issues/3) | C2 new math |
| [#4](https://github.com/johelpadilla/systemic-tau-formal/issues/4) | C3 domain transfer |
| [#5](https://github.com/johelpadilla/systemic-tau-formal/issues/5) | Feigenbaum open goals 1–3 |
| [#6](https://github.com/johelpadilla/systemic-tau-formal/issues/6) | Philosophy / Baron’s trilemma |
| [#7](https://github.com/johelpadilla/systemic-tau-formal/issues/7) | good first: more f(δ) disequalities |
| [#8](https://github.com/johelpadilla/systemic-tau-formal/issues/8) | good first: plot first-return pairs |

## Labels

| Label | Color intent | Meaning |
|-------|--------------|---------|
| `contradiction` | red | Failed P1–P4 or internal clash with evidence |
| `improvement` | blue | Docs, API, Lean lemmas, clearer honesty |
| `new-domain` | green | Domain transfer (finance, EEG, grids, …) |
| `philosophy-challenge` | purple | Ontology / trilemma / Polo critique |
| `workshop` | yellow | Stress-Test 2026 logistics & track reports |
| `open-goal` | gray | Tracked formal open problem (not yet discharged) |
| `good first issue` | light | Small, well-scoped entry tasks |

## Challenge index (C1–C3)

| ID | Title | Open issue theme | Docs |
|----|-------|------------------|------|
| C1 | Systematic false early warnings | `new-domain` / `contradiction` | [`CHALLENGES.md`](CHALLENGES.md) |
| C2 | New mathematical relation | `improvement` | [`CHALLENGES.md`](CHALLENGES.md) |
| C3 | Domain transfer | `new-domain` | [`CHALLENGES.md`](CHALLENGES.md) + protocol |
| Φ | Baron’s trilemma critique | `philosophy-challenge` | [`ONTOLOGY_BRIDGE.md`](ONTOLOGY_BRIDGE.md) |

## Falsifiable predictions (P1–P4)

Report failures with template **Contradiction / falsification**.  
List: [`FALSIFIABLE_PREDICTIONS.md`](FALSIFIABLE_PREDICTIONS.md).

## Formal Feigenbaum track (lab / construction vs research)

| Goal | Lean name | Status on `main` |
|------|-----------|------------------|
| 1a | `exists_realizer_of_functional` | **proved** (bookkeeping) |
| 1b | `open_ordinal_induces_continuum_return` | **construction** (`lookupTent`) — not field dynamics |
| 2a | `goal_2a_quadratic_of_strong` | **proved** |
| 2 | `open_return_strongly_unimodal` | **lab construction** (tent continuum) |
| 2τ | `open_return_strongly_unimodal_tau` | **lab construction** (non-tent `tauReturnFour`) |
| 3 pkg | `open_analytic_feigenbaum` | **refined package** (band + quadratic; not Mathlib renorm) |
| 3 C² / L-ID | `FeigenbaumUniversalC2`, logistic scale-ID | **algebra + scale identification** |
| Composite skeleton | `coherence_return_map_feigenbaum_of` | **proved** (if continuum+strong+U granted) |
| Composite from H | `coherence_return_map_feigenbaum` | **lab package** (default non-tent ★) |

**Still research-scale (not “open sorry”):** termwise superstable roots; Mathlib C²-open renorm; field-derived τₛ return.

Status narrative: [`FEIGENBAUM_STATUS.md`](FEIGENBAUM_STATUS.md) ·  
Single-page map: [`FORMAL_OBLIGATIONS.md`](FORMAL_OBLIGATIONS.md) ·  
Constructions: [`FEIGENBAUM_AXIOMS.md`](FEIGENBAUM_AXIOMS.md).  
Live GitHub issue #5 may lag this table — prefer docs on `main`.

## Workshop

Brief: [`WORKSHOP_STRESS_TEST_2026.md`](WORKSHOP_STRESS_TEST_2026.md).  
Label workshop posts `workshop`.

## How to open a high-quality issue

1. Choose the right **template** (`.github/ISSUE_TEMPLATE/`).  
2. Attach **commit hash** and software versions.  
3. Keep epistemic labels honest — do not mark synthetic demos as field validation.  
4. For empirical work, complete protocol §7 checklist.
