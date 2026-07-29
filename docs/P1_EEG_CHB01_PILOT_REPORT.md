# P1-EEG pilot report — CHB-MIT `chb01` (locked)

**Document ID:** `P1_EEG_CHB01_PILOT`  
**Protocol:** [`P1_EEG_CHBMIT.md`](P1_EEG_CHBMIT.md) **v1.0.0**  
**Claim class:** `[EMPÍRICO]` domain transfer C3 neuro — **not** dengue P1 (weeks)  
**Date (lock/score):** 2026-07-27 (local)  
**Cohort:** PhysioNet CHB-MIT case **chb01** only (pilot)

---

## 0. Integrity (must pass before any science claim)

| Check | Value |
|-------|--------|
| Lock file | `data/chbmit/protocol_lock.json` |
| Endpoints file | `data/chbmit/endpoints.json` |
| `endpoints_sha256` | `181ff40e6bc4a7348ff335f134eb1e5398e1d288a63b1dbb17056aeb8aa7b160` |
| `lock_ok` at score | **true** |
| Git commit at lock | `731df8f5814e202484a8549f3c0363c754bab763` |
| `pre_registered` | **7 / 7** series |
| Dataset | CHB-MIT 1.0.0 · DOI [10.13026/C2K01R](https://doi.org/10.13026/C2K01R) |
| Aggregation | RMS · epoch 1 s · EEG channels only · \(w=13\), min_run=4, θ 0.41/0.50 |
| Lead window (frozen) | **[30, 300] s** |
| Score artifact | `data/chbmit/last_p1_eeg_score.json` |
| C1 artifact | `data/chbmit/last_c1_eeg.json` |

**Pre-registration discipline:** candidates parsed from `chb01-summary.txt` only;  
all seven annotated seizures with \(t_{\mathrm{obs}} \ge 300\,\mathrm{s}\) locked **before** τₛ scoring.  
No threshold re-fit after looking at leads.

---

## 1. Primary P1-EEG result (chb01)

| Metric | Value |
|--------|-------|
| \(n\) scored | 7 |
| \(n\) precondition_fail | 0 |
| \(n\) hit | **1** |
| \(n\) miss_lead | **6** |
| \(n\) no_signal | 0 |
| **Hit rate** (among scored) | **1/7 ≈ 0.143** |

### Per-seizure table

| record | \(t_{\mathrm{obs}}\) (s) | \(t^*\) (s) | lead (s) | verdict |
|--------|--------------------------|-------------|----------|---------|
| chb01_03 | 2996 | 12 | 2984 | miss_lead |
| chb01_04 | 1467 | 12 | 1455 | miss_lead |
| chb01_15 | 1732 | 12 | 1720 | miss_lead |
| chb01_16 | 1015 | 12 | 1003 | miss_lead |
| chb01_18 | 1720 | 12 | 1708 | miss_lead |
| chb01_21 | 327 | 35 | **292** | **hit** |
| chb01_26 | 1862 | 12 | 1850 | miss_lead |

**Pattern:** On 6/7 records the first sustained chaos-band run occurs at the **earliest feasible** index after the Kendall window (\(t^*\approx 12\,\mathrm{s}\) for \(w=13\)), so lead \(\gg 300\,\mathrm{s}\).  
Only **chb01_21** lands inside the frozen pre-ictal horizon (lead 292 s ∈ [30, 300]).

---

## 2. C1 interictal false-alarm panel (same frozen detector)

| Metric | Value |
|--------|-------|
| Files scanned (interictal-capable) | 7 |
| Windows total | 42 |
| Alerts | 42 |
| False positives | **42** |
| FP rate / window | **1.0** |

**Interpretation:** Under protocol v1.0.0 parameters transferred from the Systemic Tau operational default, the RMS@1s multichannel τₛ detector is **almost always in the chaos band** on this EEG featureization — both long before seizures and on pure interictal windows. Specificity is effectively **zero** on this pilot panel.

---

## 3. Honest scientific reading

| Statement | Status |
|-----------|--------|
| Pipeline integrity (parse → pre-reg → lock → score → C1) | **PASS** |
| Protocol v1.0.0 frozen params produce early-warning hits in [30, 300] s on chb01 | **WEAK / FAIL** (1/7) |
| Acceptable C1 specificity on chb01 interictal | **FAIL** (42/42 FP) |
| Dengue / Aedes P1 (4–6 weeks) discharged | **NO** — orthogonal track |
| Clinical deployability claimed | **NO** |

**Allowed claim:**  
“Under P1-EEG v1.0.0, first locked pilot on chb01 yields hit rate 1/7 and C1 FP rate 1.0. Default operational thresholds + epoch-RMS features are **not** validated as a seizure early-warning system on this cohort.”

**Forbidden claim:**  
“EEG hit ⇒ Systemic Tau / dengue P1 proved.” There is no such collapse.

### Likely mechanism (hypothesis, not protocol change)

Epoch-RMS over 23 bipolar channels at 1 s produces a high-dimensional ordinal matrix whose windowed Kendall τₛ sits near zero for long stretches (chaos band by definition \(|\tau_s|<0.41\)). The **first** sustained run therefore fires as soon as \(w+\mathrm{min\_run}\) samples exist — i.e. ~12 s into almost every file. That is a **feature/scale mismatch**, not a software bug (lock hash held; synthetic CI green).

**Protocol law:** fixing this requires a **new protocol id/version** (e.g. different feature, bandpower, longer epoch, last-run-before-onset, or re-tuned θ) with a **new** pre-registration — not silent re-fit of v1.0.0 after seeing these numbers.

---

## 4. Reproducibility

```bash
# Data (1.6 GiB) — already under data/chbmit/raw/chb01/
aws s3 sync --no-sign-request \
  s3://physionet-open/chbmit/1.0.0/chb01/ data/chbmit/raw/chb01/

cd python && pip install -e ".[dev,eeg]" && cd ..

# Do NOT re-lock if endpoints.json unchanged — verify hash only
python notebooks/12_chbmit_p1_eeg.py score \
  --endpoints data/chbmit/endpoints.json \
  --lock data/chbmit/protocol_lock.json \
  --raw data/chbmit/raw \
  --out data/chbmit/last_p1_eeg_score.json

python notebooks/12_chbmit_p1_eeg.py c1 \
  --raw data/chbmit/raw --case chb01 \
  --out data/chbmit/last_c1_eeg.json

python notebooks/12_chbmit_p1_eeg.py report \
  --score data/chbmit/last_p1_eeg_score.json
```

### Citations

- Guttag, J. (2010). CHB-MIT Scalp EEG Database (version 1.0.0). *PhysioNet*. https://doi.org/10.13026/C2K01R  
- Shoeb, A. (2009). PhD Thesis, MIT.  
- Pollard et al., PhysioNet platform citation as required by PhysioNet.

---

## 5. Next steps (ordered)

1. **Keep v1.0.0 frozen** as the historical first locked pilot (this report). **Do not re-fit.**  
2. **v1.1.0 design freeze done:** [`P1_EEG_CHBMIT_v1.1.md`](P1_EEG_CHBMIT_v1.1.md) — log-bandpower 4 @ 2 s; first **order**-band \(t^*\); precondition G1–G4; artifacts `data/chbmit/v1.1/`. **Not scored yet.**  
3. Implement v1.1 code path → run precondition diagnostic → lock only if G1–G4 pass → score once.  
4. Optional multi-case extension (chb02…) only under a pre-specified case list **before** scoring.  
5. Aedes/dengue P1 remains open and **independent**.

---

*End of pilot report. Raw JSON artifacts are local/gitignored; this document is the citable narrative summary.*
