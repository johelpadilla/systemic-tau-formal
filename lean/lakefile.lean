import Lake
open Lake DSL

package «systemic-tau» where
  -- Mathlib: Rat order + linarith + optional Real analytic path.
  -- Default build uses Mathlib. See docs/MATHLIB.md.

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.14.0"

@[default_target]
lean_lib SystemicTau where
