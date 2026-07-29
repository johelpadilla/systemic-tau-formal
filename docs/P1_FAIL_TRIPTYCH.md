# P1 Fail-Triptych — instrument, field residual, C1 stress

**Document ID:** `P1_FAIL_TRIPTYCH`  
**Date:** 2026-07-28  
**Claim class:** `[OPERACIONAL]` synthesis — not a new experiment  
**Frozen detector (all faces):** \(w=13\), \(\theta_{\mathrm{ch}}=0.41\), `min_run=4`,  
\(t^*=\) `first_sustained_chaos_ascent`, lead window \([4,6]\), C1 horizon \(H=13\)

This note closes the **honest reading** of the P1 program after synthetic instrument
validation and multi-domain empirical runs. It does **not** retune parameters,
discharge dengue/flu/EEG early warning, or invent a new protocol version.

---

## 0. One-line verdict

| Face | Verdict | What it proves |
|------|---------|----------------|
| **I — Instrument (synthetic plant)** | **PASS** | Scorer recovers a known order→chaos break under ideal plant |
| **II — Field residual** | **FAIL / residual** | Same scorer does not deliver multi-domain EWS on real panels |
| **III — C1 ambient stress** | **FAIL (C1C)** | Chaos-band \(t^*\) is not deployable as alert without a regime guard |

**Composite:** P1 is a **working transition detector under clean plant**, not a
**robust early-warning system** under ambient chaos or heterogeneous field regimes.

`INSTRUMENT_PASS` ≠ paradigm discharged in nature.  
`C1_STRESS_FAIL` ≠ broken plant test.  
Empirical 0/N ≠ evidence that the scorer code is wrong.

---

## 1. Face I — Instrument (synthetic canonical)

| Item | Result | Source |
|------|--------|--------|
| Protocol | `P1_SYNTHETIC_CANONICAL` v1.0.0 | [`P1_SYNTHETIC_CANONICAL.md`](P1_SYNTHETIC_CANONICAL.md) |
| G1–G4 | **INSTRUMENT_PASS** | `data/synthetic/p1_canonical/last_gates.json` |
| Plant hit-rate | **20/20 (1.00)** | lead median **4** ∈ [4, 6] |
| Detection lag | median **9** after \(t_{\mathrm{switch}}\) | structural (\(w=13\)) |
| pure_sync (P1) | 10/10 `no_signal` | G3 |
| pure_noise (P1 lead score) | 10/10 `miss_lead` | G4 (mid \(t_{\mathrm{obs}}\)) |

**Interpretation:** Under an a priori plant (ordered seasonal → independent noise at
\(t_{\mathrm{switch}}=40\); planted \(t_{\mathrm{obs}}=t_{\mathrm{switch}}+\varphi\), \(\varphi=w=13\)),
the frozen chaos-ascent rule **does** fire in the lead window. The instrument is not
broken for *known* desynchronization breaks.

**Does not mean:** field skill, clinical utility, or specificity under pure noise.

Report: [`P1_SYNTHETIC_CANONICAL_REPORT.md`](P1_SYNTHETIC_CANONICAL_REPORT.md).

---

## 2. Face II — Field residual (same frozen P1)

| Domain | Protocol | Primary score | Dominant failure mode | Report |
|--------|----------|---------------|----------------------|--------|
| **Aedes Vitória** | `P1_AEDES_EXTERNAL_TOBS` v1.0 | **0/5** yearly peaks | `miss_lead` | [`P1_AEDES_VITORIA_REPORT.md`](P1_AEDES_VITORIA_REPORT.md) |
| **ILI HHS → FluSurv** | `P1_ILI_EXTERNAL_TOBS` v1.0 | peak **0/10**; p75 **1/10** | mostly `no_signal` (no sustained chaos run) | [`P1_ILI_REPORT.md`](P1_ILI_REPORT.md) |
| **EEG CHB-MIT v1.0** | chaos polarity | **1/7**; C1 FP **42/42** | ambient chaos FP | [`P1_EEG_CHB01_PILOT_REPORT.md`](P1_EEG_CHB01_PILOT_REPORT.md) |
| **EEG CHB-MIT v1.1** | order polarity | **0/7**; C1 FP **27/42** | timing / weak specificity | [`P1_EEG_CHB01_PILOT_REPORT_v1.1.md`](P1_EEG_CHB01_PILOT_REPORT_v1.1.md) |

**San Juan 2018:** clinical null year — not a scorer FAIL; no usable \(t_{\mathrm{obs}}\).

**Reading of Face II:**

1. Failures are **heterogeneous** (no single bug):
   - Vitória: signal exists but **lead geometry** does not match [4, 6] vs external peaks.
   - ILI: often **no sustained chaos-band run** at \(\theta=0.41\) on the HHS panel.
   - EEG: **ambient chaos** (v1.0) or order-run timing without lead (v1.1).
2. Face I rules out “the scorer never works under any condition.”
3. Face II rules out “P1 is multi-domain EWS with these frozen params.”
4. EEG track is **paused** (2026-07-29); further field domains with the *same* freeze are
   low value unless \(t^*\) / endpoint / guard change **a priori**.

Board context: [`FIELD_EMPIRICAL_STATUS.md`](FIELD_EMPIRICAL_STATUS.md).

---

## 3. Face III — C1 companion (false early warnings)

Same plant/null matrices as Face I; different question:

> Given an alert at \(t^*\), is there a critical event in \((t^*, t^*+H]\)?

| Gate | Panel | Result | Detail |
|------|-------|--------|--------|
| **C1A** | plant | **PASS** | FP rate **0.0** (20/20 alerts justified) |
| **C1B** | pure_sync | **PASS** | alert rate **0.0** |
| **C1C** | pure_noise | **FAIL** | FP rate **1.0** (10/10 ambient chaos alerts) |
| **Verdict** | — | **C1_STRESS_FAIL** | artifact `last_c1.json` |

**Critical distinction (G4 ≠ C1C):**

| Question | pure_noise outcome |
|----------|-------------------|
| P1 G4: does lead hit mid-series \(t_{\mathrm{obs}}\)? | **No** → G4 PASS |
| C1C: does \(t^*\) fire with no event in horizon? | **Yes always** → C1C FAIL |

So: the instrument can **pass lead scoring** on noise while still being a **systematic
false-alarm machine** in ambient chaos. That matches EEG v1.0 C1 FP ≈ 1.0.

**Deployable EWS implication:** chaos-band first ascent alone is insufficient.
A **regime guard** (or polarity redesign) is required before any operational claim.
Design only (not implemented here): [`P1_C1_GUARD_DESIGN.md`](P1_C1_GUARD_DESIGN.md).

---

## 4. Logical map (what each face blocks)

```
                 ┌─────────────────────────────┐
                 │ Face I INSTRUMENT_PASS      │
                 │ plant recovers known break  │
                 └──────────────┬──────────────┘
                                │
          blocks: “scorer broken / never fires”
                                │
                 ┌──────────────▼──────────────┐
                 │ Face II FIELD residual FAIL │
                 │ multi-domain EWS not shown  │
                 └──────────────┬──────────────┘
                                │
          blocks: “P1 discharged as natural EWS”
                                │
                 ┌──────────────▼──────────────┐
                 │ Face III C1_STRESS_FAIL     │
                 │ ambient noise FP = 1.0      │
                 └──────────────┬──────────────┘
                                │
          blocks: “ship chaos t* as alert without guard”
```

---

## 5. Allowed vs forbidden next moves

### Allowed

| Move | Why |
|------|-----|
| Cite this triptych as program status | Honest composite verdict |
| Design / freeze a **new** protocol with explicit C1 guard | Face III residual is real |
| Pause multi-domain field expansion | Same freeze already stressed |
| Publish as instrument characterization + negative field result | High value, low self-deception |
| Lean / Feigenbaum formal track | Orthogonal; not blocked by P1 field FAIL |

### Forbidden (honesty)

| Move | Why |
|------|-----|
| Claim “P1 validated” from Face I alone | Ignores II + III |
| Retune \(\theta,w,\) lead on Vitória/ILI/EEG locks | Post-hoc |
| Fix plant / nulls so C1C passes without changing detector | Lab washing |
| Another same-param field domain “because maybe this time” | Expected residual, not discovery |
| Equate G4 PASS with specificity | G4 ≠ C1 |

---

## 6. Program position (2026-07-28)

| Track | Position |
|-------|----------|
| P1 synthetic instrument | **Closed PASS** (v1.0.0) |
| P1 synthetic C1 stress | **Closed FAIL** on ambient chaos (C1C) |
| P1-Aedes / P1-ILI empirical | **EWS not supported** under freeze |
| P1-EEG | **Paused** |
| Optional follow-on | C1 guard design → new protocol version if adopted a priori |
| Not next | More identical-freeze field domains |

---

## 7. Reproduce the numbers (no re-design)

```bash
cd /path/to/systemic-tau-formal
python notebooks/16_p1_synthetic_canonical.py run
python notebooks/16_p1_synthetic_canonical.py c1
cd python && pytest -q tests/test_p1_synthetic.py
```

Empirical reports and locks remain under `docs/P1_*` and each domain’s `data/` tree.

---

## 8. Honesty footer

This document is a **synthesis of already locked scores**. It adds no new hits,
no new \(\theta\), and no discharge of ontological or epidemiological claims.
If a future protocol version passes Faces I–III under a **pre-registered** guard,
that is a new claim — not a rewrite of this triptych.
