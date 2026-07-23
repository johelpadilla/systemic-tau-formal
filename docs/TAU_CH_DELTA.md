# τ_ch vs Feigenbaum δ — formal status

Epistemic labels: see `EPISTEMIC_LABELS.md`.

## Claims

| Statement | Label | Status |
|-----------|--------|--------|
| Operational bands τ_st = 1/2, τ_ch = 41/100 | `[OPERACIONAL]` | Fixed for protocol |
| 2/δ ≈ 0.428 is near 0.41 | `[OPERACIONAL]` / motivational | Numerical + Lean `twoOverDelta_gt_tauChaos` |
| Unique closed form τ_ch = f(δ) | `[CONJETURA]` | **Open** |
| Finite simple candidates ≠ τ_ch | `[TEOREMA]` | **Proved** (Lean) |

## Machine-checked disequalities (`SystemicTau/Thresholds.lean`)

Against the rational approximation of δ used in this monorepo:

| Candidate | Lean name | Result |
|-----------|-----------|--------|
| 2/δ | `twoOverDelta` | ≠ τ_ch (in fact >) |
| 1/δ | `oneOverDelta` | ≠ τ_ch |
| (δ−1)/δ | `gatePrefactor` | ≠ τ_ch |
| (δ−1)/(2δ) | `deltaMinusOne_over_twoDelta` | ≠ τ_ch |
| τ_st | `tauStable` | ≠ τ_ch |

Packaged as `failedSimpleCandidates`.

## What this does *not* mean

- It does **not** prove that no function of δ equals 0.41.  
- It does **not** authorize re-fitting τ_ch on dengue or other field data and calling the result “universal”.  
- Protocol reports must keep 0.50 / 0.41 unless a **sensitivity section** documents the change (`EXPERIMENTAL_PROTOCOL.md`).

## Next steps (honest)

1. Enlarge the candidate class (with community agreement) and rule out or confirm members.  
2. Optional Mathlib `ℝ` path for δ as a real limit, not only a rational stand-in.  
3. Do not collapse this file into a claim that τ_ch is “derived from Feigenbaum theory” without a discharged construction.
