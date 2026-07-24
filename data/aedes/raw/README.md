# Aedes field series (`raw/`)

**Epistemic label:** `[EMPÍRICO]` for committed trap matrices listed in `manifest.json`.  
**Not proxy.** Proxy stand-ins live in `../proxy/` (`[OPERACIONAL]` only).

## Schema (matrix CSV)

Same contract as the rest of the monorepo / `load_matrix_csv`:

| Rule | Detail |
|------|--------|
| Rows | Time index (epi week / sample). Optional date / non-numeric column is dropped. |
| Columns | Trap / site series, **N ≥ 2** |
| Header | Optional first row of names |
| Values | Counts; missing trap-weeks filled with **0** in thesis imports |
| Delimiter | Comma |

## Committed series (2018 San Juan)

| File | T × N | Cluster |
|------|-------|---------|
| `San_Juan_SJU3_2018_12traps.csv` | 30 × 12 | SJU-3 (standardized long) |
| `San_Juan_SJU1_Repto_Metropolitano_2018.csv` | 49 × 21 | SJU-1 Repto Metropolitano |
| `San_Juan_SJU2_2018_epiweeks.csv` | 46 × 22 | SJU-2 epi weeks 7–52 |

Provenance: thesis fieldwork materials under `tau-sistemic/.../aedes_tesis/`.  
SUMMER and WINTER Excel books for SJU-2 are **identical** matrices (only SUMMER was imported).

Regenerate SJU-1 / SJU-2 from Excel (requires `pandas`, `xlrd`, `openpyxl`):

```bash
python python/scripts/import_aedes_thesis.py
```

## Empirical report

```bash
python notebooks/07_aedes_field_report.py
python notebooks/07_aedes_field_report.py --json data/aedes/raw/last_field_report.json
```

**Honesty:** the report does **not** score P1 (4–6 week lead) without a pre-registered
observable transition endpoint. It reports τₛ regimes, RECD clock, and chaos-band run lengths.

## How to add more

1. Place a matrix CSV here (`*.csv` is trackable).  
2. Register it in `manifest.json`.  
3. Re-run notebook 02 / 07 and tests.

Bulk Excel (`.xls`/`.xlsx`) stays **gitignored** — convert via the import script or by hand.

## Loader priority

`core.load_aedes_sites()` (and notebooks 02 / 07):

1. **All** `raw/*.csv` if any exist → label `[EMPÍRICO]`  
2. Else committed `proxy/*.csv` → `[OPERACIONAL]`  
3. Else in-memory proxy generator
