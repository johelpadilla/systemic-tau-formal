/-
  Four-level architecture and Baron's Trilemma avoidance (specification).

  [AFIRMACIÓN ONTOLÓGICA] — not an arithmetic theorem.
  Encoded so critics can open `philosophy-challenge` issues against a
  precise object rather than a moving target.
-/
namespace SystemicTau.Ontology

/-- Stratified levels of the programme. -/
inductive Level where
  | observational   -- L0: ranks, samples, windows
  | metric          -- L1: τₛ, g, Δt_k
  | dynamical       -- L2: return maps, universality where theorems apply
  | ontological     -- L3: discrete extramental time / ascent claims
  deriving DecidableEq, Repr

/-- Horns of Baron's Trilemma. -/
inductive TrilemmaHorn where
  | infiniteRegress
  | circularity
  | dogmatism
  deriving DecidableEq, Repr

/-- A claim is well-sited if its level is declared and justification
    does not collapse into a single horn. Specification only. -/
structure Claim where
  text : String
  level : Level
  avoids : List TrilemmaHorn

/--
  [AFIRMACIÓN ONTOLÓGICA]
  The architecture claims that requiring every public claim to declare
  a Level blocks pure regress (time by deeper time), pure circularity
  (clock defined only by clock), and pure dogmatism (L3 with no L0–L2).
-/
def architectureAvoidsTrilemma : Prop := True

theorem architecture_spec : architectureAvoidsTrilemma := trivial

end SystemicTau.Ontology
