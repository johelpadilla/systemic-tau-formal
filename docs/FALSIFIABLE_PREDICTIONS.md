# Public list of falsifiable predictions

All items below are **`[EMPÍRICO]`** or **`[CONJETURA]`** unless marked otherwise.  
None of these are Lean theorems.

## P1 — Ontological ascent lead time

**Statement.** In any system that enters a genuine chaotic regime (`|τₛ| < 0.41` sustained), the RECD pipeline should produce an “ontological ascent” signal \(t^*\) **between 4 and 6 weeks** before an *observable* critical transition (domain-defined endpoint).

| Field | Value |
|-------|--------|
| Label | `[EMPÍRICO]` / domain-dependent |
| Precondition | Sustained chaotic band + multivariate ordinal observability |
| Failure mode | Systematic lead times outside 4–6 weeks, or no \(t^*\) before transition |
| Notes | Windowing and sampling rate must follow `EXPERIMENTAL_PROTOCOL.md` |

## P2 — Fractal dimension of the extramental clock

**Statement.** The fractal dimension of the extramental clock trajectory on low-dimensional chaotic attractors should approximate **≈ 1.98**.

| Field | Value |
|-------|--------|
| Label | `[CONJETURA]` + `[EMPÍRICO]` on synthetic attractors |
| Failure mode | Stable estimates far from ~1.98 under agreed embedding/estimators |
| Notes | Estimator and embedding must be pre-registered in the report |

## P3 — Threshold robustness under noise

**Statement.** Operational thresholds **0.50 / 0.41** remain usable (same qualitative regime classification) under additive Gaussian noise up to **20%** of signal scale, **without re-training**.

| Field | Value |
|-------|--------|
| Label | `[EMPÍRICO]` / robustness claim |
| Failure mode | Systematic regime flips or total loss of discrimination at ≤20% noise |
| Notes | Noise definition: see protocol § Noise |

## P4 — Anti-synchronization clock structure

**Statement.** In strongly anti-synchronized regimes (`τₛ ≤ −0.41`), RECD advances with an **interval structure distinct** from the synchronized stable regime (`τₛ ≥ 0.50`).

| Field | Value |
|-------|--------|
| Label | `[CONJETURA]` operationalized by gate \(g = −1\) vs \(g = +1\) |
| Failure mode | Identical Δt statistics (distribution of increments) across anti vs sync after controls |
| Notes | Compare increment histograms and run-length structure |

## How to report a falsification

Open a GitHub issue with label `contradiction`, attach:

1. Dataset description + license  
2. Preprocessing log (protocol checklist)  
3. Code hash / commit  
4. Figures of τₛ, g(τₛ), T_RECD, and claimed transition  
5. Which prediction (P1–P4) fails and by how much  

Use the issue template `.github/ISSUE_TEMPLATE/contradiction.yml`.
