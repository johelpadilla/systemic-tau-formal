# Formal obligations map (Feigenbaum + RECD)

**Purpose.** Single-page honesty board for peer scrutiny and for Zenodo version
notes: what Lean **checks**, what is **bookkeeping**, what is a **cited
construction / lab package**, and what remains **research-scale**.

**Epistemic labels:** [`EPISTEMIC_LABELS.md`](EPISTEMIC_LABELS.md) ·  
**Live module status:** [`../STATUS.md`](../STATUS.md) ·  
**Feigenbaum narrative (canonical table):** [`FEIGENBAUM_STATUS.md`](FEIGENBAUM_STATUS.md) ·  
**Construction map:** [`FEIGENBAUM_AXIOMS.md`](FEIGENBAUM_AXIOMS.md) ·  
**Mathlib / Tendsto:** [`MATHLIB.md`](MATHLIB.md)

**Published archive:** **v0.1.9** — DOI [10.5281/zenodo.21536462](https://doi.org/10.5281/zenodo.21536462) · concept [10.5281/zenodo.21516059](https://doi.org/10.5281/zenodo.21516059)  
**Prior pin (v0.1.7):** [10.5281/zenodo.21522346](https://doi.org/10.5281/zenodo.21522346)  
**Prior pin (v0.1.6):** [10.5281/zenodo.21516523](https://doi.org/10.5281/zenodo.21516523)  

**`main` / v0.1.9 content:** zero `sorry`, zero research `axiom`;
logistic **scale-ID**, C²/Schwarzian algebra, **non-tent** τₛ lab return (see §7.2).

---

## 1. What “proved” means here

| Tag | Meaning |
|-----|---------|
| **✓ theorem** | `lake build` accepts a completed proof (no `sorry` in that decl). |
| **✓ bookkeeping** | Interface equivalence or discrete graph fact; **not** the preprint’s dynamical claim. |
| **✓ inhabited / example** | Structure exists (e.g. tent map); **not** “τₛ dynamics are a tent”. |
| **✓ construction** | Named cited construction (geometric cascade, `lookupTent`, tent/tau lab). |
| **✓ identification** | Scale-level ID of two cascades (ratios); **not** termwise superstable roots. |
| **✓ algebra** | Formal derivatives / Schwarzian identities on the logistic polynomial. |
| **○ open / research-scale** | True superstable roots; Mathlib C²-open renorm; field-derived return; unique \(\tau_{\mathrm{ch}}=f(\delta)\). |
| **spec only** | Ontology / philosophy encoded as types; not mathematical necessity. |

**Forbidden moves (project policy):**

- Claiming tent *is* τₛ dynamics (lab only).  
- Claiming `tauReturnF` is *derived* from ordinal ranks alone (lab conjugacy).  
- Closing cascade → Feigenbaum δ with the toy arithmetic progression.  
- Claiming geometric / logistic-anchored cascade *is* the logistic superstable sequence termwise.  
- Collapsing dengue lead times or RECD bands into Lean theorems.  
- Treating ε–N ↔ `Tendsto` as classical Feigenbaum universality.  
- Describing discharged constructions as “honest `sorry`” (that language is **obsolete** post zero-sorry pack).

---

## 2. Operational core (RECD / bands) — largely closed

| Obligation | Lean / Python | Status |
|------------|---------------|--------|
| Window / Kendall interface | `Basic.lean`, `python/core/tau.py` | ✓ interface + Python |
| Bands τ_st = 1/2, τ_ch operational | `Thresholds.lean`, golden tests | ✓ operational + lemmas |
| Gate \(g\) laws (stable / chaotic / anti-sync) | `RECD.lean` | ✓ theorem |
| Nonneg trichotomy / asymmetry of gate | docs + tests + Lean | ✓ |
| Finite simple \(f(\delta)=\tau_{\mathrm{ch}}\) candidates | `failedSimpleCandidates` (10 forms) | ✓ non-identity |
| Unique inverse-scale \(f(\delta)=c/\delta\) at pin | `ThresholdFromDelta` | ✓ uniqueness in class |
| Classical free-\(c\) derivation of \(\tau_{\mathrm{ch}}\) | — | ○ open (research-scale) |

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
| L | Logistic (and conjugacy) strong unimodal | `logisticStrong` / `tauReturnFourStrong` | ✓ non-tent example |
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
Live table: [`FEIGENBAUM_STATUS.md`](FEIGENBAUM_STATUS.md).

| ID | Statement (short) | Declaration | Status |
|----|-------------------|-------------|--------|
| **1b** | Continuum realizer if functional + in band | `open_ordinal_induces_continuum_return` | ✓ `lookupTent` |
| **1b∅** | Empty pairs → continuum | `open_ordinal_induces_continuum_return_empty` | ✓ construction |
| **2** | ∃ continuum strong return (tent lab) | `open_return_strongly_unimodal` | ✓ tent continuum |
| **2τ** | ∃ continuum strong return (**non-tent**) | `open_return_strongly_unimodal_tau` | ✓ `tauReturnFourContinuum` |
| **1b+2∅** | Joint empty pairs | `open_reduction_joint_empty_pairs` | ✓ tent / lab |
| **1b+2†** | Joint when pairs agree with tent | `open_reduction_joint_when_tent_agrees` | ✓ tent |
| **3 pkg** | Refined `FeigenbaumUniversal` (band + quadratic) | `open_analytic_feigenbaum` | ✓ refined (**not** `True` placeholders) |
| **3 C²** | C² tip + Schwarzian ≤ 0 package | `FeigenbaumUniversalC2` | ✓ algebra (`FeigenbaumSchwarzian`) |
| **★** | Composite lab package from H | `coherence_return_map_feigenbaum` | ✓ **non-tent** `tauReturnFour` + refined pkg |
| **★ tent** | Alternate composite | `coherence_return_map_feigenbaum_tent` | ✓ tent retained |

```text
          ReductionHypotheses H
                   │
          ┌────────┴────────┐
          ▼                 ▼
     1b ✓ lookupTent    2 ✓ tent lab
     (func+band)        2τ ✓ tauReturn (logistic conjugacy)
          │                 │
          └────────┬────────┘
                   ▼
            3 ✓ FeigenbaumU (band + quadratic)
            3 C² ✓ FeigenbaumUniversalC2 (logistic)
                   ▼
            ★ ✓ lab composite (default: non-tent)
```

**1a vs 1b (do not confuse):**

| | 1a | 1b |
|--|----|----|
| Input | Finite list of pairs + `IsFunctional` | Same + pairs in coherence band |
| Output | Some total \(R:\mathbb{Q}\to\mathbb{Q}\) | `ContinuumReturnMap` via `lookupTent` |
| Status | ✓ | ✓ construction |
| Content | Graph theory / lookup | Continuum package (not full dynamical τₛ) |

---

## 4. Analytic / Real / logistic track (goal 3 refinements)

| ID | Statement | Module | Status |
|----|-----------|--------|--------|
| A | Cascade / scaling / rational ε–N interfaces | `FeigenbaumAnalytic` | ✓ encoded |
| A¬ | Toy arithmetic cascade **does not** approach δ (ε–N) | `toy_not_cascadeDeltaLimit_feigenbaum` | ✓ honesty |
| A3a | **∃** cascade → δ (ε–N) | `geometricFeigenbaumCascade` / `open_cascade_ratios_to_delta` | ✓ construction |
| A3b | **∃** non-empty class sharing δ | geometric (+ logistic-anchored) class | ✓ construction |
| A3c | Bridge → refined `FeigenbaumUniversal` | `open_bridge_to_feigenbaum_universal` | ✓ refined |
| A+ | Package with cascade witness | `FeigenbaumUniversalWithCascade` | ✓ Type |
| L-ID | Logistic-anchored cascade scale-ID with geometric | `FeigenbaumLogistic` / `logistic_scale_identified_geometric` | ✓ **identification** (not superstable roots) |
| L-δ | Same δ_op limit for logistic-anchored cascade | `logistic_cascadeDeltaLimit` | ✓ construction |
| S | Formal \(f',f'',f'''\); Schwarzian ≤ 0 off critical point | `FeigenbaumSchwarzian` | ✓ algebra |
| R | `scalingRatioReal`, `cascadeDeltaLimitTendsto` | `FeigenbaumTendsto` | ✓ encoded |
| B | ε–N ↔ `Tendsto` for the cast sequence | `cascadeDeltaLimit_iff_tendsto` | ✓ bookkeeping |
| R¬ | Toy cascade **does not** tend to Feigenbaum δ (`Tendsto`) | `toy_not_cascadeApproachesFeigenbaumDelta` | ✓ honesty |
| R3a–c | ∃ form + class + bridge (`Tendsto`) | geometric + B | ✓ construction |

Bookkeeping **B** equates two *interfaces*. Geometric construction proves ∃ cascade with exact ratio δ_op.  
**L-ID** proves the logistic-*anchored* chart shares those ratios — **not** that \(r_n\) are classical superstable parameters.

**Honesty blocks:** A¬ / R¬ — toy is **not** a witness. 3a is **∃ B**, never ∀ B.

---

## 5. What remains research-scale (non-binding)

Aligned with [`FEIGENBAUM_STATUS.md`](FEIGENBAUM_STATUS.md) “Next classical steps”:

| Goal | Next classical step | Already done (do not re-claim as open `sorry`) |
|------|---------------------|-----------------------------------------------|
| 1b dynamical | Canonical continuum return of τₛ from ordinal+smooth *field* data | `lookupTent` / empty continuum; **non-tent** lab continuum |
| 2 dynamical | That *that* field return is strongly unimodal | tent lab + **tauReturn** lab shape |
| 3 classical | **Termwise** logistic superstable roots; Mathlib C²-open renorm | geometric ratios ≡ δ_op; **scale-ID**; Schwarzian algebra + `FeigenbaumUniversalC2` |
| ★ dynamical | Compose true field 1b–3 without lab substitution | lab composite package (**non-tent** default) |

`FeigenbaumUniversal` fields are **refined** (operational band + quadratic tip).  
Cascade witness: `FeigenbaumUniversalWithCascade`.  
C² package: `FeigenbaumUniversalC2`.

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

## 7. Zenodo version notes

### 7.1 Published — v0.1.7 (historical; do not edit the deposit)

Adapted into `zenodo/metadata.json` for **v0.1.7**:

> **Formal track packaged as v0.1.7.**  
> Mathlib 4.14 wired; Feigenbaum cascade interfaces (ε–N) and Real/`Tendsto` shapes encoded.  
> Proved bookkeeping: rational ε–N ↔ metric `Tendsto` for cast scaling ratios; functional finite Poincaré pairs admit a total realizer (goal 1a); strong unimodality implies quadratic location (goal 2a); composite package under granted continuum+strong+universal hypotheses.  
> **At deposit time, still open as `sorry`:** dynamical continuum return from ordinal+smooth (1b), strong unimodality of that return (2), Feigenbaum δ universality (3), and the composite from hypotheses alone.  
> Operational RECD gate and band lemmas remain machine-checked. Unique \(\tau_{\mathrm{ch}}=f(\delta)\) remains open beyond finite simple non-identities.

That paragraph is **true of the v0.1.7 tarball**. It is **not** a description of current `main`.

### 7.2 Draft for next pin — v0.1.8 (working tree; not yet deposited)

Use this (or a close paraphrase) in `zenodo/metadata.json` when cutting **v0.1.8**:

> **Formal track update v0.1.8 (post-v0.1.7 packs on `main`).**  
> Zero `sorry` and zero research `axiom` under `SystemicTau/`. Former open goals are discharged only as **named cited constructions / laboratory packages**, not as classical dynamical theorems from bare ordinal+smooth hypotheses.  
> **Reduction:** continuum realizers via `lookupTent`; tent lab continuum (goal 2); **non-tent** continuum return `tauReturnFour` (logistic conjugacy on the coherence interval); composite ★ uses the non-tent return + refined `FeigenbaumUniversal` (operational δ-band + quadratic tip). Tent composite retained as alternate.  
> **Analytic:** geometric cascade with exact ratio δ_op; ε–N ↔ `Tendsto` bookkeeping; toy cascade honesty blocks (does **not** approach δ).  
> **Logistic scale-ID:** logistic-anchored parameter sequence shares ratios with the geometric model (landmarks \(r_0=2\), \(r_1=3\)); **not** termwise identification with classical superstable roots.  
> **C² / Schwarzian:** formal derivatives of the logistic map; `HasC2QuadraticTip`; Schwarzian ≤ 0 off the critical point; `FeigenbaumUniversalC2` package. **Not** Mathlib C²-open renormalization / universality.  
> **Still research-scale:** termwise superstable logistic roots; Mathlib renorm fixed point; field-derived τₛ return; unique closed-form \(\tau_{\mathrm{ch}}=f(\delta)\); stronger empirical P1/P4 multi-site discharge.  
> Operational RECD gate and band lemmas remain machine-checked.

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
| **v0.1.7** (Zenodo) | Mathlib; Analytic + Tendsto interfaces; ε–N↔Tendsto; goals 1a/2a/C∘; this map **as of deposit** (1b–3/★ still `sorry` then) |
| post-v0.1.7 formal pack | Goal 2 tent-conditional; toy ↛ δ (ε–N + Tendsto); class-share Prop de-vacuous |
| **zero-sorry pack** | Former sorrys → named axioms + corollaries |
| **construction pack** | All research axioms discharged; `FeigenbaumUniversal` refined; geometric cascade |
| **logistic + C² + non-tent pack** (`6e386c9` era) | Scale-ID (`FeigenbaumLogistic`); Schwarzian (`FeigenbaumSchwarzian`); ★ default = `tauReturnFour` |
| **Still not claimed** | Termwise superstable roots; Mathlib C² Feigenbaum renorm; field-derived return; unique \(\tau_{\mathrm{ch}}\); field dengue beyond current P3/P4 scan |

Last updated: 2026-07-24 (docs aligned with `FEIGENBAUM_STATUS`: zero `sorry`/axiom; L-ID + C² + non-tent ★; §7 splits v0.1.7 historical vs v0.1.8 draft).
