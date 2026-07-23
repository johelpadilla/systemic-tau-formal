# Aedes / dengue trap data

## Layout

| Path | Role |
|------|------|
| `proxy/` | **Committed** synthetic two-site stand-in (`[OPERACIONAL]`) |
| `raw/` | **Not in git** — place licensed field CSVs here (see `.gitignore`) |

## Proxy fixtures (`proxy/`)

| File | Notes |
|------|--------|
| `Cano_Martin_Pena_proxy.csv` | 200 × 3 non-negative trap-like series |
| `Candelaria_proxy.csv` | Later onset of volatility (demo “transition”) |
| `manifest.json` | Schema + seeds; **not** calendar-stamped field data |

These are **not** Caño Martín Peña / Candelaria entomology. Notebook `02_aedes_puerto_rico` loads them and runs the τₛ + RECD pipeline.

## Real data intake (when license permits)

1. Obtain clear license / data-use terms and citation of the agency/study.  
2. De-identify if required.  
3. Drop CSVs under `data/aedes/raw/` (ignored by git by default).  
4. Document source + license in a local `raw/LICENSE.txt` (do not commit secrets).  
5. Point the loader in notebook 02 at `raw/` instead of `proxy/`.  
6. Report outcomes as `[EMPÍRICO]` only for those series.

Sibling applied pipelines: `~/grok-work/tau-sistemic`.

Regenerate proxies:

```bash
cd python && python scripts/export_fixtures.py
```
