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
| Ops | Synthetic: `python/tests/test_p4_anti_sync.py`. Field scan: `notebooks/09_aedes_p4_field.py` + `core.p4_field_scan`. 2018 SJU1–3 multi-trap matrices are **co-moving** (positive mean pairwise corr) → status `no_strong_anti_regime` (premise not met; not a silent “pass”). True field discharge needs windows with `τₛ ≤ −0.41` mass. |

## P1-Aedes (field multi-trap; external clinical endpoint)

**Statement.** Under protocol [`P1_AEDES_EXTERNAL_TOBS.md`](P1_AEDES_EXTERNAL_TOBS.md) v1.0.0, on committed multi-trap Aedes matrices (`data/aedes/raw/`), the RECD/τₛ pipeline produces a sustained chaos-band ascent signal \(t^*\) with lead \(\mathrm{lead}=t_{\mathrm{obs}}-t^*\) in **[4, 6] weeks** before an **external** domain transition (clinical dengue week or documented intervention), mapped via `calendar_map.json`.

| Field | Value |
|-------|--------|
| Label | `[EMPÍRICO]` dengue / vector residual (paradigm P1) |
| Endpoint | External weekly clinical / intervention only — **not** trap-surge |
| Precondition | `pre_registered` + protocol lock SHA-256; external incidence under `data/aedes/external/` |
| Failure mode | Systematic `miss_lead` / `no_signal` under frozen \(w=13\), \(\theta=0.41\), min_run=4 |
| Ops | `notebooks/14_aedes_p1_external.py`; status: tooling ready; **2018 cases intake open** |
| Note | DengAI San Juan incidence ends ~2013; 2018 traps require separate clinical series |

## P1-EEG (domain transfer; clinical endpoint) — track paused

**Statement.** Under protocol [`P1_EEG_CHBMIT.md`](P1_EEG_CHBMIT.md) v1.0.0, on CHB-MIT scalp EEG aggregated to 1 s RMS per channel, the RECD/τₛ pipeline produces a sustained chaos-band ascent signal \(t^*\) with lead \(\mathrm{lead}=t_{\mathrm{obs}}-t^*\) in **[30, 300] seconds** before **clinically annotated seizure onset** (`t_obs` from PhysioNet summaries), for seizures with ≥300 s pre-ictal history in-file.

| Field | Value |
|-------|--------|
| Label | `[EMPÍRICO]` C3 neuro (not dengue P1 weeks) |
| Endpoint | CHB-MIT seizure start (DOI [10.13026/C2K01R](https://doi.org/10.13026/C2K01R)) |
| Precondition | `pre_registered` + protocol lock SHA-256; ≥8 EEG channels; min preictal 300 s |
| Failure mode | Systematic `miss_lead` / `no_signal` / high C1 interictal FP rate under frozen params |
| Ops | `notebooks/12_chbmit_p1_eeg.py`; **track paused 2026-07-29** after v1.0/v1.1 fails |

## How to report a falsification

Open a GitHub issue with label `contradiction`, attach:

1. Dataset description + license  
2. Preprocessing log (protocol checklist)  
3. Code hash / commit  
4. Figures of τₛ, g(τₛ), T_RECD, and claimed transition  
5. Which prediction (P1–P4) fails and by how much  

Use the issue template `.github/ISSUE_TEMPLATE/contradiction.yml`.
