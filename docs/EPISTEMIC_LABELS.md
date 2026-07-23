# Epistemic labels (mandatory)

Every document, notebook cell group, issue, and Lean docstring in this repository **must** mark claim type. Mixing levels is a bug.

| Label | Meaning | Allowed moves |
|-------|---------|-----------------|
| `[TEOREMA]` | Formally proved (Lean) or classically proved with complete proof in `papers/` | Cite proof; machine-check when Lean ready |
| `[CONJETURA]` | Plausible, stated for attack; not proved | Seek counterexample or proof |
| `[INTERPRETACIÓN FÍSICA]` | Model of the world / measurement story | Test on data; may fail without killing pure math |
| `[AFIRMACIÓN ONTOLÓGICA]` | Philosophical thesis (levels of being, Polo homology, etc.) | Philosophical critique; not refuted by one CSV |
| `[OPERACIONAL]` | Convention used for computation (window size, band edges as defaults) | May be revised with documented protocol |
| `[EMPÍRICO]` | Claim about a dataset or domain (lead times, dengue, finance) | Replication / domain transfer |

## Minimal example

```text
[OPERACIONAL] Default chaotic band: |τₛ| < 0.41
[TEOREMA]     (target) Unimodal quadratic return map ⇒ Feigenbaum universality
[EMPÍRICO]    Lead time 4–6 weeks before observable critical transition (domain-dependent)
[AFIRMACIÓN ONTOLÓGICA] RECD as discrete extramental clock homologous to efficient causality (Polo)
```

## Forbidden collapses

- Do **not** write “proved by dengue data” for a mathematical theorem.
- Do **not** write “δ is Polo’s efficient cause.”
- Do **not** claim Lean has proved a statement that still contains `sorry`.
