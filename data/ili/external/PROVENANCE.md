# FluSurv external incidence — provenance

**Download date:** 2026-07-29  
**API:** `https://api.delphi.cmu.edu/epidata/flusurv/`  
**Location:** `network_all`  
**Signal used for \(t_{\mathrm{obs}}\):** `rate_overall` (lab-confirmed influenza hospitalizations per 100,000)  
**File:** `flusurv_network_all.csv`

Columns:

| Column | Meaning |
|--------|---------|
| `season` | Flu season label (e.g. `2017-18`) |
| `year`, `weekofyear` | Epiweek parts |
| `epiweek` | YYYYWW |
| `rate_overall` | FluSurv network rate |
| `total_cases` | Alias of `rate_overall` for scorer compatibility |

Upstream: CDC FluSurv-NET via Delphi Epidata.  
License: US Government public data (see Delphi / CDC terms).

Channel matrices (HHS %wILI) live under `../field_hhs/` from Delphi `fluview` (CDC ILINet).
