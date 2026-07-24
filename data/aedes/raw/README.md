# Aedes field series (`raw/`)

**Epistemic label:** `[EMPÍRICO]` for committed trap matrices listed in `manifest.json`.  
**Not proxy.** Proxy stand-ins live in `../proxy/` (`[OPERACIONAL]` only).

## Schema (matrix CSV)

Same contract as the rest of the monorepo / `load_matrix_csv`:

| Rule | Detail |
|------|--------|
| Rows | Time index (epi week / sample). Optional date column is dropped if non-numeric. |
| Columns | Trap / site series, **N ≥ 2** |
| Header | Optional first row of names |
| Values | Non-negative counts preferred (pipeline clips negatives if needed) |
| Delimiter | Comma |

Example header:

```text
DATE,SJU-3-01,SJU-3-02,...,SJU-3-12
```

## Committed series

| File | T × N (approx.) | Notes |
|------|-----------------|--------|
| `San_Juan_SJU3_2018_12traps.csv` | 30 × 12 | San Juan SJU-3 traps, 2018 standardized long format |

Source lineage: thesis fieldwork (Caño Martín Peña / Repto Metropolitano context) +
standardized export used in the tau-sistemic research tree. See `manifest.json`.

## How to add more

1. Place a matrix CSV here (`*.csv` is trackable).  
2. Register it in `manifest.json` (`sites` / `files`).  
3. Run:

```bash
python notebooks/02_aedes_puerto_rico.py
# or
cd python && pytest -q tests/test_aedes_raw.py
```

Bulk Excel (`.xls`/`.xlsx`) stays **gitignored** — convert to matrix CSV first.

## Loader priority

`core.load_aedes_sites()` (and notebook 02):

1. **All** `raw/*.csv` if any exist → label `[EMPÍRICO]`  
2. Else committed `proxy/*.csv` → `[OPERACIONAL]`  
3. Else in-memory proxy generator
