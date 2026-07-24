# Aedes / dengue trap data

## Layout

| Path | Role | Label |
|------|------|--------|
| `proxy/` | Committed synthetic two-site stand-in | `[OPERACIONAL]` |
| `raw/` | Field / thesis trap matrices (CSV) | `[EMPÍRICO]` when real series |

## Proxy fixtures (`proxy/`)

| File | Notes |
|------|--------|
| `Cano_Martin_Pena_proxy.csv` | 200 × 3 non-negative trap-like series |
| `Candelaria_proxy.csv` | Later onset of volatility (demo “transition”) |
| `manifest.json` | Schema + seeds; **not** calendar-stamped field data |

Names are **not** field entomology. Notebook `02_aedes_puerto_rico` falls back here only if `raw/` has no CSVs.

## Field intake (`raw/`)

See [`raw/README.md`](raw/README.md). Committed 2018 San Juan clusters:

- `San_Juan_SJU3_2018_12traps.csv` — SJU-3 (30 × 12)
- `San_Juan_SJU1_Repto_Metropolitano_2018.csv` — SJU-1 (49 × 21)
- `San_Juan_SJU2_2018_epiweeks.csv` — SJU-2 (46 × 22)

```bash
python notebooks/02_aedes_puerto_rico.py
python notebooks/07_aedes_field_report.py
cd python && pytest -q tests/test_aedes_raw.py
# re-import SJU1/2 from thesis Excel:
python python/scripts/import_aedes_thesis.py
```

Regenerate **proxy only** (never overwrites `raw/`):

```bash
cd python && python scripts/export_fixtures.py
```

Sibling research tree: `~/grok-work/tau-sistemic`.
