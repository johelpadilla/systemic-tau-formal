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

## P1-EEG clinical transfer (parallel track)

Not Aedes, but paradigm-critical for **clean `t_obs`**: CHB-MIT seizure onset.

| Item | Status |
|------|--------|
| Protocol v1.0.0 | [`P1_EEG_CHBMIT.md`](P1_EEG_CHBMIT.md) — **immutable history** |
| Code + lock + C1 (v1.0.0) | `chbmit_io` / `p1_eeg` / nb 12 |
| CI synthetic (v1.0.0) | `tests/test_p1_eeg_chbmit.py` |
| **chb01 locked pilot v1.0.0** | **DONE 2026-07-27** — [`P1_EEG_CHB01_PILOT_REPORT.md`](P1_EEG_CHB01_PILOT_REPORT.md) |
| P1 hit rate (chb01, v1.0.0) | **1/7 ≈ 0.143** (6× miss_lead, 0× no_signal) |
| C1 FP (chb01, v1.0.0) | **42/42** (rate 1.0) — specificity fail |
| Lock SHA-256 (v1.0.0) | `181ff40e6bc4a7348ff335f134eb1e5398e1d288a63b1dbb17056aeb8aa7b160` |
| **Protocol v1.1.0** | **LOCKED + scored** — [`P1_EEG_CHBMIT_v1.1.md`](P1_EEG_CHBMIT_v1.1.md) · report [`P1_EEG_CHB01_PILOT_REPORT_v1.1.md`](P1_EEG_CHB01_PILOT_REPORT_v1.1.md) |
| v1.1 package | log_bandpower_4_chmean @ 2 s; order polarity; G1–G4; tree `data/chbmit/v1.1/` |
| P1 hit rate (chb01, v1.1.0) | **0/7** (7× miss_lead; 0× no_signal) |
| C1 FP (chb01, v1.1.0) | **27/42 ≈ 0.643** |
| Precondition G1–G4 | **PASS** (chaos 0.624, order 0.115, n=42) |
| Lock SHA (endpoints, v1.1) | `e4fa3c2902a1e729a8cdaa12966b16b49b724612a7a64c4c471c261e4e266ae8` |

**Honest verdict (v1.0.0):** integrity PASS; EWS not supported (ambient chaos).  
**Honest verdict (v1.1.0):** integrity + precondition **PASS**; EWS **FAIL** (0/7) — order runs exist but first order \(t^*\) lacks lead-window timing. C1 better than v1.0 (0.64 vs 1.0) but still weak. Does **not** discharge dengue P1.

**EEG track PAUSED (2026-07-29).**

## P1-Aedes external clinical (Vitória unlock)

| Item | Status |
|------|--------|
| Protocol | [`P1_AEDES_EXTERNAL_TOBS.md`](P1_AEDES_EXTERNAL_TOBS.md) v1.0.0 |
| San Juan 2018 clinical | **null** (near-zero dengue year) |
| Vitória top-15 yearly peak | **0/5 hits** — [`P1_AEDES_VITORIA_REPORT.md`](P1_AEDES_VITORIA_REPORT.md) |
| Data | `data/aedes/field_vitoria/` |

## P1-ILI HHS → FluSurv (2026-07-29)

| Item | Status |
|------|--------|
| Protocol | [`P1_ILI_EXTERNAL_TOBS.md`](P1_ILI_EXTERNAL_TOBS.md) v1.0.0 |
| Channels | HHS1–10 ILINet %wILI, seasons 2010–11…2019–20 |
| \(t_{\mathrm{obs}}\) | FluSurv `network_all` `rate_overall` (not national ILI) |
| peak_week | **0/10 hits** (mostly `no_signal`) |
| first_exceed_season_p75 | **1/10 hits** |
| Report | [`P1_ILI_REPORT.md`](P1_ILI_REPORT.md) |
| Code / CLI | `core.p1_ili` · `core.ili_io` · nb **15** |

**Honest verdict:** integrity PASS; primary EWS claim **not supported**. Dominant failure = no sustained chaos-band run on HHS panel under frozen \(\theta=0.41\), \(w=13\).

**Program decision (2026-07-29):** EEG is **not convenient** as the primary paradigm / EWS testbed. Track **paused** (pilots archived, code retained). Residual empirical priority returns to **Aedes with external \(t_{\mathrm{obs}}\)**, where regime-contrast preconditions better match the Tau scorer family.

**Program synthesis (2026-07-28):** multi-domain empirical residuals + synthetic instrument PASS + C1 ambient FAIL are closed as one honest composite in [`P1_FAIL_TRIPTYCH.md`](P1_FAIL_TRIPTYCH.md). Same-param field expansion is low value; optional C1 guard is design-only in [`P1_C1_GUARD_DESIGN.md`](P1_C1_GUARD_DESIGN.md).

## P1-Aedes external \(t_{\mathrm{obs}}\) (priority residual)

| Item | Status |
|------|--------|
| Protocol v1.0.0 | [`P1_AEDES_EXTERNAL_TOBS.md`](P1_AEDES_EXTERNAL_TOBS.md) — **DESIGN FREEZE** |
| Calendar map SJU1–3 | `data/aedes/raw/calendar_map.json` |
| Propose / lock / score | `python/core/p1_aedes.py` · `notebooks/14_aedes_p1_external.py` |
| External incidence intake | `data/aedes/external/` (example only until 2018 cases land) |
| True multi-site score | **Blocked** on 2018 San Juan / PR **weekly clinical** (or intervention) series — DengAI ends ~2013 |

```bash
python notebooks/14_aedes_p1_external.py status
python notebooks/14_aedes_p1_external.py calendar
# after dropping incidence CSV:
python notebooks/14_aedes_p1_external.py propose --incidence data/aedes/external/YOUR.csv --method peak_week
```

## Still open (paradigm-critical residual)

| Item | Blocker | Next step |
|------|---------|-----------|
| True P1 multi-site (Aedes) | **2018 weekly dengue / intervention dates** (external) | Drop CSV under `data/aedes/external/` → propose → human `pre_registered:true` → lock → score |
| P1-EEG beyond v1.1 | **Paused** — not convenient for paradigm EWS | Reopen only with explicit new design freeze |
| Multi-year / multi-municipality raw | Licensed intake | Drop CSVs under `raw/YYYY/` + update `manifest.json` |
| Field P4 discharge | Windows with mass \(\tau_s\le -0.41\) | More sites / seasons with anti-sync structure |
| Field ↛ lab map theorem | Research-scale | Keep diagnostic board; do not overclaim |

## Relation to Lean

Lean `tauReturnFour` / logistic packages remain **laboratory constructions**.
This track supplies the **observational dual** required by the paradigm claim
“ordinal observability on real systems,” without closing classical Feigenbaum
universality.

Last updated: 2026-07-29 (P1-Aedes v1.0.0 protocol + calendar + CLI; EEG paused; 2018 cases intake open).
