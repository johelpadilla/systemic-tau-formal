# Mathlib integration

Epistemic honesty: Mathlib supplies **order / field / tactic** infrastructure
and (later) a path to **real-analytic** Feigenbaum statements. It does **not**
discharge open goals 1–3 by itself.

## Default stack (this monorepo)

| Piece | Role |
|-------|------|
| Lean **4.14.0** | `lean-toolchain` |
| **mathlib4** `@ v4.14.0` | `lean/lakefile.lean` require |
| Imports used today | `Mathlib.Algebra.Order.Ring.Unbundled.Rat`, `Mathlib.Tactic.Linarith`, `Ring`, `FieldSimp` |
| Analytic claim shapes | `SystemicTau/FeigenbaumAnalytic.lean` (ε–N cascade limit; open goals 3a–3c) |

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
| `Tendsto` limit δ_n → δ on ℝ | **open** (goal 3; needs analysis modules) |
| Continuum unimodal return of τₛ | **open** (goals 1–2; not a Mathlib import issue) |

## Next Mathlib modules (optional, research)

When discharging open goal 3 for real:

```lean
import Mathlib.Topology.Basic
import Mathlib.Order.Filter.Basic
-- Tendsto (fun n => (scalingRatio B n : ℝ)) atTop (nhds δ)
```

Do **not** replace `open_analytic_feigenbaum` with a tent-map witness.

## CI

`.github/workflows/ci.yml` runs `lake exe cache get` then `lake build` on Ubuntu.
First cold CI without cache is long; subsequent runs hit the Actions cache on `.lake` / `~/.elan`.
