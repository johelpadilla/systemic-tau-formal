# P1-ILI — multi-region HHS %wILI with external FluSurv \(t_{\mathrm{obs}}\)

**Document ID:** `P1_ILI_EXTERNAL_TOBS`  
**Protocol version:** `1.0.0`  
**Claim class:** `[EMPÍRICO]` influenza / ILI early-warning residual  
**Software pin:** `systemic-tau-formal` (commit at lock time)

---

## 0. What this is / is not

| This is | This is not |
|---------|-------------|
| Pre-registered P1 on **HHS1–10 ILINet %wILI** matrices | Using national ILI peak as \(t_{\mathrm{obs}}\) (aggregate circularity) |
| \(t_{\mathrm{obs}}\) from **FluSurv-NET hospitalization rate** (external clinical severity) | Post-hoc retune of \(\theta\) / lead after seeing \(\tau^*\) |
| Lead window **4–6 weeks** (paradigm P1 default) | Claim that outpatient ILI *equals* hospitalization dynamics |
| Honest FAIL / miss / no_signal under frozen params | COVID-era seasons treated as normal flu (excluded *a priori*) |

**Forbidden collapse:** “HHS ILI predicts national ILI peak ⇒ P1 discharged.”  
**Allowed:** “Under protocol v1.0.0, multi-region \(\tau_s\) vs FluSurv peak supports / fails P1.”

---

## 1. Data

### 1.1 Channels (matrix \(T \times N\))

| Item | Value |
|------|-------|
| Source | CDC ILINet via [Delphi Epidata `fluview`](https://cmu-delphi.github.io/delphi-epidata/api/fluview.html) |
| Regions | **hhs1 … hhs10** (\(N=10\)) |
| Signal | **`wili`** (weighted % ILI) |
| Season window | CDC flu season: **epiweek YY40 → (YY+1)20** (~33 complete weeks) |
| Layout | `data/ili/field_hhs/HHS_wILI_YYYY-YY.csv` — rows = season weeks, cols = hhs1…hhs10 |

Channel selection is **a priori** (all 10 HHS regions). No data-driven pruning.

### 1.2 External \(t_{\mathrm{obs}}\)

| Item | Value |
|------|-------|
| Source | CDC FluSurv-NET via Delphi [`flusurv`](https://cmu-delphi.github.io/delphi-epidata/api/flusurv.html) |
| Location | **`network_all`** (network-wide catchment aggregate) |
| Signal | **`rate_overall`** (lab-confirmed flu hospitalizations / 100k) |
| Method (primary) | `peak_week` — epiweek of max `rate_overall` within the season span |
| Method (secondary) | `first_exceed_season_p75` — first week ≥ p75 of that season’s rates |
| Store | `data/ili/external/flusurv_network_all.csv` |

**Not allowed as primary \(t_{\mathrm{obs}}\):** national ILINet peak, max of the same HHS matrix, Google Flu Trends, any transform of the channel matrix.

### 1.3 Seasons in scope (v1.0.0)

| Include | Exclude (*a priori*) |
|---------|----------------------|
| 2010–11 … 2019–20 (10 seasons) | **2020–21 and later** (COVID disruption of care-seeking / surveillance) |
| | Incomplete partial seasons without a defined FluSurv peak |

---

## 2. Frozen operational params (`[OPERACIONAL]`)

Same paradigm defaults as P1-Aedes v1.0.0:

| Param | Value | Notes |
|-------|-------|-------|
| `window_size` \(w\) | 13 | weekly samples |
| \(\theta_{\mathrm{ch}}\) | 0.41 | chaos band \(\lvert\tau_s\rvert < 0.41\) |
| \(\theta_{\mathrm{st}}\) | 0.50 | stable band (report only) |
| `t_star` | first sustained **chaos-band** run, length ≥ `min_run` | `first_sustained_chaos_ascent` |
| `min_run` | 4 | weeks |
| `lead` | \(t_{\mathrm{obs}} - t^*\) | row units ≈ weeks |
| `lead_window` | **[4, 6]** | paradigm P1 |

**No re-fit** after lock. Bump protocol version to change any of the above.

---

## 3. Pre-registration workflow

1. **Intake** Delphi → commit matrices + FluSurv CSV (or refresh with dated provenance).  
2. **Propose** endpoints: FluSurv peak (or p75) → season row index via `calendar_map.json`.  
3. **Human review** (or automated a-priori rule already frozen here): set `pre_registered: true` only for seasons with mappable peak.  
4. **Lock** SHA-256 of endpoints + frozen params.  
5. **Score** — refuse null \(t_{\mathrm{obs}}\), `pre_registered: false`, or endpoints hash ≠ lock.

CLI: `notebooks/15_ili_p1_external.py`.

---

## 4. Spatial / measurement honesty

- Channels are **HHS multi-state outpatient ILI**; \(t_{\mathrm{obs}}\) is **network FluSurv hospitalization rate**.  
- Scale and care pathway differ (outpatient visits ≠ hospital catchment). A hit does **not** prove state-level hospital forecast skill.  
- FluSurv coverage is catchment-based, not a full national census of hospitalizations.

---

## 5. Pass criterion

For each locked season series with `pre_registered: true`:

- Compute \(\tau_s(t)\) on the \(T\times 10\) matrix with \(w=13\).  
- \(t^* =\) first sustained chaos ascent (`min_run=4`, \(\theta=0.41\)).  
- **Hit** iff \(\mathrm{lead} = t_{\mathrm{obs}} - t^* \in [4,6]\).  
- Aggregate: hit-rate over scored seasons (honest FAIL allowed).

---

## 6. Files

| Path | Role |
|------|------|
| `docs/P1_ILI_EXTERNAL_TOBS.md` | This protocol freeze |
| `data/ili/field_hhs/` | Season matrices + locks/scores |
| `data/ili/external/` | FluSurv incidence |
| `python/core/p1_ili.py` | Lock / score |
| `python/core/ili_io.py` | Delphi intake helpers |
| `notebooks/15_ili_p1_external.py` | CLI |
| `python/tests/test_p1_ili.py` | Unit tests |

---

## 7. Citations

- CDC ILINet / FluView; FluSurv-NET.  
- Delphi Epidata API (CMU).  
- Chaves et al., Emerging Infectious Diseases 2015 (FluSurv-NET description).
