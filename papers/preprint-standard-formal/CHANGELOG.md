# Preprint changelog — operational standard (τₛ / RECD)

Document ID: `preprint-standard-formal`  
Software pin: `systemic-tau-formal` **v0.1.8** (DOI 10.5281/zenodo.21522882)

## 0.1.8-r3 — 2026-07-24

Residual polish after positive review of r2 (non-blocking layout/readability):

- Table 4 split: **Proved (core)** vs **Proved (lab lemmas)** for faster scanning.
- Figure 3: hatched greyscale-safe strip for positive intermediate band (\(g=0\)).
- §§5.1–5.4: connecting sentences for non-Lean readers.
- \(\deltaop\): explicit fixed ten-decimal truncation wording + non-uniqueness of approximant.
- Table 5 (`modules-detail`) pinned with `[H]` + `\clearpage` before bibliography (no longer floats into References).

Frozen PDF: `pins/standard-formal-v0.1.8-r3.pdf`

## 0.1.8-r2 — 2026-07-24

Second printable English revision after external feedback on the v0.1.8 prototype.

- Sharper abstract (operational standard + laboratory package; not closed universality).
- Subtitle: Lean 4 formalization, laboratory constructions, open scrutiny (v0.1.8).
- Explicit no-overclaim in Introduction and Discussion.
- Formal status table: proved / laboratory constructions / explicitly open.
- Gate equation environment + expanded formal properties + edge samples.
- Figures: monorepo architecture, discourse layers, bands+gate, synthetic τₛ/g walk.
- Module inventory with Status (Core / Lab / Spec); expanded appendix map.
- Scrutiny challenges C1–C3 with attack metrics.
- Related-work subsection (Feigenbaum, Lean/Mathlib, EWS + critical caution).
- Appendix A: release note v0.1.7 → v0.1.8.
- Consistent macros `\taus`, `\taust`, `\tauch`, `\deltaop`.
- Layout fixes for band labels and float placement (r2 polish).

Frozen PDF: `pins/standard-formal-v0.1.8-r2.pdf` (superseded by r3).

## 0.1.8-r1 — 2026-07-24

First printable English draft aligned to software v0.1.8 (pre-feedback integration).
Not retained as a separate binary pin; superseded by r2.
