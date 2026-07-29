# External domain series for P1-Aedes (`t_obs`)

**Epistemic label:** external clinical / operational only — **not** trap-derived.  
**Protocol:** [`docs/P1_AEDES_EXTERNAL_TOBS.md`](../../../docs/P1_AEDES_EXTERNAL_TOBS.md) v1.0.0

## Purpose

Provide **independent** weekly endpoints so multi-trap \(\tau_s\) can be scored as true P1  
(lead 4–6 weeks before a domain transition). Never fill `endpoints.json` from trap totals.

## Expected file (clinical dengue)

| Column | Required | Notes |
|--------|----------|-------|
| `year` | yes | e.g. 2011 |
| `weekofyear` | yes | 1–53 |
| `total_cases` | yes | non-negative counts |
| `week_start_date` | optional | ISO week start |
| `geo` | optional | e.g. `Vitoria_BR_citywide` |

Example: `incidence.example.csv`.

## Status (updated 2026-07-28)

### San Juan / PR 2018 traps — clinical blocked

| File | Status |
|------|--------|
| `pr_dengue_cases_2018.csv` | OpenDengue V1.3 national weekly PRI 2018 — **all zeros** |
| Detail | [`SOURCES_2018.md`](SOURCES_2018.md) |

No usable outbreak peak (post-Zika). Do not invent \(t_{\mathrm{obs}}\).

### Vitória, Brazil 2008–2012 — usable paired residual

| File | Status |
|------|--------|
| `vitoria_dengue_cases_2008_2012.csv` | Citywide dengue-like weekly cases (**real peaks**) |
| Upstream | `_sources/Vitoria.data.csv` (Figshare `10.6084/m9.figshare.7905254.v1`) |
| Multi-channel matrices + P1 scores | [`../field_vitoria/`](../field_vitoria/) |
| Report | [`docs/P1_AEDES_VITORIA_REPORT.md`](../../../docs/P1_AEDES_VITORIA_REPORT.md) |

Scored under protocol v1.0.0: **0/5 yearly hits** (honest `miss_lead`). Pipeline unblocked.

## Allowed sources

1. CDC ArboNET / NNDSS / CDC dengue historic weekly (U.S. territories)  
2. Puerto Rico Department of Health / Instituto de Estadísticas arbovirus weekly  
3. PAHO PLISA / OpenDengue country weekly (document geography)  
4. Documented vector-control campaign start week (agency report)  
5. Paired open field sets (e.g. Vitória Figshare above)

## Forbidden

- Copying trap max_total / first_q90 into `pre_registered: true`  
- Looking at \(\tau^*\) before locking endpoints  
- Using 1990–2013 DengAI peaks as \(t_{\mathrm{obs}}\) for 2018 traps  
- Locking all-zero clinical series as if a peak existed  
