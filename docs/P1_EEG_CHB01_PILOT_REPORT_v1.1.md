# P1-EEG pilot report v1.1.0 — CHB-MIT `chb01` (locked)

**Document ID:** `P1_EEG_CHB01_PILOT_v1.1`  
**Protocol:** [`P1_EEG_CHBMIT_v1.1.md`](P1_EEG_CHBMIT_v1.1.md) **v1.1.0**  
**Claim class:** `[EMPÍRICO]` domain transfer C3 neuro — **not** dengue P1  
**Date (precondition / lock / score):** 2026-07-29  
**Cohort:** PhysioNet CHB-MIT case **chb01** only  
**Historical v1.0.0 (immutable FAIL EWS):** [`P1_EEG_CHB01_PILOT_REPORT.md`](P1_EEG_CHB01_PILOT_REPORT.md)

---

## 0. Integrity (must pass before any science claim)

| Check | Value |
|-------|--------|
| Design freeze | [`P1_EEG_CHBMIT_v1.1.md`](P1_EEG_CHBMIT_v1.1.md) |
| Artifact tree | `data/chbmit/v1.1/` |
| Precondition diagnostic | `precondition_diagnostic.json` |
| Gates G1–G4 | **all_pass = true** |
| mean chaos occupancy (interictal) | **0.624** (≤ 0.90) |
| mean order occupancy (interictal) | **0.115** (∈ [0.02, 0.95]) |
| n diagnostic windows | **42** |
| Endpoints | `endpoints.json` (7 pre-registered) |
| `endpoints_sha256` | `e4fa3c2902a1e729a8cdaa12966b16b49b724612a7a64c4c471c261e4e266ae8` |
| `precondition_diagnostic_sha256` | `dd30a326a434ac7f0e507dde08f6dc2b755a848fb703f3435ad99d5d4bcce892` |
| Lock | `protocol_lock.json` |
| Git commit at lock | `731df8f5814e202484a8549f3c0363c754bab763` |
| Aggregation | **log_bandpower_4_chmean** · epoch **2 s** · 4 bands · chmean collapse |
| \(t^*\) polarity | **first sustained order-band run** (\(\lvert\tau\rvert \ge 0.50\), min_run=4) |
| \(w\) / θ | 13 / 0.41 / 0.50 (paradigm defaults; not EEG-refit) |
| Lead window | **[30, 300] s** |
| Score artifact | `last_p1_eeg_score.json` |
| C1 artifact | `last_c1_eeg.json` |

**Discipline:** precondition on **interictal occupancy only** before lock; clinical \(t_{\mathrm{obs}}\) from summary; **no** use of v1.0.0 scores for parameter choice.

**Feature-layout note (§3.0 of freeze):** full \(4\cdot N_{\mathrm{ch}}\) columns rejected a priori as pairwise-Kendall-infeasible; primary scorer uses per-channel mean of 4 log-bandpowers (\(N=N_{\mathrm{ch}}\)).

---

## 1. Primary P1-EEG result (chb01, v1.1.0)

| Metric | Value |
|--------|-------|
| \(n\) scored | 7 |
| \(n\) precondition_fail | 0 |
| \(n\) hit | **0** |
| \(n\) miss_lead | **7** |
| \(n\) no_signal | 0 |
| **Hit rate** (among scored) | **0/7 = 0.0** |

### Per-seizure table

| record | \(t_{\mathrm{obs}}\) (s) | \(t^*\) (s) | lead (s) | preictal order_occ | preictal chaos_occ | verdict |
|--------|--------------------------|-------------|----------|--------------------|--------------------|---------|
| chb01_03 | 2996 | 44 | 2952 | 0.071 | 0.719 | miss_lead |
| chb01_04 | 1466 | 428 | 1038 | 0.235 | 0.493 | miss_lead |
| chb01_15 | 1732 | 1356 | 376 | 0.018 | 0.726 | miss_lead |
| chb01_16 | 1014 | 344 | 670 | 0.242 | 0.385 | miss_lead |
| chb01_18 | 1720 | 110 | 1610 | 0.252 | 0.353 | miss_lead |
| chb01_21 | 326 | 24 | **302** | 0.375 | 0.191 | miss_lead |
| chb01_26 | 1862 | 206 | 1656 | 0.255 | 0.416 | miss_lead |

**Pattern:** Order-band runs **exist** (0× `no_signal`) — unlike v1.0.0’s ambient-chaos floor at \(t^*\approx 12\,\mathrm{s}\) on RMS.  
The **first** sustained order run is almost always **too early** (lead \(> 300\,\mathrm{s}\)). Closest: chb01_21 lead **302 s** (just outside frozen upper bound 300 s).

---

## 2. C1 interictal false-alarm panel (order polarity)

| Metric | Value |
|--------|--------|
| Detector | first sustained **order** run (same as P1) |
| Files scanned | 7 |
| Windows total | 42 |
| Alerts | 27 |
| False positives | **27** |
| FP rate / window | **0.643** |

**vs v1.0.0:** C1 FP rate fell from **1.0** (chaos polarity / RMS) to **0.643** (order / bandpower). Specificity improved but remains poor for clinical early-warning.

---

## 3. Honest scientific reading

| Statement | Status |
|-----------|--------|
| Pipeline integrity (precondition → pre-reg → lock → score) | **PASS** |
| Precondition G1–G4 (non-ambient feature) | **PASS** |
| Early-warning hits in [30, 300] s under v1.1.0 | **FAIL** (0/7) |
| Order polarity fires at all pre-ictally | **YES** (7/7 have \(t^*\)) |
| Dengue / Aedes P1 discharged | **NO** |
| Clinical deployability | **NO** |
| Silent re-fit of v1.0.0 | **NO** (new protocol + tree) |

### Comparison to v1.0.0 (narrative only)

| | v1.0.0 | v1.1.0 |
|--|--------|--------|
| Feature | RMS @ 1 s | log-bandpower 4 chmean @ 2 s |
| \(t^*\) | first chaos | first order |
| Hit | 1/7 | **0/7** |
| Dominant fail | ambient chaos → early floor \(t^*\) | order exists but **first** run not in lead window |
| C1 FP | 42/42 (1.0) | **27/42 (0.643)** |
| Precondition gate | none | **PASS** |

### Mechanism (hypothesis, not a protocol change)

Under hypersync / order polarity, **first** sustained order-band entry is a **poor early-warning statistic** when interictal order occupancy is already ~11%: order runs occur long before onset. The failure mode is **timing specificity**, not “never ordered” and not “always chaos.”

**Protocol law:** improving this requires a **new** version (e.g. last order run in a lookback, order *ascent from chaos*, different band collapse, or different lead definition) with new freeze — **not** silent re-fit of 1.1.0.

### Reporting class (design §7)

| Class | This pilot |
|-------|------------|
| promising (hit≥3/7 and C1 FP≤0.5) | no |
| partial (feature non-ambient, polarity weak) | **yes** — gates pass; EWS hits fail |
| FAIL under v1.1 | **EWS primary metric FAIL** (0/7) |

---

## 4. Reproducibility

```bash
cd python && pip install -e ".[dev,eeg]" && cd ..

python notebooks/13_chbmit_p1_eeg_v11.py precondition \
  --case chb01 --raw data/chbmit/raw \
  --out data/chbmit/v1.1/precondition_diagnostic.json

# Do not re-lock if endpoints + diagnostic unchanged
python notebooks/13_chbmit_p1_eeg_v11.py score \
  --endpoints data/chbmit/v1.1/endpoints.json \
  --lock data/chbmit/v1.1/protocol_lock.json \
  --diagnostic data/chbmit/v1.1/precondition_diagnostic.json \
  --raw data/chbmit/raw \
  --out data/chbmit/v1.1/last_p1_eeg_score.json

python notebooks/13_chbmit_p1_eeg_v11.py c1 \
  --case chb01 --raw data/chbmit/raw \
  --out data/chbmit/v1.1/last_c1_eeg.json
```

CI (no PhysioNet):

```bash
cd python && pytest -q tests/test_p1_eeg_v11.py
```

### Citations

- Guttag, J. (2010). CHB-MIT Scalp EEG Database (version 1.0.0). *PhysioNet*. https://doi.org/10.13026/C2K01R  
- Shoeb, A. (2009). PhD Thesis, MIT.

---

## 5. Program decision

**EEG track paused (2026-07-29):** not convenient for Systemic Tau early-warning / paradigm proof after two locked pilots (v1.0 ambient chaos; v1.1 order without lead timing).  

1. **Keep v1.0.0 and v1.1.0 frozen** as historical evidence (do not re-fit).  
2. **No v1.2 / multi-case EEG** unless the program reopens with an explicit new design freeze.  
3. **Priority residual:** Aedes / dengue P1 with **external** domain \(t_{\mathrm{obs}}\) (cleaner regime-contrast preconditions).

---

*End of v1.1.0 pilot report. Raw JSON under `data/chbmit/v1.1/` (local); this document is the citable narrative.*
