# P1-Aedes report — Vitória, Brazil (unlocked residual)

**Date:** 2026-07-28  
**Protocol:** `P1_AEDES_EXTERNAL_TOBS` v1.0.0  
**Claim class:** `[EMPÍRICO]`  
**Data:** Figshare `10.6084/m9.figshare.7905254.v1` (Vitória MosquiTRAP + dengue-like cases, 2008–2012)

---

## 1. Why we left San Juan 2018 clinical

Committed San Juan multi-trap matrices (SJU1/2/3, 2018) have **no usable clinical peak**:

- OpenDengue national PRI 2018: weekly confirmed dengue = **0**
- CDC NNDSS 2018 PR: cumulative dengue ≈ **2**
- PRDH Informes (digitized): `DENV_new` ≈ **0**

Details: `data/aedes/external/SOURCES_2018.md`.

**Blocker was not missing CSV downloads — it was a near-zero dengue year.**

---

## 2. What we found that *does* serve

Public paired dataset (same DOI):

- **75 neighborhoods × 243 weeks** mosquito counts + dengue-like cases  
- Large clinical waves in **2009** and **2011** (citywide weekly peaks 514 and 559)

Intake path: `data/aedes/field_vitoria/`  
External incidence: `data/aedes/external/vitoria_dengue_cases_2008_2012.csv`

**A priori channel rule:** top 15 RG by total mosquitoes (not cases).  
**A priori \(t_{\mathrm{obs}}\):** from **Cases only** (peak_week or first_exceed_year_p75), locked before inspecting \(\tau^*\).

---

## 3. Scores (frozen params)

| \(w\) | \(\theta_{\mathrm{chaos}}\) | lead window | \(t^*\) rule |
|------|------------------------------|-------------|--------------|
| 13 | 0.41 | 4–6 weeks | first_sustained_chaos_ascent |

| Endpoints file | Method | n scored | hits | hit rate |
|----------------|--------|----------|------|----------|
| `endpoints_vitoria.json` | peak 2011 full series | 1 | 0 | 0 |
| `endpoints_vitoria_yearly.json` | peak_week / year | 5 | 0 | 0 |
| `endpoints_vitoria_yearly_p75.json` | first_exceed p75 / year | 5 | 0 | 0 |

Representative yearly `peak_week` leads (t_obs − t\*):

| Year | t\* | t_obs (peak) | lead | verdict |
|------|-----|--------------|------|---------|
| 2008 | 12 | 13 | 1 | miss (window 4–6) |
| 2009 | 15 | 11 | −4 | miss (after peak) |
| 2010 | 30 | 18 | −12 | miss |
| 2011 | 28 | 17 | −11 | miss |
| 2012 | 12 | 1 | −11 | miss |

**Verdict:** under protocol v1.0.0 frozen params, multi-neighborhood \(\tau_s\) **does not** give 4–6 week early warning of citywide clinical peak/onset on this Vitória top-15 design. Closest year is 2008 (lead 1 week to peak).

---

## 4. What this means for the paradigm

1. **Infrastructure works:** external \(t_{\mathrm{obs}}\) → lock → score path is no longer blocked by missing clinical data.  
2. **Empirical residual is real:** Vitória is a proper multi-channel + clinical test, not trap-surge circularity.  
3. **Result is FAIL / miss_lead, not “unscored.”** Prefer this to inventing 2018 San Juan peaks.  
4. **Do not** retune \(\theta\) / lead window post-hoc to manufacture hits on this lock without a new pre-registered protocol version.

---

## 5. Next residual options (if continuing dengue track)

1. Pre-register a **new protocol version** (different \(t^*\) rule, seasonal baseline, or per-RG clinical \(t_{\mathrm{obs}}\)) **before** re-scoring.  
2. Intervention endpoint (e.g. Cairns Wolbachia release week — Figshare `9831113`).  
3. Other long multi-trap open sets (inventory in tau-sistemic `Master_Open_Aedes_Datasets_Inventory.md`) with concurrent incidence.

---

## 6. Files

| Path | Role |
|------|------|
| `data/aedes/field_vitoria/*.csv` | Year / full matrices |
| `data/aedes/field_vitoria/endpoints_*.json` | Pre-registered endpoints |
| `data/aedes/field_vitoria/protocol_lock_*.json` | SHA locks |
| `data/aedes/field_vitoria/last_p1_aedes_score_*.json` | Score dumps |
| `data/aedes/external/vitoria_dengue_cases_2008_2012.csv` | External clinical |
| `data/aedes/external/_sources/Vitoria.*` | Upstream Figshare copies |
