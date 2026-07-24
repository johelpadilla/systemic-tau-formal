# Field / multi-site empirical status (critical path)

Epistemic labels: [`EPISTEMIC_LABELS.md`](EPISTEMIC_LABELS.md).  
Falsifiable list: [`FALSIFIABLE_PREDICTIONS.md`](FALSIFIABLE_PREDICTIONS.md).

This track is the **paradigm-critical** residual: observational τₛ return and
multi-site lead characterization on real trap matrices — **not** Lean Feigenbaum
discharge.

## What is closed (machine-checked ops + field data)

| Package | Class | Status |
|---------|-------|--------|
| `data/aedes/raw/` SJU1/2/3 2018 | `[EMPÍRICO]` | 3 multi-trap matrices + `manifest.json` |
| Recursive multi-year loader | `[OPERACIONAL]` | `raw/**/*.csv` → keys `YYYY_Site` |
| P3 noise @ ρ≤0.20 on field | `[EMPÍRICO]` scan | nb 08 + board; usable band agreement |
| P4 structure scan | `[EMPÍRICO]` | nb 09; 2018 SJU → `no_strong_anti_regime` (premise) |
| **Field return multi-site** | `[EMPÍRICO]` diagnostic | `core.field_return` + nb **11** |
| **Exploratory trap-surge leads** | `[EMPÍRICO]` characterization | `exploratory_lead_scan` — **not** P1 discharge |
| Unified board v2 | `[OPERACIONAL]` aggregate | `build_empirical_board` includes field_return + p1_exploratory |

## Field return construction (honest)

From each multi-trap matrix \(X\in\mathbb{R}^{T\times N}\):

1. Compute global τₛ (Kendall windows, protocol `window_size=13`).
2. **Chaos-band runs:** maximal intervals with \(\lvert\tau_s\rvert < 0.41\) and length ≥ `min_run`.
3. **Coherence-run return map:** phase proxies
   \(s_{\mathrm{exit}}=(L-1)/(L+5)\), \(s_{\mathrm{next}}=G/(G+5)\) between successive runs
   (same idea as thesis return-map scripts).
4. **Local-max first-return** on the τₛ series (combinatorial skeleton shared with Lean lab).
5. Binned mean curve + coarse `single_peak_like` flag (exploratory shape only).
6. Run-length ratio median as **δ proxy** — **not** classical Feigenbaum δ from superstable \(R_n\).

**Does not claim:** continuum strong unimodality, identification with logistic/tent lab maps,
or Mathlib renorm fixed point.

## P1 honesty split

| Path | File / API | Pre-registered? | Counts as P1 discharge? |
|------|------------|-----------------|-------------------------|
| Scaffold | `endpoints.example.json` | no | no |
| True P1 | `endpoints.json` + `pre_registered:true` + domain `t_obs` | **yes** | **yes** (scored) |
| Exploratory | `trap_surge_t_obs` / `exploratory_lead_scan` | **always false** | **never** |

Trap-surge endpoints (`max_total`, `first_q90`) are derived from the **same** matrix
as τₛ. Useful for multi-site lead *distribution* under an explicit observational
endpoint; **not** clinical outbreak dates and **not** pre-registration.

## Commands

```bash
python notebooks/11_aedes_field_return.py
python notebooks/11_aedes_field_return.py --json data/aedes/raw/last_field_return.json
python notebooks/10_aedes_empirical_board.py
cd python && pytest -q tests/test_field_return.py tests/test_empirical_board.py tests/test_p1_endpoints.py
```

## Still open (paradigm-critical residual)

| Item | Blocker | Next step |
|------|---------|-----------|
| True P1 multi-site | External domain dates (outbreak / clinical / vector control) | Fill `endpoints.json` with `pre_registered:true` *before* looking at τ* leads |
| Multi-year / multi-municipality raw | Licensed intake | Drop CSVs under `raw/YYYY/` + update `manifest.json` |
| Field P4 discharge | Windows with mass \(\tau_s\le -0.41\) | More sites / seasons with anti-sync structure |
| Field ↛ lab map theorem | Research-scale | Keep diagnostic board; do not overclaim |

## Relation to Lean

Lean `tauReturnFour` / logistic packages remain **laboratory constructions**.
This track supplies the **observational dual** required by the paradigm claim
“ordinal observability on real systems,” without closing classical Feigenbaum
universality.

Last updated: 2026-07-24 (field return multi-site + exploratory leads pack).
