# P1-EEG — CHB-MIT clinical seizure onset (serious protocol)

**Document ID:** `P1_EEG_CHBMIT`  
**Version:** 1.0.0 · **Date freeze target:** 2026-07-25  
**Claim class:** `[EMPÍRICO]` domain transfer (C3 neuro) with clinical `t_obs`  
**Software pin:** `systemic-tau-formal` (commit at pre-registration time)  
**Related:** [`EXPERIMENTAL_PROTOCOL.md`](EXPERIMENTAL_PROTOCOL.md) · [`FALSIFIABLE_PREDICTIONS.md`](FALSIFIABLE_PREDICTIONS.md) · [`CROSS_DOMAIN.md`](CROSS_DOMAIN.md) · [`CHALLENGES.md`](CHALLENGES.md)

---

## 0. What this is / is not

| This **is** | This **is not** |
|-------------|-----------------|
| Pre-registered early-warning test of τₛ/RECD against **clinically annotated seizure onset** | The original dengue P1 claim of **4–6 weeks** lead |
| Domain transfer **C3** with gold-standard `t_obs` | A replacement for Aedes field P1 |
| Machine-auditable: frozen params + SHA-256 of endpoints before scoring | Post-hoc threshold tuning after looking at leads |
| Optional C1 interictal false-alarm panel on the same corpus | Proof of clinical deployability |

**Forbidden collapse:** “EEG hit ⇒ dengue P1 proved.”  
**Allowed:** “EEG hit/miss under protocol v1.0 ⇒ evidence for/against ordinal early-warning on multichannel EEG features.”

---

## 1. Data source (cite always)

| Field | Value |
|-------|--------|
| Dataset | CHB-MIT Scalp EEG Database |
| Version | 1.0.0 |
| DOI | [10.13026/C2K01R](https://doi.org/10.13026/C2K01R) |
| PhysioNet | https://physionet.org/content/chbmit/1.0.0/ |
| License | Open Data Commons Attribution License v1.0 |
| Primary citation | Guttag, J. (2010). CHB-MIT Scalp EEG Database (version 1.0.0). *PhysioNet*. |
| Methods citation | Shoeb, A. (2009). Application of Machine Learning to Epileptic Seizure Onset Detection and Treatment. PhD Thesis, MIT. |
| Subjects | 22 pediatric (23 cases; chb21 = same subject as chb01 ~1.5 y later — **do not count as independent**) |
| Sampling | 256 Hz, typically 23 EEG channels (10–20) |
| Endpoints | Annotated seizure start/end (~182–198 seizures) in `chbNN-summary.txt` and `.seizure` files |

---

## 2. Frozen operational parameters (v1.0.0)

These are **`[OPERACIONAL]`** and **must not change** between pre-registration and first scored report without bumping protocol version.

| Parameter | Frozen value | Rationale |
|-----------|--------------|-----------|
| `fs_hz` | 256 | Dataset native |
| `epoch_s` | **1.0** | Coarse-grain to Kendall-feasible scale |
| `feature` | **`rms`** | Simple, rank-stable, fully specified |
| `channel_policy` | EEG 10–20 only; drop names in {`-`, empty} and non-EEG (ECG, VNS, …) | Avoid dummy / peripheral channels |
| `min_channels` | 8 | Below this → `precondition_fail` |
| `window_size` \(w\) | **13** | Same default as Systemic Tau reference |
| `stride` | 1 | Protocol default |
| `min_run` | **4** | Same as `first_sustained_chaos_ascent` |
| `theta_chaos` / `theta_stable` | **0.41 / 0.50** | Operational standard; no re-fit |
| `min_preictal_s` | **300** (5 min) | Enough history for \(w\) and sustained run |
| `lead_lo_s` | **30** | Early-warning, not instantaneous detection |
| `lead_hi_s` | **300** | 5 min pre-ictal horizon (domain-adapted; **not** weeks) |
| `eval_crop` | pre-ictal only up to `t_obs` (inclusive index of onset epoch) | No look-ahead into ictal samples for \(t^*\) |
| `t_star` definition | First sustained chaos-band run (\(\lvert\tau_s\rvert < 0.41\), length ≥ `min_run`) on aggregated series | Matches Aedes scorer logic |
| `C1_horizon_s` | **600** after a false alert | Interictal FP definition |
| `C1_gap_from_seizure_s` | **1800** (30 min) | Interictal windows must be far from any seizure |

**Lead units:** seconds on the epoch grid (`lead_s = (t_obs_epoch − t_star) * epoch_s`).  
**Pass:** `lead_lo_s ≤ lead_s ≤ lead_hi_s` and \(t^* < t_{\mathrm{obs}}\).

Sensitivity analyses (optional appendices) may vary `epoch_s` ∈ {1, 2}, `feature` ∈ {rms, bandpower_theta_beta}, or lead windows — **never** for primary v1.0 verdict without a new protocol id.

---

## 3. Aggregation (mandatory)

Raw multichannel EEG is **not** fed to Kendall at 256 Hz.

```text
EDF  →  (T_raw × N_ch) @ 256 Hz
     →  non-overlapping epochs of epoch_s
     →  per-channel RMS
     →  X_agg shape (T_epochs × N_ch)
     →  τₛ / gate / RECD / t*
```

For epoch \(k\) and channel \(j\):

\[
X_{k,j} = \sqrt{\frac{1}{L}\sum_{i=0}^{L-1} x_{kL+i,j}^{2}},\quad L = \lfloor f_s\cdot\mathrm{epoch\_s}\rfloor.
\]

Map clinical time to epoch index:

\[
t_{\mathrm{obs\_epoch}} = \lfloor t_{\mathrm{obs\_s}} / \mathrm{epoch\_s} \rfloor.
\]

---

## 4. Pre-registration workflow (mandatory for P1-EEG discharge)

1. **Install + pin software** (`git rev-parse HEAD`, package version).  
2. **Download** only the cases listed in the endpoints file (start: `chb01`).  
3. **Parse** `chbNN-summary.txt` → candidate seizures with `t_start_s`, `t_end_s`.  
4. **Filter** candidates with `t_start_s ≥ min_preictal_s` (and file long enough).  
5. **Write** `data/chbmit/endpoints.json` with every kept seizure,  
   `pre_registered: true`, full metadata, **before any τₛ scoring**.  
6. **Lock:** `python -m` / CLI `lock` → writes `protocol_lock.json` containing  
   SHA-256 of canonical endpoints JSON + frozen params + git commit.  
7. **Score only if** current endpoints hash matches lock (tool enforces).  
8. **Publish** table of verdicts + lock file + commit hash.

Refusals (honest):

| Condition | Tool behavior |
|-----------|----------------|
| `pre_registered` false | refuse score |
| endpoints hash ≠ lock | refuse score |
| `t_obs` null | not scored |
| preictal too short | `precondition_fail` |
| \(N < min_channels\) | `precondition_fail` |

---

## 5. Verdict taxonomy

| Code | Meaning |
|------|---------|
| `hit` | \(t^* < t_{\mathrm{obs}}\) and lead in \([lead\_lo\_s, lead\_hi\_s]\) |
| `miss_lead` | \(t^*\) exists before onset but lead outside window |
| `no_signal` | no sustained chaos run before onset |
| `post_onset_only` | only chaos runs at/after onset (detection ≠ prediction) |
| `precondition_fail` | insufficient preictal, channels, or load error |
| `lock_fail` | scoring blocked by integrity checks |

Primary success metric for protocol v1.0:  
**hit rate among seizures with status ≠ precondition_fail**, plus full table (no cherry-picking).

---

## 6. C1 companion (same corpus)

**Goal:** stress false early warnings on **interictal** EEG.

1. Build windows of length ≥ `min_preictal_s` with no seizure within `C1_gap_from_seizure_s`.  
2. Run identical aggregation + \(t^*\) detector.  
3. If an alert fires, require no seizure in the next `C1_horizon_s` → count **FP**.  
4. Report FP rate per hour of interictal analyzed.

C1 does **not** use the same rows as P1 hits; separate table.

---

## 7. Software map

| Path | Role |
|------|------|
| `python/core/chbmit_io.py` | Summary parse, channel filter, RMS aggregation, EDF load |
| `python/core/p1_eeg.py` | Lock, score, C1 panel, report dict |
| `data/chbmit/` | README, examples, local EDF (gitignored), lock/endpoints (local) |
| `notebooks/12_chbmit_p1_eeg.py` | CLI: `parse` / `lock` / `score` / `c1` / `report` |
| `python/tests/test_p1_eeg_chbmit.py` | Synthetic end-to-end (no 42 GB download in CI) |

Optional dependency group: `pip install -e ".[eeg]"` → `mne` (preferred) or `pyedflib`.

---

## 8. Download (start small)

Full corpus ≈ **42.6 GB**. Pilot:

```bash
mkdir -p data/chbmit/raw
# PhysioNet recursive (example: case chb01 only)
wget -r -N -c -np -P data/chbmit/raw \
  https://physionet.org/files/chbmit/1.0.0/chb01/

# or AWS open data
aws s3 sync --no-sign-request \
  s3://physionet-open/chbmit/1.0.0/chb01/ \
  data/chbmit/raw/chb01/
```

Place tree so summaries live at:

```text
data/chbmit/raw/chb01/chb01-summary.txt
data/chbmit/raw/chb01/chb01_03.edf
...
```

---

## 9. Report checklist (protocol §7 style)

1. Title: P1-EEG CHB-MIT protocol v1.0.0  
2. Data DOI + license + cases used  
3. Aggregation + frozen params (copy table §2)  
4. `protocol_lock.json` SHA + git commit  
5. Per-seizure table: record, `t_obs_s`, `t_star_s`, `lead_s`, verdict  
6. Aggregate: n_hit / n_scored / n_precondition_fail  
7. C1 FP rate (if run)  
8. Limitations (pediatric, medication withdrawal, montage changes, ordinal feature = RMS not raw field potentials)  
9. Explicit statement: **not** dengue P1 discharge  

---

## 10. Versioning

| Protocol version | Status | Change |
|------------------|--------|--------|
| `1.0.0` | **LOCKED + SCORED** (chb01) | Initial freeze: RMS @ 1 s; first chaos-band \(t^*\); lead 30–300 s; min preictal 300 s. EWS claim **not supported** — see [`P1_EEG_CHB01_PILOT_REPORT.md`](P1_EEG_CHB01_PILOT_REPORT.md). |
| `1.1.0` | **LOCKED + SCORED** (chb01) | log_bandpower_4_chmean @ 2 s; first **order** \(t^*\); G1–G4 before lock. EWS **FAIL** (0/7); gates PASS; C1 FP 0.643. Report: [`P1_EEG_CHB01_PILOT_REPORT_v1.1.md`](P1_EEG_CHB01_PILOT_REPORT_v1.1.md). |

Any change to frozen params ⇒ bump protocol version and new lock.  
**v1.0.0 must not be re-fit** from pilot leads; further EEG work uses **1.1.0+** only.

---

## 11. Commands (after data present)

```bash
cd python && pip install -e ".[dev,eeg]"

# From repo root:
python notebooks/12_chbmit_p1_eeg.py parse \
  --raw data/chbmit/raw --case chb01 \
  --out data/chbmit/endpoints_candidates.json

# Human review → copy to endpoints.json, set pre_registered true
python notebooks/12_chbmit_p1_eeg.py lock \
  --endpoints data/chbmit/endpoints.json \
  --lock data/chbmit/protocol_lock.json

python notebooks/12_chbmit_p1_eeg.py score \
  --endpoints data/chbmit/endpoints.json \
  --lock data/chbmit/protocol_lock.json \
  --raw data/chbmit/raw \
  --out data/chbmit/last_p1_eeg_score.json

python notebooks/12_chbmit_p1_eeg.py c1 \
  --raw data/chbmit/raw --case chb01 \
  --out data/chbmit/last_c1_eeg.json

python notebooks/12_chbmit_p1_eeg.py report \
  --score data/chbmit/last_p1_eeg_score.json \
  --c1 data/chbmit/last_c1_eeg.json
```

CI without PhysioNet data:

```bash
cd python && pytest -q tests/test_p1_eeg_chbmit.py
```
