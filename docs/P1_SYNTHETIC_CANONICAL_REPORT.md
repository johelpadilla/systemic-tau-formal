# P1-Synthetic Canonical — score report (v1.0.0)

**Protocol:** `P1_SYNTHETIC_CANONICAL`  
**Version:** `1.0.0`  
**Label:** `[OPERACIONAL]` lab instrument test  
**CLI:** `python notebooks/16_p1_synthetic_canonical.py run`

---

## Verdict

### P1 instrument (lead score)

| Item | Result |
|------|--------|
| **Gates G1–G4** | **INSTRUMENT_PASS** |
| Plant hit-rate | **20 / 20 (1.00)** |
| Detection lag median | **9** rows after \(t_{\mathrm{switch}}\) (within \([0, w=13]\)) |
| Lead median (plant) | **4** (inside protocol window \[4, 6\]) |
| pure_sync | 10/10 `no_signal` |
| pure_noise (P1 score) | 10/10 `miss_lead` (0 lead-window hits with mid \(t_{\mathrm{obs}}\)) |

### C1 companion (false early warnings)

| Item | Result |
|------|--------|
| **C1 gates** | **C1_STRESS_FAIL** (C1C) |
| C1A plant FP rate | **0.0** (20/20 alerts justified by planted \(t_{\mathrm{obs}}\)) |
| C1B pure_sync alert rate | **0.0** |
| C1C pure_noise FP rate | **1.0** (10/10 ambient chaos alerts) |
| Horizon \(H\) | 13 |

**Reading:** P1 recovers a **known** transition cleanly. C1 shows chaos-band \(t^*\) **always** fires on IID noise with no subsequent event — the classic ambient-chaos false-alarm stress (same family as EEG v1.0 C1 FP ≈ 1.0). G4 can still pass because mid-series \(t_{\mathrm{obs}}\) does not land lead in \[4, 6\]; that is not the same as “no alert.”

Artifacts: `data/synthetic/p1_canonical/`  
(`endpoints.json`, `protocol_lock.json`, `last_score.json`, `last_gates.json`, `last_c1.json`, `matrices/`)

---

## What was tested

Same frozen detector as empirical P1 tracks:

- \(w=13\), \(\theta_{\mathrm{ch}}=0.41\), `min_run=4`
- \(t^* =\) `first_sustained_chaos_ascent`
- P1 hit iff \(\mathrm{lead} = t_{\mathrm{obs}} - t^* \in [4,6]\)
- C1 FP iff alert and no critical event in \((t^*, t^*+H]\)

Canonical plant: ordered seasonal → independent noise at \(t_{\mathrm{switch}}=40\);  
planted \(t_{\mathrm{obs}} = t_{\mathrm{switch}} + \varphi\) with \(\varphi = w = 13\) (a priori).

---

## Interpretation

1. **The scorer is not broken for planted transitions.** Under a clean ordinal order→chaos plant, P1 recovers the event with full hit-rate; plant C1 alerts are justified.
2. **Detection lag is structural** (\(\mathrm{med}\approx 9\)). Lead is vs planted \(t_{\mathrm{obs}}\), not vs \(t_{\mathrm{switch}}\) alone.
3. **C1 ambient stress fails on purpose for this polarity:** pure noise → systematic false early warnings. Any deployable EWS needs a guard (precondition, order polarity, rate limit, or domain filter) — not only a working lead scorer.
4. **Empirical FAILs (Vitória / ILI / EEG)** remain field residuals; synthetic C1_STRESS_FAIL is an additional honesty constraint on chaos-band \(t^*\).
5. This report **does not** discharge dengue, flu, or EEG early-warning claims.

---

## Reproduce

```bash
cd /path/to/systemic-tau-formal
python notebooks/16_p1_synthetic_canonical.py run
python notebooks/16_p1_synthetic_canonical.py c1
cd python && pytest -q tests/test_p1_synthetic.py
```

---

## Honesty

`INSTRUMENT_PASS` ≠ paradigm P1 discharged in nature.  

**Closed synthesis:** [`P1_FAIL_TRIPTYCH.md`](P1_FAIL_TRIPTYCH.md) (instrument / field residual / C1).  
**Optional next (design only):** [`P1_C1_GUARD_DESIGN.md`](P1_C1_GUARD_DESIGN.md) — implement only after a priori freeze; do not retune \(t^*\)/lead to chase field hits.
