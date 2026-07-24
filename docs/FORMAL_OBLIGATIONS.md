# Formal obligations map (Feigenbaum + RECD)

**Purpose.** Single-page honesty board for peer scrutiny and for the next Zenodo
version note: what Lean **checks**, what is **bookkeeping**, what is a
**cited construction**, and what remains research-scale (logistic ID / Mathlib C²).

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
| **✓ construction** | Named cited construction (geometric cascade, tent lab, lookupTent). |
| **○ open / research-scale** | Logistic identification, Mathlib C² universality, field empirics. |
| **spec only** | Ontology / philosophy encoded as types; not mathematical necessity. |

**Forbidden moves (project policy):**

- Claiming tent *is* τₛ dynamics (lab only).  
- Closing cascade → Feigenbaum δ with the toy arithmetic progression.  
- Claiming geometric cascade *is* the logistic superstable sequence.  
- Collapsing dengue lead times or RECD bands into Lean theorems.  
- Treating ε–N ↔ `Tendsto` as classical Feigenbaum universality.

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
| 2† | *If* continuum return = tent map ⇒ strong + quadratic | `goal_2_when_return_is_tent` | ✓ conditional lab only |

### 3.2 Cited constructions (zero `sorry`, zero research `axiom`)

Full map: [`FEIGENBAUM_AXIOMS.md`](FEIGENBAUM_AXIOMS.md).

| ID | Statement (short) | Declaration | Status |
|----|-------------------|-------------|--------|
| **1b** | Continuum realizer if functional + in band | `open_ordinal_induces_continuum_return` | ✓ `lookupTent` |
| **1b∅** | Empty pairs → tent continuum | `open_ordinal_induces_continuum_return_empty` | ✓ construction |
| **2** | ∃ continuum strong return (lab) | `open_return_strongly_unimodal` | ✓ tent continuum |
| **1b+2∅** | Joint empty pairs | `open_reduction_joint_empty_pairs` | ✓ tent |
| **1b+2†** | Joint when pairs agree with tent | `open_reduction_joint_when_tent_agrees` | ✓ tent |
| **3 pkg** | Refined `FeigenbaumUniversal` (band + quadratic) | `open_analytic_feigenbaum` | ✓ refined |
| **★** | Composite lab package from H | `coherence_return_map_feigenbaum` | ✓ tent + pkg |

```text
          ReductionHypotheses H
                   │
          ┌────────┴────────┐
          ▼                 ▼
     1b ✓ lookupTent    2 ✓ tent lab
     (func+band)        (not ∀ C)
          │                 │
          └────────┬────────┘
                   ▼
            3 ✓ FeigenbaumU
            (band + quadratic)
                   ▼
            ★ ✓ lab composite
```

**1a vs 1b (do not confuse):**

| | 1a | 1b |
|--|----|----|
| Input | Finite list of pairs + `IsFunctional` | Same + pairs in coherence band |
| Output | Some total \(R:\mathbb{Q}\to\mathbb{Q}\) | `ContinuumReturnMap` via `lookupTent` |
| Status | ✓ | ✓ construction |
| Content | Graph theory / lookup | Continuum package (not full dynamical τₛ) |

---

## 4. Analytic / Real track (goal 3 refinements)

| ID | Statement | Module | Status |
|----|-----------|--------|--------|
| A | Cascade / scaling / rational ε–N interfaces | `FeigenbaumAnalytic` | ✓ encoded |
| A¬ | Toy arithmetic cascade **does not** approach δ (ε–N) | `toy_not_cascadeDeltaLimit_feigenbaum` | ✓ honesty |
| A3a | **∃** cascade → δ (ε–N) | `geometricFeigenbaumCascade` / `open_cascade_ratios_to_delta` | ✓ construction |
| A3b | **∃** non-empty class sharing δ | geometric singleton class | ✓ construction |
| A3c | Bridge → refined `FeigenbaumUniversal` | `open_bridge_to_feigenbaum_universal` | ✓ refined |
| A+ | Package with cascade witness | `FeigenbaumUniversalWithCascade` | ✓ Type |
| R | `scalingRatioReal`, `cascadeDeltaLimitTendsto` | `FeigenbaumTendsto` | ✓ encoded |
| B | ε–N ↔ `Tendsto` for the cast sequence | `cascadeDeltaLimit_iff_tendsto` | ✓ bookkeeping |
| R¬ | Toy cascade **does not** tend to Feigenbaum δ (`Tendsto`) | `toy_not_cascadeApproachesFeigenbaumDelta` | ✓ honesty |
| R3a–c | ∃ form + class + bridge (`Tendsto`) | geometric + B | ✓ construction |

Bookkeeping **B** equates two *interfaces*. Geometric construction proves ∃ cascade with exact ratio δ_op; **not** logistic identification.

**Honesty blocks:** A¬ / R¬ — toy is **not** a witness. 3a is **∃ B**, never ∀ B.

---

## 5. What remains research-scale (non-binding)

| Goal | Next classical step | Already done (do not re-claim) |
|------|---------------------|--------------------------------|
| 1b dynamical | Canonical continuum return of τₛ from ordinal+smooth | lookupTent / empty tent |
| 2 dynamical | That *that* R is strongly unimodal | tent lab shape |
| 3 classical | Logistic cascade → δ; Mathlib C² universality | geometric ratios ≡ δ_op |
| ★ dynamical | Compose true 1b–3 without lab substitution | lab composite package |

`FeigenbaumUniversal` fields are **refined** (operational band + quadratic tip).
Cascade witness: `FeigenbaumUniversalWithCascade`.

---

## 6. Empirical / community obligations (not Lean)

| Item | Status |
|------|--------|
| Aedes field under `data/aedes/raw/` (SJU1/2/3 2018) | ✓ CSV + nb 07 |
| P3 on field Aedes (ρ≤0.20, no re-fit) | ✓ nb 08 + tests |
| P1 with pre-registered `endpoints.json` | ○ scaffold only (example file) |
| P4 field scan on SJU1–3 (structure vs baselines) | ✓ nb 09 + tests; **no strong-anti premise** on 2018 matrices (honest) |
| Unified empirical board (P1/P3/P4) + multi-year raw intake | ✓ nb 10 + recursive `raw/**/*.csv` |
| More years/sites (anti-regime windows for true P4 discharge) | ○ pending (drop CSVs under `raw/YYYY/`) |
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
cd lean && lake build          # expect PASS; no sorry, no research axiom
cd ../python && pytest -q      # golden + protocol tests
```

Expect **no** `sorry` and **no** Lean `axiom` under `lean/SystemicTau/`.
(Legacy *theorem* names `ax_exists_feigenbaum_cascade` / `ax_feigenbaum_class_cascades`
are proved aliases of the geometric construction.)

---

## 9. Changelog of formal honesty (high level)

| Milestone | Formal honesty note |
|-----------|---------------------|
| v0.1.4–0.1.6 | Gate, bands, first-return skeleton, C3 synth, simple \(f(\delta)\) non-ids |
| **v0.1.7** | Mathlib; Analytic + Tendsto interfaces; ε–N↔Tendsto; goals 1a/2a/C∘; this map |
| post-v0.1.7 formal pack | Goal 2 tent-conditional; toy ↛ δ (ε–N + Tendsto); class-share Prop de-vacuous |
| **zero-sorry pack** | Former sorrys → named axioms + corollaries |
| **construction pack** | All 3 axioms discharged; `FeigenbaumUniversal` refined; geometric cascade |
| **Still not claimed** | Logistic ID of cascade; Mathlib C² Feigenbaum; field dengue; unique \(\tau_{\mathrm{ch}}\) |

Last updated: 2026-07-24 (**zero `sorry`**, **zero research `axiom`**; cited constructions).
