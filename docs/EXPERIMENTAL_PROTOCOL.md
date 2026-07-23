# Experimental protocol (standard report)

**Version:** 0.1.0 · **Length target:** keep reports comparable across groups  
**Labels:** procedures are `[OPERACIONAL]`; outcomes are `[EMPÍRICO]`.

## 1. Minimal preprocessing

1. Multivariate series \(X \in \mathbb{R}^{T \times N}\) with \(N \ge 2\).  
2. Align timestamps; no look-ahead imputation across the evaluation split.  
3. Allowed: missing-value mask, rank-preserving transforms, per-variable z-score **if documented**.  
4. Forbidden without justification: target leakage, post-hoc threshold re-fit on test transitions.

## 2. Recommended windowing

| Parameter | Default | Notes |
|-----------|---------|--------|
| Window length \(w\) | 13 | Match `systemictau` default unless sampling rate forces change |
| Stride | 1 | Report if decimated |
| Minimum \(T\) | \(\ge 10 w\) | Shorter runs → exploratory only |

If sampling is weekly (e.g. entomological traps), state the calendar mapping of \(w\).

## 3. Core pipeline (order fixed)

1. Ontological partition (Local / Medium / Global) if multi-scale; else Global only.  
2. Compute \(\tau_s(t)\) (mean pairwise Kendall-τ in window).  
3. Gate \(g(\tau_s)\) and RECD increments \(\Delta t_k\); accumulate \(T\).  
4. Optional RQA / hyper-persistence (report parameters).  
5. Transition detectors (Frobenius / KS / consensus \(t^*\)) if claiming early warning.

## 4. Operational thresholds (defaults)

| Band | Condition | Meaning |
|------|-----------|---------|
| Stable | \(\tau_s \ge 0.50\) | Strong ordinal sync |
| Chaotic | \(\|\tau_s\| < 0.41\) | High-volatility / chaotic band |
| Anti-sync | \(\tau_s \le -0.41\) | Strong anti-concordance |
| Feigenbaum \(\delta\) | \(\approx 4.6692016091\) | Used in gate / depth scaling |

**`[OPERACIONAL]`** — changing thresholds requires a sensitivity section.

## 5. Significance criteria

Pre-specify **before** looking at \(t^*\):

- Endpoint definition of “critical transition”  
- Nulls: phase-randomized or IAAFT surrogates (state which)  
- Multiplicity correction if multiple scales/detectors  
- Minimum run length inside chaotic band for “sustained”

## 6. Noise protocol (for P3)

- Add Gaussian noise \(\varepsilon \sim \mathcal{N}(0, \sigma^2)\) with \(\sigma = \rho \cdot \mathrm{std}(X_{\cdot,j})\) per column, \(\rho \in \{0, 0.05, 0.10, 0.20\}\).  
- Recompute full pipeline **without** re-fitting thresholds.  
- Report regime classification agreement vs \(\rho=0\).

## 7. Required report format

```text
1. Title / domain / contact
2. Data: source, license, N, T, sampling rate
3. Preprocessing checklist (this doc §1)
4. Parameters: w, stride, detectors, software versions + git commit
5. Epistemic labels for each claim
6. Results: τₛ series, g, T_RECD, t* if any, endpoint times
7. Surrogates / null results
8. Which predictions P1–P4 are supported / falsified
9. Limitations (honest)
10. Code + environment lockfile
```

## 8. Software

- Reference: `pip install systemictau` or this repo’s `python/` package.  
- Formal: `lake build` when claiming machine-checked lemmas.
