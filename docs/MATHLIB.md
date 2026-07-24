# Mathlib integration

Epistemic honesty: Mathlib supplies **order / field / tactic** infrastructure
and (later) a path to **real-analytic** Feigenbaum statements. It does **not**
discharge open goals 1–3 by itself.

## Default stack (this monorepo)

| Piece | Role |
|-------|------|
| Lean **4.14.0** | `lean-toolchain` |
| **mathlib4** `@ v4.14.0` | `lean/lakefile.lean` require |
| Imports used today | `Mathlib.Algebra.Order.Ring.Unbundled.Rat`, `Mathlib.Tactic.Linarith`, `Ring`, `FieldSimp`; Real track: `Data.Real.Basic`, `Topology.Instances.Real`, `Order.Filter.AtTopBot` |
| Analytic claim shapes | `SystemicTau/FeigenbaumAnalytic.lean` (ε–N cascade limit; open goals 3a–3c) |
| Real / `Tendsto` shapes | `SystemicTau/FeigenbaumTendsto.lean` (classical limit interface; open 3aℝ–3cℝ) |

Build:

```bash
export PATH="$HOME/.elan/bin:$PATH"
cd lean
lake update          # once / when rev changes
lake exe cache get  # Linux CI / most platforms — prebuilt oleans
lake build           # builds SystemicTau (+ mathlib deps as needed)
```

### macOS note (cache binary)

On some macOS versions the Mathlib `cache` executable fails with:

```text
dyld: __DATA_CONST segment missing SG_READ_ONLY flag
```

Workaround: build the **import closure from source** (slow first time, ~0.5–1 GB oleans for the Rat/linarith slice used here). Linux GitHub Actions should use `lake exe cache get` successfully.

## What is / is not formalized with Mathlib

| Item | Status |
|------|--------|
| ℚ as `LinearOrder` / field arithmetic | **used** (via Mathlib) |
| Operational gate + band lemmas | **proved** (same as pre-Mathlib intent) |
| Cascade / δ ε–N interfaces | **encoded** in `FeigenbaumAnalytic` |
| `Tendsto` limit δ_n → δ on ℝ | **proved** for geometric cascade (exact ratio δ_op); logistic ID open |
| ε–N ↔ `Tendsto` bookkeeping | **proved** (`cascadeDeltaLimit_iff_tendsto`) — not Feigenbaum |
| Continuum unimodal return of τₛ | **lab constructions**: tent + **non-tent** logistic conjugacy (`tauReturnF`); not derived from ordinal ranks alone |
| C² / Schwarzian (logistic algebra) | **proved** in `FeigenbaumSchwarzian` (formal derivatives); open-set universality still research |
| Logistic cascade scale ID | **proved** in `FeigenbaumLogistic` (anchored geometric); true superstable roots open |

## Real / Tendsto interface

```lean
import SystemicTau.FeigenbaumTendsto
-- cascadeDeltaLimitTendsto B δ :=
--   Tendsto (scalingRatioReal B) atTop (𝓝 δ)
-- cascadeDeltaLimit_iff_tendsto  -- proved bookkeeping
-- open_cascade_tendsto_feigenbaum_delta  -- OPEN (research)
```

The ε–N ↔ `Tendsto` bridge is pure metric analysis on the cast sequence.
Discharging open goal 3 for a **physical** cascade still needs real dynamics
(or an external theorem with citation) — the bridge alone does **not** prove
Feigenbaum δ.

Do **not** replace `open_analytic_feigenbaum` with a tent-map or toy-cascade witness.

## CI

`.github/workflows/ci.yml` runs `lake exe cache get` then `lake build` on Ubuntu.
First cold CI without cache is long; subsequent runs hit the Actions cache on `.lake` / `~/.elan`.
