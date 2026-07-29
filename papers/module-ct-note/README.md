# Module CT technical note

**Title:** Discrete Extramental Time versus Classical Thermodynamic Time: A Formal Confrontation

| Item | Value |
|------|--------|
| Source | [`Discrete_Extramental_Time_vs_Classical_Thermodynamic_Time.md`](Discrete_Extramental_Time_vs_Classical_Thermodynamic_Time.md) |
| PDF | [`Discrete_Extramental_Time_vs_Classical_Thermodynamic_Time.pdf`](Discrete_Extramental_Time_vs_Classical_Thermodynamic_Time.pdf) |
| **DOI (this note)** | [10.5281/zenodo.21582078](https://doi.org/10.5281/zenodo.21582078) |
| Concept DOI | [10.5281/zenodo.21582077](https://doi.org/10.5281/zenodo.21582077) |
| Record | https://zenodo.org/records/21582078 |
| Software pin | `systemic-tau-formal` **v0.1.11** |
| DOI (software) | [10.5281/zenodo.21581189](https://doi.org/10.5281/zenodo.21581189) |
| Scope | Lean Module CT only (0 `sorry`); no empirical premises |
| Length | ~11 pages (Letter) |
| Design doc | [`docs/RECD_vs_Thermodynamic_Time.md`](../../docs/RECD_vs_Thermodynamic_Time.md) |

## Build PDF

Prefer Homebrew pandoc 3.x (system `/usr/bin/pandoc` may be 1.x):

```bash
/usr/local/Cellar/pandoc/3.10/bin/pandoc \
  -f markdown+tex_math_single_backslash+tex_math_dollars+raw_tex \
  --pdf-engine=xelatex \
  --toc --toc-depth=1 \
  -V documentclass=article \
  -o Discrete_Extramental_Time_vs_Classical_Thermodynamic_Time.pdf \
  Discrete_Extramental_Time_vs_Classical_Thermodynamic_Time.md
```

YAML front matter sets geometry, fonts, link colors, and booktabs headers.
