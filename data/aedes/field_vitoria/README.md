# Field series — Vitória, Brazil (MosquiTRAP + dengue-like cases)

**Label:** `[EMPÍRICO]`  
**DOI / Figshare:** [10.6084/m9.figshare.7905254.v1](https://doi.org/10.6084/m9.figshare.7905254.v1)  
**Paper context:** Leach et al., mosquito surveillance linked to dengue fever (Bayesian mechanistic modeling).  
**Source copy:** `../external/_sources/Vitoria.data.csv` (+ weather, README).

## Why this site (vs San Juan 2018)

San Juan 2018 multi-trap matrices exist, but **island confirmed dengue 2018 ≈ 0** (OpenDengue / NNDSS / PRDH).  
No clinical domain peak → P1 cannot define external \(t_{\mathrm{obs}}\).

Vitória provides **both** in the same public release:

| Layer | Content |
|-------|---------|
| Vector | Weekly MosquiTRAP counts, **75 neighborhoods (RG)**, weeks 1/2008–34/2012 (243 weeks, balanced panel) |
| Clinical | Weekly **dengue-like illness** reports per RG (and citywide sum) |
| Peaks | Real outbreaks (e.g. 2009 peak ~514/wk, 2011 peak ~559/wk citywide) |

## Matrices committed here

| File | Shape | Notes |
|------|-------|--------|
| `Vitoria_BR_top15RG_2008_2012.csv` | 243 × 15 | Full span; multi-year |
| `Vitoria_BR_top15RG_YYYY.csv` | ~52 × 15 | **A priori** epidemiological-year slices |

**Channel selection (a priori, not Cases):** top 15 RG by **sum(Mosquitoes)** over the full span.  
RG list: 68, 69, 71, 35, 66, 23, 4, 25, 58, 38, 19, 70, 45, 17, 62.

## Clinical incidence (external)

`../external/vitoria_dengue_cases_2008_2012.csv` — citywide sum of `Cases` by week.

## P1 design used

Protocol: `P1_AEDES_EXTERNAL_TOBS` v1.0.0, frozen params \(w=13\), \(\theta=0.41\), lead **4–6** weeks, \(t^*\) = first sustained chaos ascent.

1. **Multi-year single peak** (`endpoints_vitoria.json`): peak 2011 citywide → `t_obs=174` → **miss_lead** (early 2008 \(t^*\)).  
2. **Year slices + `peak_week`** (`endpoints_vitoria_yearly.json`): **0/5 hits**.  
3. **Year slices + `first_exceed_year_p75`** (`endpoints_vitoria_yearly_p75.json`): **0/5 hits**.

Locks + scores: `protocol_lock_vitoria*.json`, `last_p1_aedes_score_vitoria*.json`.

### Honest summary (do not spin)

| Design | n | hits | note |
|--------|---|------|------|
| Full series peak 2011 | 1 | 0 | \(t^*=12\), lead=162 |
| Yearly `peak_week` | 5 | 0 | often \(t^*\) **after** clinical peak (negative lead) |
| Yearly `first_exceed_year_p75` | 5 | 0 | same; closest is 2008 lead≈0 |

**P1 EWS claim not supported** on this Vitória top-15 design under frozen params.  
The dataset **does** serve as a true multi-channel + external-\(t_{\mathrm{obs}}\) residual (pipeline unblocked).

## Reproduce score

```bash
cd /path/to/systemic-tau-formal
python3 - <<'PY'
import json
from pathlib import Path
import sys
sys.path.insert(0, "python")
from core.p1_aedes import score_locked_endpoints
from core.io_data import load_matrix_csv

root = Path(".")
d = root / "data/aedes/field_vitoria"
ep = json.loads((d / "endpoints_vitoria_yearly.json").read_text())
lock = json.loads((d / "protocol_lock_vitoria_yearly.json").read_text())
sites = {
    Path(s["file"]).stem: load_matrix_csv(d / s["file"])
    for s in ep["series"]
}
print(json.dumps(score_locked_endpoints(ep, lock, root=root, sites=sites), indent=2))
PY
```

## Spatial honesty

Channels are **neighborhood aggregates** (MosquiTRAP totals), not household traps.  
Clinical \(t_{\mathrm{obs}}\) is **citywide**. Scale mismatch is documented; a hit would not prove house-level forecast skill.
