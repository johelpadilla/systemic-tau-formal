# Systemic Tau Stress-Test 2026 — workshop brief

**Status:** public invitation · **Repo version:** v0.1.6+  
**Concept DOI:** [10.5281/zenodo.21516059](https://doi.org/10.5281/zenodo.21516059)  
**Labels:** organization is `[OPERACIONAL]`; outcomes of attacks are `[EMPÍRICO]` / `[TEOREMA]` / philosophy as appropriate.

## 1. Purpose

A **48-hour destruction workshop** (async or hybrid) whose success metric is *not* confirmation of Systemic Tau, but:

1. **Failed predictions** recorded with protocol evidence  
2. **False-positive** early-warning systems under pre-agreed endpoints  
3. **Formal gaps** pressure-tested (especially Feigenbaum open goals)  
4. **Philosophical** challenges that do not collapse epistemic labels  

If nothing breaks, that is a *weak* result. Prefer clear falsifications over polite agreement.

## 2. Tracks

| Track | Focus | Primary docs | Issue label |
|-------|--------|--------------|-------------|
| **A — Dynamics** | τₛ / RECD as early-warning machinery | `EXPERIMENTAL_PROTOCOL.md`, notebooks 01–04 | `contradiction`, `new-domain` |
| **B — Formal** | Lean statements, `sorry` honesty, gate lemmas | `STATUS.md`, `FEIGENBAUM_STATUS.md`, `lean/` | `improvement` |
| **C — Philosophy** | Ontology, Polo, Baron’s trilemma | `ONTOLOGY_BRIDGE.md`, `EPISTEMIC_LABELS.md` | `philosophy-challenge` |

Cross-cutting challenges **C1–C3** live in [`CHALLENGES.md`](CHALLENGES.md).

## 3. Pre-registration (before looking at results)

Each team files a short issue or PR comment with:

| Field | Required |
|-------|----------|
| Track (A/B/C) | yes |
| Endpoint definition (if empirical) | yes for A |
| Window \(w\), stride, software commit | yes for A |
| Null / surrogate plan | yes for A |
| Which of P1–P4 or C1–C3 is targeted | yes |
| Lean claim + file if formal | yes for B |

Templates: `.github/ISSUE_TEMPLATE/`.

## 4. Suggested 48h schedule (async-friendly)

| Block | Hours (local) | Activity |
|-------|----------------|----------|
| **T0** | 0–2 | Clone v0.1.6+, run `pytest` + optional `lake build`; pick track |
| **T1** | 2–8 | Reproduce notebook 01 + 04 (P3) or tent Feigenbaum module |
| **T2** | 8–24 | Attack: own data / surrogate / domain transfer / formal gap note |
| **T3** | 24–36 | Write protocol §7 report or Lean PR sketch |
| **T4** | 36–48 | Open issues with label; optional short talk abstract (≤300 words) |

In-person variant: same blocks condensed with evening synthesis.

## 5. Minimum viable attack kits

### Track A (no Lean required)

```bash
git clone https://github.com/johelpadilla/systemic-tau-formal.git
cd systemic-tau-formal/python && pip install -e ".[dev]" && pytest -q
cd ..
python notebooks/01_synthetic_chaos.py
python notebooks/04_p3_noise_robustness.py
python notebooks/03_falsifiability_test.py data/synthetic/regime_switch.csv
# then: your.csv under EXPERIMENTAL_PROTOCOL.md
```

Binder: badge on README (first build may take minutes).

### Track B

```bash
# elan + Lean 4.14
export PATH="$HOME/.elan/bin:$PATH"
cd lean && lake build
# read docs/FEIGENBAUM_STATUS.md — do not close sorry by swapping tent map
```

### Track C

Read `docs/EPISTEMIC_LABELS.md` + `docs/ONTOLOGY_BRIDGE.md`.  
Submit a critique that **names which horn** of Baron’s trilemma is allegedly reintroduced.

## 6. Success criteria (what we accept as “hit”)

| Claim class | Accepted as hit if… |
|-------------|---------------------|
| P1–P4 | Pre-registered endpoint + protocol checklist + public code/data license |
| C1 | Systematic false positives vs agreed baseline (not one cherry-picked window) |
| C2 | New statement + numerical or formal check; not restating δ ≈ 4.669 |
| Lean | Points to a wrong lemma, missing hypothesis, or invalid `sorry` discharge |
| Philosophy | Engages levels without treating ontology as theorem or dengue as proof |

## 7. Non-goals of the workshop

- Marketing confirmation tours  
- Replacing domain validation with Lean builds  
- Claiming dengue lead times as theorems  
- Closing Feigenbaum open goals without real analysis / Mathlib work  

## 8. Outputs

1. GitHub issues under the labels above  
2. Optional PRs (tests, docs, Lean lemmas)  
3. Optional one-page abstracts → collect in `papers/workshop-2026/` (after event)  
4. Maintainers update `STATUS.md` / `ROADMAP.md` only for machine-checked or protocol-grade hits  

## 9. Citation

Cite the monorepo version you attacked:

- Concept / latest: [10.5281/zenodo.21516059](https://doi.org/10.5281/zenodo.21516059)
- v0.1.5: [10.5281/zenodo.21516329](https://doi.org/10.5281/zenodo.21516329)  
- Concept (latest): [10.5281/zenodo.21516059](https://doi.org/10.5281/zenodo.21516059)  

## 10. Contact / hosting

Primary venue: **this GitHub repository** (issues + PRs).  
In-person host / date: *TBD* — open a discussion or issue titled `[workshop] logistics`.

---

*This brief is an invitation to scrutiny, not a claim that the framework has survived it.*
