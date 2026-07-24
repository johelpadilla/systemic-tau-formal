# Preprint: machine-checkable operational standard (τₛ / RECD)

| Field | Value |
|-------|--------|
| **Title** | A Machine-Checkable Operational Standard for Systemic Tau τₛ and the Discrete Extramental Clock (RECD) |
| **Subtitle** | Lean 4 formalization, laboratory constructions, and open scrutiny program (v0.1.8) |
| **Document version** | `0.1.8-r3` |
| **Software pin** | `systemic-tau-formal` **v0.1.8** |
| **Software DOI** | [10.5281/zenodo.21522882](https://doi.org/10.5281/zenodo.21522882) |
| **Concept DOI** | [10.5281/zenodo.21516059](https://doi.org/10.5281/zenodo.21516059) |
| **Date** | 2026-07-24 |
| **Source** | `main.tex` |
| **Build** | `xelatex main.tex` (×2 recommended) |
| **Frozen PDF** | `pins/standard-formal-v0.1.8-r3.pdf` |

## Build

```bash
cd papers/preprint-standard-formal
xelatex -interaction=nonstopmode main.tex
xelatex -interaction=nonstopmode main.tex
```

Requires XeLaTeX, Times New Roman (or edit `\setmainfont`), and standard TeX packages
(`amsmath`, `booktabs`, `tikz`, `hyperref`, `float`, …).

## Pin policy

- **Software** versions remain `v0.1.x` tags on the monorepo.
- **Preprint** revisions use `0.1.8-rN` while the formal pin is v0.1.8.
- Bump `rN` for prose/layout-only changes; bump software + major doc version when Lean claims change.
- Prefer attaching the frozen PDF to a Zenodo record for a **document DOI**; until then cite the software DOI and this path.

## Citation (provisional)

Padilla-Villanueva, J. (2026). *A Machine-Checkable Operational Standard for Systemic Tau τₛ and the Discrete Extramental Clock (RECD)* (preprint 0.1.8-r3; software v0.1.8).  
https://github.com/johelpadilla/systemic-tau-formal  
Software DOI: https://doi.org/10.5281/zenodo.21522882

See also `CHANGELOG.md` and `VERSION`.
