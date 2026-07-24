# Papers index

Do not duplicate multi‑MB PDF binaries in git unless needed for a release tag.  
Link DOIs and local catalog paths instead. Small frozen pins (~150 KB) under `papers/*/pins/` are allowed.

| Topic | Catalog / DOI / path | Lean target |
|-------|----------------------|-------------|
| **Operational standard preprint (EN)** | `preprint-standard-formal/` · doc **0.1.8-r3** · PDF `preprint-standard-formal/pins/standard-formal-v0.1.8-r3.pdf` · software DOI [10.5281/zenodo.21522882](https://doi.org/10.5281/zenodo.21522882) | full `SystemicTau/` |
| Feigenbaum reduction | `Publicaciones/09_Feigenbaum_Reduction_Theorem.pdf` | `FeigenbaumReduction.lean` |
| Feigenbaum (journal style) | `11_Teorema_Feigenbaum_Estilo_Revista.pdf` | same |
| Appendix B | `12_Suplemento_Apéndice_B_Feigenbaum.pdf` | same |
| RECD framework | Zenodo / `Fundacion_RECD` | `RECD.lean`, `Basic.lean` |
| Magna synthesis | `10.5281/zenodo.20576241` | overview |
| Dengue EWS | catalog `06_`, `07_`, `08_` | empirical layer only |

When cutting a public GitHub release, attach PDFs via Zenodo and pin DOIs here.
