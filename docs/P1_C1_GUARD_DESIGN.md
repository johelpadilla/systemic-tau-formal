# P1 C1 Guard — design freeze sketch (not implemented)

**Document ID:** `P1_C1_GUARD_DESIGN`  
**Date:** 2026-07-28  
**Claim class:** `[OPERACIONAL]` design only — **no code, no re-score**  
**Parent status:** [`P1_FAIL_TRIPTYCH.md`](P1_FAIL_TRIPTYCH.md) · Face III `C1_STRESS_FAIL`  
**Baseline detector:** frozen P1 chaos ascent (`w=13`, \(\theta_{\mathrm{ch}}=0.41\), `min_run=4`)

---

## 0. Why this note exists

Synthetic C1C (pure IID / independent noise) yields **FP rate = 1.0**: every series
alerts, none has an event in \((t^*, t^*+H]\). EEG v1.0 showed the same family
(ambient chaos → perpetual early warning).

**Problem statement (a priori):**

> Define a **guard** \(G\) such that an alert is emitted only when
> \(t^*\) **and** \(G\) hold, with \(G\) chosen **before** re-running plant / nulls /
> any field domain — and without fitting \(G\) to those outcomes.

This document proposes candidates and admission gates. **It does not pick a winner
by peeking at scores.** Implementation requires a **new protocol version**
(e.g. P1 v1.1 / C1-guard v1.0), not silent mutation of v1.0 locks.

---

## 1. Definitions (carry over)

| Symbol | Meaning |
|--------|---------|
| \(\tau_s(t)\) | Windowed multi-channel Kendall τ (or domain equivalent) |
| \(t^*\) | First index of sustained chaos-band ascent (baseline rule) |
| \(H\) | C1 horizon (baseline **13**) |
| Alert (baseline) | Existence of \(t^*\) |
| FP | Alert and no critical event in \((t^*, t^*+H]\) |
| Guard \(G\) | Boolean predicate on the series **up to** \(t^*\) (causal) |

**Causal constraint:** \(G\) may use only data with indices \(\le t^*\) (or \(\le t^*-1\)
if the ascent window itself must not leak). No use of future \(t_{\mathrm{obs}}\).

---

## 2. Design goals

| ID | Goal | Metric |
|----|------|--------|
| D1 | Kill ambient-chaos FP | C1C pure_noise: FP rate ≤ **0.20** (suggested; freeze before code) |
| D2 | Keep clean transition skill | C1A plant: FP rate ≤ **0.10**; P1 plant hit-rate ≥ **0.80** |
| D3 | Keep order null quiet | C1B pure_sync: alert rate ≤ **0.10** |
| D4 | No post-hoc on field | Field re-score only after lock; field FAIL does not edit \(G\) |

**Non-goals:** maximizing field hits; inventing \(G\) after seeing Vitória/ILI/EEG
residuals; claiming clinical deployability from synthetic C1 alone.

---

## 3. Candidate guards (menu — pick ≤1 primary before implement)

### G-A — Pre-order / regime contrast (recommended default candidate)

**Idea:** Chaos ascent is only meaningful if it **exits a prior ordered regime**.

Sketch:

1. Let \(R_{\mathrm{pre}}\) be the longest run with \(\tau_s \ge \theta_{\mathrm{st}}\)
   (or \(\lvert\tau_s\rvert \ge \theta_{\mathrm{st}}\)) ending at or before the ascent start.
2. Require \(\mathrm{length}(R_{\mathrm{pre}}) \ge L_{\mathrm{pre}}\) (candidate: \(L_{\mathrm{pre}}=w=13\)).
3. Optionally require mean \(\tau_s\) on \(R_{\mathrm{pre}} \ge \theta_{\mathrm{st}}\).

**Why it should kill C1C:** pure noise rarely sustains long high-\(\tau\) pre-runs.  
**Risk:** late plant transitions with short pre-order tails → plant hit-rate drop.  
**Link to history:** same *family* as EEG v1.1 order polarity, but as a **guard on
chaos \(t^*\)**, not a full polarity flip.

### G-B — Local baseline Δτ

**Idea:** Require a drop from a local baseline, not only absolute \(\theta_{\mathrm{ch}}\).

Sketch:

1. Baseline \(b = \mathrm{median}(\tau_s[t^*-B:t^*])\) with \(B\) frozen (e.g. 26).
2. Require \(b - \tau_s(t^*) \ge \Delta_{\min}\) (e.g. 0.25) **and** chaos-band run.

**Why:** ambient noise has high variance but weak structured drop from order.  
**Risk:** two free numbers (\(B, \Delta_{\min}\)); higher post-hoc temptation.

### G-C — Single ascent / low churn

**Idea:** Suppress alerts when the series chatters across \(\theta_{\mathrm{ch}}\).

Sketch:

1. Count chaos-band run onsets in \([0, t^*]\).
2. Require count \(= 1\) (first and only) **or** count ≤ \(K\) with \(K=1\) frozen.

**Why:** pure noise produces many threshold crossings.  
**Risk:** plant with noisy pre-break may fail; may be weak alone (use as secondary).

### G-D — Rate limit / refractory

**Idea:** After any alert, suppress new alerts for \(H_{\mathrm{ref}}\) steps.

**Why:** operational page-load control.  
**Does not fix C1C first alert** on pure noise — **not sufficient alone**.

### G-E — Domain / feature gate (out of band)

**Idea:** Only run P1 when domain precondition holds (e.g. seasonal order known).  
**Why:** engineering control plane.  
**Not a substitute** for statistical guard on the τ path; document as deployment
policy, not scorer science.

---

## 4. Recommended design package (proposal to freeze later)

| Piece | Proposal | Status |
|-------|----------|--------|
| Primary guard | **G-A** pre-order run \(L_{\mathrm{pre}}=13\), \(\theta_{\mathrm{st}}=0.50\) | **not frozen** until explicit lock |
| Secondary (optional) | G-C with \(K=1\) | only if G-A alone fails D1 on synthetic *dev* holdout |
| Forbidden until new version | Changing \(w, \theta_{\mathrm{ch}},\) lead, \(H\) to chase C1C | — |
| Protocol name if adopted | e.g. `P1_SYNTHETIC_CANONICAL` **v1.1.0** + field forks only after | — |

**Freeze rule:** write numeric thresholds into a new protocol markdown +
`protocol_lock.json` **before** running the admission panel below.

---

## 5. Admission panel (must pass before any field claim)

Same matrices / seeds as v1.0 plant-nulls preferred for comparability; if generator
changes, re-lock and **do not** compare silently to v1.0.

| Gate | Panel | Pass criterion (suggested freeze) |
|------|-------|-----------------------------------|
| **P1'** | plant | hit-rate ≥ 0.80 (lead [4,6] vs planted \(t_{\mathrm{obs}}\)) |
| **C1A'** | plant | FP rate ≤ 0.10 |
| **C1B'** | pure_sync | alert rate ≤ 0.10 |
| **C1C'** | pure_noise | FP rate ≤ 0.20 |
| **G-hold** | pure_noise | if alert rate > 0, those alerts still meet FP rule |

**Overall:** all five must PASS → `GUARD_ADMISSION_PASS`.  
Else → redesign \(G\) **or** abandon chaos-band EWS for that polarity.

**Holdout honesty:** if any threshold was adjusted after a failed C1C' attempt on
the same seeds, document it as exploratory and re-validate on **new** seeds only.

---

## 6. What implementation would touch (when ordered)

| Area | Action |
|------|--------|
| `python/core/p1_synthetic.py` (or shared `p1_alert.py`) | `guard_pre_order(...)` + alert = \(t^* \land G\) |
| Protocol docs | new version; immutability of v1.0 |
| `notebooks/16_...` | `guard` / `run --protocol 1.1` |
| Tests | plant still hits; pure_noise FP bound; pure_sync quiet |
| Field domains | **optional** re-score under new lock only; expect residual |

**Not in scope of this design note:** coding, seed fishing, field tuning.

---

## 7. Relation to EEG v1.1

EEG v1.1 flipped polarity (order runs) and still failed lead (0/7) with moderate C1
improvement. Lessons:

1. Polarity / guard can change specificity **without** creating lead skill.
2. Face I plant (chaos after order) is the natural home for **G-A**.
3. Do not treat “C1 improved” as “EWS works.”

---

## 8. Decision checklist (before writing code)

- [ ] Primary guard chosen (default proposal: G-A).
- [ ] All numeric thresholds written in a **new** protocol file.
- [ ] Admission criteria (table §5) frozen with the protocol.
- [ ] Explicit statement: v1.0 locks and Face III FAIL remain historical truth.
- [ ] No field re-score until `GUARD_ADMISSION_PASS` on synthetic admission panel.
- [ ] User / program owner signs freeze (commit message or STATUS line).

---

## 9. Honesty footer

Until the checklist is completed and code is locked, **baseline P1 remains
C1_STRESS_FAIL on ambient noise**. This file is a design menu, not a claim that
a guard already works.
