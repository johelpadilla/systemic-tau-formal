# Preprint: machine-checkable operational standard (τₛ / RECD)

| Field | Value |
|-------|--------|
| **Title** | A Machine-Checkable Operational Standard for Systemic Tau τₛ and the Discrete Extramental Clock (RECD) |
| **Subtitle** | Lean 4 formalization, laboratory constructions, and open scrutiny program (v0.1.9) |
| **Document version** | `0.1.9-r2` |
| **Software pin** | `systemic-tau-formal` **v0.1.9** |
| **Preprint DOI** | [10.5281/zenodo.21536484](https://doi.org/10.5281/zenodo.21536484) |
| **Preprint concept DOI** | [10.5281/zenodo.21523231](https://doi.org/10.5281/zenodo.21523231) |
| **Software DOI** | [10.5281/zenodo.21536462](https://doi.org/10.5281/zenodo.21536462) |
| **Software concept DOI** | [10.5281/zenodo.21516059](https://doi.org/10.5281/zenodo.21516059) |
| **Date** | 2026-07-24 |
| **Source** | `main.tex` |
| **Build** | `xelatex main.tex` (×2 recommended) |
| **Frozen PDF** | `pins/standard-formal-v0.1.9-r2.pdf` |

## Build

```bash
cd papers/preprint-standard-formal
xelatex -interaction=nonstopmode main.tex
xelatex -interaction=nonstopmode main.tex
```

## Pin policy

Frozen PDFs live under `pins/`. Update `SHA256SUMS` when freezing a new pin.
