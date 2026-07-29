# P1-ILI report — HHS %wILI vs FluSurv (locked residual)

**Date:** 2026-07-29  
**Protocol:** `P1_ILI_EXTERNAL_TOBS` v1.0.0  
**Claim class:** `[EMPÍRICO]`  
**Data:** Delphi Epidata → CDC ILINet (HHS1–10 `wili`) + FluSurv-NET (`network_all` `rate_overall`), seasons **2010–11 … 2019–20**

---

## 1. Why influenza after Vitória / San Juan

| Track | Blocker / result |
|-------|------------------|
| San Juan Aedes 2018 | Clinical dengue ≈ 0 → no \(t_{\mathrm{obs}}\) |
| Vitória Aedes | Pipeline unlocked; **0/5** yearly hits (miss_lead) |
| **ILI / Flu** | Complete multi-region weekly panel + real hospital peaks; N=10 seasons |

Design goal: honest multi-channel P1 with **external** clinical severity endpoint (not trap-surge / not national ILI aggregate).

---

## 2. Design freeze (a priori)

| Piece | Value |
|-------|-------|
| Channels | HHS1–10 ILINet **%wILI** (\(N=10\)) |
| Season window | epiweek **YY40 → (YY+1)20** (~33 weeks) |
| \(t_{\mathrm{obs}}\) primary | FluSurv **`peak_week`** of `rate_overall` |
| \(t_{\mathrm{obs}}\) secondary | FluSurv **`first_exceed_season_p75`** |
| Exclude | **2020+** seasons (COVID) |
| Params | \(w=13\), \(\theta=0.41\), lead **4–6**, \(t^*=\) first sustained chaos ascent |

**Honesty:** national ILI peak is **not** used as \(t_{\mathrm{obs}}\) (would be soft circularity).

Intake path: `data/ili/field_hhs/`  
External: `data/ili/external/flusurv_network_all.csv`

---

## 3. Scores (frozen params)

### 3.1 Primary — `peak_week` FluSurv

| Season | t\* | t_obs (row) | FluSurv peak epiweek | lead | verdict |
|--------|-----|-------------|----------------------|------|---------|
| 2010-11 | — | 20 | 201108 | — | **no_signal** |
| 2011-12 | 16 | 23 | 201211 | 7 | **miss_lead** |
| 2012-13 | — | 13 | 201301 | — | **no_signal** |
| 2013-14 | — | 13 | 201401 | — | **no_signal** |
| 2014-15 | — | 12 | 201452 | — | **no_signal** |
| 2015-16 | — | 22 | 201610 | — | **no_signal** |
| 2016-17 | 22 | 20 | 201708 | −2 | **miss_lead** |
| 2017-18 | — | 13 | 201801 | — | **no_signal** |
| 2018-19 | — | 23 | 201911 | — | **no_signal** |
| 2019-20 | 22 | 18 | 202006 | −4 | **miss_lead** |

**Aggregate:** n_scored=**10**, n_hit=**0**, hit_rate=**0.0**

### 3.2 Secondary — `first_exceed_season_p75`

| Season | t\* | t_obs | lead | verdict |
|--------|-----|-------|------|---------|
| 2010-11 | — | 15 | — | no_signal |
| 2011-12 | 16 | 21 | **5** | **hit** |
| 2012-13 | — | 11 | — | no_signal |
| 2013-14 | — | 11 | — | no_signal |
| 2014-15 | — | 10 | — | no_signal |
| 2015-16 | — | 19 | — | no_signal |
| 2016-17 | 22 | 13 | −9 | miss_lead |
| 2017-18 | — | 12 | — | no_signal |
| 2018-19 | — | 18 | — | no_signal |
| 2019-20 | 22 | 12 | −10 | miss_lead |

**Aggregate:** n_scored=**10**, n_hit=**1**, hit_rate=**0.1**

---

## 4. Interpretation (do not spin)

1. **Infrastructure works:** multi-season multi-channel + external clinical lock/score is no longer blocked.  
2. **Primary design fails EWS:** under chaos-ascent + 4–6 week lead, **0/10** FluSurv peak hits.  
3. **Dominant mode is `no_signal`:** in most seasons the HHS %wILI panel never enters a sustained chaos-band run (`min_run=4`, \(\theta=0.41\)). That is a different failure mode than Vitória (where \(t^*\) often arrived **after** clinical peak).  
4. **Secondary p75** yields one in-window hit (2011–12 lead=5) — not enough to claim discharge; still locked and reported for completeness.  
5. **Do not** retune \(\theta\) / lead / \(t^*\) rule post-hoc on this lock without a new pre-registered protocol version.

---

## 5. What this means for the paradigm

| Claim | Status |
|-------|--------|
| “P1 4–6 week EWS on multi-region ILI → FluSurv peak, frozen chaos params” | **Not supported** (0/10) |
| “Domain has usable external \(t_{\mathrm{obs}}\) and complete channels” | **Yes** |
| “Cross-domain residual is still open” | **Yes** — consider alternate \(t^*\) polarity or domain with clearer multi-channel desync |

---

## 6. Files

| Path | Role |
|------|------|
| `data/ili/field_hhs/HHS_wILI_*.csv` | Season matrices |
| `data/ili/field_hhs/calendar_map.json` | Epiweek → row |
| `data/ili/field_hhs/endpoints_hhs_yearly*.json` | Pre-registered endpoints |
| `data/ili/field_hhs/protocol_lock_hhs_yearly*.json` | SHA locks |
| `data/ili/field_hhs/last_p1_ili_score_*.json` | Score dumps |
| `data/ili/external/flusurv_network_all.csv` | External clinical rates |
| `python/core/p1_ili.py`, `ili_io.py` | Code |
| `notebooks/15_ili_p1_external.py` | CLI |
