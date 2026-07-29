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

## Empirical reports

```bash
python notebooks/07_aedes_field_report.py
python notebooks/08_aedes_p3_field.py          # P3 noise ρ≤0.20 on field matrices
python notebooks/09_aedes_p4_field.py          # P4 structure vs baselines
python notebooks/10_aedes_empirical_board.py   # unified P1/P3/P4 board
```

**Honesty:**
- nb 07 does **not** score P1 without a pre-registered endpoint.
- nb 08 runs protocol noise on field series (usable band labels at ρ≤0.20 in tests).
- nb 09 does **not** claim P4 discharge without strong-anti premise (`τₛ ≤ −0.41` mass).
- nb 10 aggregates P1/P3/P4 + **field return** + **exploratory leads** (`build_empirical_board` v2).
- nb 11 — multi-site **field-derived first-return** + trap-surge exploratory leads
  (`core.field_return`, `exploratory_lead_scan`). See `docs/FIELD_EMPIRICAL_STATUS.md`.
- For true P1: protocol [`docs/P1_AEDES_EXTERNAL_TOBS.md`](../../../docs/P1_AEDES_EXTERNAL_TOBS.md) v1.0.0.
  Calendar: `calendar_map.json`. External clinical under `../external/`.
  CLI: `python notebooks/14_aedes_p1_external.py status|propose|lock|score`.
  Copy `endpoints.example.json` → `endpoints.json` (gitignored) only after external
  `t_obs` + `pre_registered: true`. Trap-surge leads are **never** auto-promoted to P1.
  **Blocker:** 2018 weekly dengue cases (DengAI ends ~2013).

## How to add more (multi-year intake)

1. **Flat:** place `Site_Year.csv` in this directory, **or**  
   **Year folder:** `raw/2019/Site_A.csv` → loader key `2019_Site_A`.
2. Register it in `manifest.json` (path relative to `raw/`).
3. Re-run notebooks 02 / 07 / 10 and tests.

Bulk Excel (`.xls`/`.xlsx`) stays **gitignored** — convert via the import script or by hand.

## Loader priority

`core.load_aedes_sites()` (and notebooks 02 / 07 / 10):

1. **All** `raw/**/*.csv` if any exist → label `[EMPÍRICO]` (recursive year folders)  
2. Else committed `proxy/*.csv` → `[OPERACIONAL]`  
3. Else in-memory proxy generator
