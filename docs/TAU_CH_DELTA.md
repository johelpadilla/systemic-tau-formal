# τ_ch vs Feigenbaum δ — formal status

Epistemic labels: see `EPISTEMIC_LABELS.md`.

## Claims

| Statement | Label | Status |
|-----------|--------|--------|
| Operational bands τ_st = 1/2, τ_ch = 41/100 | `[OPERACIONAL]` | Fixed for protocol |
| 2/δ ≈ 0.428 is near 0.41 | `[OPERACIONAL]` / motivational | Numerical + Lean `twoOverDelta_gt_tauChaos` |
| Unique \(f(\delta)=c/\delta\) with \(f(\delta_{\mathrm{op}})=\tau_{\mathrm{ch}}\) | `[TEOREMA]` | **Proved** in inverse-scale class (`ThresholdFromDelta.lean`) |
| Classical derivation of τ_ch from pure Feigenbaum (no free \(c\)) | `[CONJETURA]` | **Open** (naive \(2/\delta\) fails machine-checked) |
| Finite simple candidates ≠ τ_ch | `[TEOREMA]` | **Proved** (Lean) |

## Unique operational bridge (`SystemicTau/ThresholdFromDelta.lean`)

**Class.** Inverse-homogeneous maps \(f(\delta)=c/\delta\) with \(c>0\) (Feigenbaum length scaling \(\propto 1/\delta\)).

**Pin.** \(f(\delta_{\mathrm{op}})=\tau_{\mathrm{ch}}\) forces a unique scale
\[
c_\star=\tau_{\mathrm{ch}}\cdot\delta_{\mathrm{op}},\qquad
f(\delta)=\frac{c_\star}{\delta}=\kappa\cdot\frac{2}{\delta},\quad
\kappa=\frac{c_\star}{2}<1.
\]

**Stable edge.** \(\tau_{\mathrm{st}}(\delta)=1/2\) independent of δ (Kendall mid).

**Also proved.** Antitonicity of \(f\) on \(\delta>0\); recovery of operational pair at \(\delta_{\mathrm{op}}\); compatibility with nonneg trichotomy of regimes and gate antitonicity on the chaos band; four-level ontology registry (L0–L3); honesty block that pure \(f=2/\delta\) cannot equal \(\tau_{\mathrm{ch}}\).

## Machine-checked disequalities (`SystemicTau/Thresholds.lean`)

Against the rational approximation of δ used in this monorepo:

| Candidate | Lean name | Result |
|-----------|-----------|--------|
| 2/δ | `twoOverDelta` | ≠ τ_ch (in fact >) |
| 1/δ | `oneOverDelta` | ≠ τ_ch |
| (δ−1)/δ | `gatePrefactor` | ≠ τ_ch |
| (δ−1)/(2δ) | `deltaMinusOne_over_twoDelta` | ≠ τ_ch |
| 2/(δ+1) | `twoOverDeltaPlusOne` | ≠ τ_ch |
| (δ−2)/δ | `deltaMinusTwo_over_delta` | ≠ τ_ch |
| 3/(2δ) | `threeOverTwoDelta` | ≠ τ_ch |
| 4/δ² | `fourOverDeltaSq` | ≠ τ_ch |
| 5/δ | `fiveOverDelta` | ≠ τ_ch |
| τ_st | `tauStable` | ≠ τ_ch |

Packaged as `failedSimpleCandidates` (extended, issue #7). Python twin:
`python/tests/test_thresholds_delta.py`.

## What this does *not* mean

- It does **not** prove that classical Feigenbaum theory alone forces 0.41 (that would eliminate free \(c\)).  
- It does **not** authorize re-fitting τ_ch on dengue or other field data and calling the result “universal”.  
- Protocol reports must keep 0.50 / 0.41 unless a **sensitivity section** documents the change (`EXPERIMENTAL_PROTOCOL.md`).

## Next steps (honest)

1. Seek a renormalization construction that fixes \(c\) without the operational pin (research-scale).  
2. Optional Mathlib `ℝ` path for δ as a real limit, not only a rational stand-in.  
3. Do not collapse this file into a claim that τ_ch is “derived from Feigenbaum theory” without discharging the classical residual.
