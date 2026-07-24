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

See [`raw/README.md`](raw/README.md). Committed starter:

- `raw/San_Juan_SJU3_2018_12traps.csv` — San Juan SJU-3, 2018, 12 traps

Drop additional matrix CSVs under `raw/`, register them in `raw/manifest.json`, and re-run notebook 02 / tests.

```bash
python notebooks/02_aedes_puerto_rico.py
cd python && pytest -q tests/test_aedes_raw.py
```

Regenerate **proxy only** (never overwrites `raw/`):

```bash
cd python && python scripts/export_fixtures.py
```

Sibling research tree: `~/grok-work/tau-sistemic`.
