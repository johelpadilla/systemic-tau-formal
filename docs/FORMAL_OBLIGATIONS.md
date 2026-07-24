# Formal obligations map (Feigenbaum + RECD)

**Purpose.** Single-page honesty board for peer scrutiny and for the next Zenodo
version note: what Lean **checks**, what is **bookkeeping**, and what remains
**research-open** (`sorry`).

**Epistemic labels:** [`EPISTEMIC_LABELS.md`](EPISTEMIC_LABELS.md) ·  
**Live module status:** [`../STATUS.md`](../STATUS.md) ·  
**Feigenbaum narrative:** [`FEIGENBAUM_STATUS.md`](FEIGENBAUM_STATUS.md) ·  
**Mathlib / Tendsto:** [`MATHLIB.md`](MATHLIB.md)

**Release:** **v0.1.7** packages this map + the formal track on `main` (Mathlib → Tendsto → 1a/2a → obligations).  
**DOI (v0.1.7):** [10.5281/zenodo.21522346](https://doi.org/10.5281/zenodo.21522346)  
**Concept DOI:** [10.5281/zenodo.21516059](https://doi.org/10.5281/zenodo.21516059)  
**Prior pin (v0.1.6):** [10.5281/zenodo.21516523](https://doi.org/10.5281/zenodo.21516523)

---

## 1. What “proved” means here

| Tag | Meaning |
|-----|---------|
| **✓ theorem** | `lake build` accepts a completed proof (no `sorry` in that decl). |
| **✓ bookkeeping** | Interface equivalence or discrete graph fact; **not** the preprint’s dynamical claim. |
| **✓ inhabited / example** | Structure exists (e.g. tent map); **not** “τₛ dynamics are a tent”. |
| **○ open** | Named `sorry` or missing empirical artifact; research or data. |
| **spec only** | Ontology / philosophy encoded as types; not mathematical necessity. |

**Forbidden moves (project policy):**

- Closing goal 1b/2/3 by substituting the tent map under arbitrary hypotheses.  
- Closing cascade → Feigenbaum δ with the toy arithmetic progression.  
- Collapsing dengue lead times or RECD bands into Lean theorems.  
- Treating ε–N ↔ `Tendsto` as a Feigenbaum universality proof.

---

## 2. Operational core (RECD / bands) — largely closed

| Obligation | Lean / Python | Status |
|------------|---------------|--------|
| Window / Kendall interface | `Basic.lean`, `python/core/tau.py` | ✓ interface + Python |
| Bands τ_st = 1/2, τ_ch operational | `Thresholds.lean`, golden tests | ✓ operational + lemmas |
| Gate \(g\) laws (stable / chaotic / anti-sync) | `RECD.lean` | ✓ theorem |
| Nonneg trichotomy / asymmetry of gate | docs + tests + Lean | ✓ |
| Finite simple \(f(\delta)=\tau_{\mathrm{ch}}\) candidates | `failedSimpleCandidates` | ✓ non-identity (not full uniqueness) |
| Unique closed-form \(\tau_{\mathrm{ch}}=f(\delta)\) | — | ○ open (medium term) |

---

## 3. Feigenbaum reduction — obligation DAG

Preprint target (informal):

> Ordinal observability + generic smoothness  
> ⇒ continuum first-return of coherence is strongly unimodal with quadratic tip  
> ⇒ Feigenbaum universality package.

### 3.1 Discrete / conditional (✓)

| ID | Statement (short) | Declaration | Class |
|----|-------------------|-------------|--------|
| T | Tent map strongly unimodal on \([-1,1]\) | `tentStrong` | ✓ example |
| T2 | Tent period-2 orbit \(1/4\leftrightarrow 3/4\) | `tentF_quarter_period2` | ✓ example |
| Q | Strongly unimodal ⇒ interior critical location | `stronglyUnimodal_has_quadratic` | ✓ theorem |
| Q′ | Same under `PreprintReturnSetup` | `conditional_quadratic_from_setup` | ✓ theorem |
| FR | Combinatorial section + `returnPairs` | `FirstReturnData`, … | ✓ definitions |
| 1a | Functional finite pairs admit a total realizer | `exists_realizer_of_functional` | ✓ bookkeeping |
| 2a | Strong unimodal + same map as continuum ⇒ quadratic location | `goal_2a_quadratic_of_strong` | ✓ bookkeeping |
| C∘ | If continuum + strong \(U\) + `FeigenbaumUniversal`, composite package | `coherence_return_map_feigenbaum_of` | ✓ bookkeeping |

### 3.2 Research open (`sorry`)

| ID | Statement (short) | Declaration | Why hard |
|----|-------------------|-------------|----------|
| **1b** | Ordinal + smooth induce a *dynamical* continuum return realizing Poincaré pairs | `open_ordinal_induces_continuum_return` | Not mere interpolation (1a); needs a construction from the hypotheses |
| **2** | That continuum return is strongly unimodal | `open_return_strongly_unimodal` | Dynamics / genericity |
| **3** | Unimodal + quadratic tip ⇒ Feigenbaum package | `open_analytic_feigenbaum` | Classical analysis / renormalization |
| **★** | Composite from `ReductionHypotheses` alone | `coherence_return_map_feigenbaum` | Conjunction of 1b–3 |

```text
          ReductionHypotheses H
                   │
                   ▼
            ┌──── 1b ○ ────┐
            │ continuum R  │
            └──────┬───────┘
                   ▼
            ┌──── 2 ○ ─────┐     ┌── 2a ✓ ──┐
            │ StronglyUni  │────►│ quadratic │
            └──────┬───────┘     └───────────┘
                   ▼
            ┌──── 3 ○ ─────┐
            │ FeigenbaumU  │
            └──────┬───────┘
                   ▼
              ★ composite ○
         (C∘ ✓ if 1b–3 granted)
```

**1a vs 1b (do not confuse):**

| | 1a | 1b |
|--|----|----|
| Input | Finite list of pairs + `IsFunctional` | `ReductionHypotheses` + series + section |
| Output | Some total \(R:\mathbb{Q}\to\mathbb{Q}\) | Continuum return map on coherence |
| Status | ✓ | ○ |
| Content | Graph theory / lookup | Dynamical claim of the preprint |

---

## 4. Analytic / Real track (goal 3 refinements)

| ID | Statement | Module | Status |
|----|-----------|--------|--------|
| A | Cascade / scaling / rational ε–N interfaces | `FeigenbaumAnalytic` | ✓ encoded |
| A3a–c | Cascade → δ; class; bridge (ε–N form) | same | ○ `sorry` |
| R | `scalingRatioReal`, `cascadeDeltaLimitTendsto` | `FeigenbaumTendsto` | ✓ encoded |
| B | ε–N ↔ `Tendsto` for the cast sequence | `cascadeDeltaLimit_iff_tendsto` | ✓ bookkeeping |
| R3a–c | Cascade → Feigenbaum δ; class; bridge (`Tendsto`) | same | ○ `sorry` |

Bookkeeping **B** equates two *interfaces*. It does **not** prove any physical cascade limits to \(\delta\approx 4.669\ldots\).

---

## 5. What a future discharge would look like (non-binding)

| Goal | Acceptable discharge path | Unacceptable |
|------|---------------------------|--------------|
| 1b | Cited construction: ordinal data + smoothness ⇒ unique/canonical continuum return; or reduced hypotheses with explicit axioms | `exact ⟨idContinuum, …⟩` under dummy `H` |
| 2 | Proof that that \(R\) is strongly unimodal (or generic in a Mathlib class) | Reuse `tentStrong` for arbitrary `C.R` |
| 3 | Import/formalize classical Feigenbaum (or restricted class) with citations | Toy cascade ratios → 1, or `True` placeholders filled with `trivial` while claiming δ |
| ★ | Compose 1b–3 via `coherence_return_map_feigenbaum_of` | Single `sorry` replaced by tent witness |

Placeholders still in `FeigenbaumUniversal` (`delta_limit : True`, `class_universal : True`) must be refined to real props (e.g. linked to `cascadeDeltaLimitTendsto`) **before** claiming analytic discharge.

---

## 6. Empirical / community obligations (not Lean)

| Item | Status |
|------|--------|
| Aedes field under `data/aedes/raw/` (SJU1/2/3 2018) | ✓ CSV + nb 07 |
| P3 on field Aedes (ρ≤0.20, no re-fit) | ✓ nb 08 + tests |
| P1 with pre-registered `endpoints.json` | ○ scaffold only (example file) |
| More years/sites + P4 field | ○ pending |
| C3 **field** results (not synthetic kits) | ○ pending |
| Workshop Stress-Test 2026 date / host | ○ issue #1 |
| P1–P4 on real series | ○ community |

Synthetic kits and proxy CSVs are **operational demos**, not field validation.

---

## 7. Zenodo version note (v0.1.7)

The following was adapted into `zenodo/metadata.json` for **v0.1.7**:

> **Formal track packaged as v0.1.7.**  
> Mathlib 4.14 wired; Feigenbaum cascade interfaces (ε–N) and Real/`Tendsto` shapes encoded.  
> Proved bookkeeping: rational ε–N ↔ metric `Tendsto` for cast scaling ratios; functional finite Poincaré pairs admit a total realizer (goal 1a); strong unimodality implies quadratic location (goal 2a); composite package under granted continuum+strong+universal hypotheses.  
> **Still open (honest `sorry`):** dynamical continuum return from ordinal+smooth (1b), strong unimodality of that return (2), Feigenbaum δ universality (3), and the composite from hypotheses alone.  
> Operational RECD gate and band lemmas remain machine-checked. Unique \(\tau_{\mathrm{ch}}=f(\delta)\) remains open beyond finite simple non-identities.

---

## 8. How to re-verify

```bash
export PATH="$HOME/.elan/bin:$PATH"
cd lean && lake build          # expect PASS + sorry warnings on open goals
cd ../python && pytest -q      # golden + protocol tests
```

Open goal names to grep:

```text
open_ordinal_induces_continuum_return
open_return_strongly_unimodal
open_analytic_feigenbaum
coherence_return_map_feigenbaum
open_cascade_ratios_to_delta
open_cascade_tendsto_feigenbaum_delta
```

---

## 9. Changelog of formal honesty (high level)

| Milestone | Formal honesty note |
|-----------|---------------------|
| v0.1.4–0.1.6 | Gate, bands, first-return skeleton, C3 synth, simple \(f(\delta)\) non-ids |
| **v0.1.7** | Mathlib; Analytic + Tendsto interfaces; ε–N↔Tendsto; goals 1a/2a/C∘; this map |
| **Still not claimed** | Full Feigenbaum reduction; field dengue; unique \(\tau_{\mathrm{ch}}\) |

Last updated: 2026-07-23 (shipped with **v0.1.7**).
