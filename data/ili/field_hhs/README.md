# Field series — USA HHS ILINet %wILI (P1-ILI)

**Label:** `[EMPÍRICO]`  
**Protocol:** [`docs/P1_ILI_EXTERNAL_TOBS.md`](../../../docs/P1_ILI_EXTERNAL_TOBS.md) v1.0.0  
**Channels:** Delphi Epidata `fluview` → CDC ILINet **weighted %ILI** for **hhs1…hhs10**  
**External \(t_{\mathrm{obs}}\):** Delphi `flusurv` → FluSurv-NET **`network_all` `rate_overall`**

## Matrices

| File | Shape | Season window |
|------|-------|---------------|
| `HHS_wILI_YYYY-YY.csv` | ~33 × 10 | epiweek YY40 → (YY+1)20 (complete HHS panel only) |

Header columns: `hhs1,…,hhs10`. Row 0 = first complete season week.

Calendar (epiweek list per series): `calendar_map.json`.

## Design (a priori)

| Piece | Rule |
|-------|------|
| Channels | All 10 HHS regions (no abundance pruning) |
| Seasons | 2010–11 … 2019–20 |
| Exclude | **2020+** (COVID surveillance / care-seeking disruption) |
| Primary \(t_{\mathrm{obs}}\) | FluSurv `peak_week` within season |
| Secondary \(t_{\mathrm{obs}}\) | FluSurv `first_exceed_season_p75` |
| Params | \(w=13\), \(\theta=0.41\), lead **4–6**, chaos ascent |

**Forbidden:** national ILI peak as \(t_{\mathrm{obs}}\) (aggregate circularity).

## Locked scores (v1.0.0 freeze)

| Endpoints | Method | n | hits | hit rate |
|-----------|--------|---|------|----------|
| `endpoints_hhs_yearly.json` | peak_week | 10 | 0 | 0.0 |
| `endpoints_hhs_yearly_p75.json` | first_exceed_season_p75 | 10 | 1 | 0.1 |

Details: `docs/P1_ILI_REPORT.md`.

## Reproduce

```bash
cd /path/to/systemic-tau-formal
python notebooks/15_ili_p1_external.py score
python notebooks/15_ili_p1_external.py score --method first_exceed_season_p75
```

## Honesty

Outpatient ILINet (HHS) ≠ FluSurv hospital catchments. A hit would not prove state-level hospital forecast skill.
