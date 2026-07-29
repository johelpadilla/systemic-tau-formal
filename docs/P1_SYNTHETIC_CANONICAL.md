# P1-Synthetic Canonical — instrument validation of chaos-band EWS

**Document ID:** `P1_SYNTHETIC_CANONICAL`  
**Protocol version:** `1.0.0`  
**Claim class:** `[OPERACIONAL]` lab instrument test — **not** field epidemiology  
**Software pin:** `systemic-tau-formal` (commit at lock time)

---

## 0. What this is / is not

| This is | This is not |
|---------|-------------|
| Controlled test of the **same** frozen P1 detector used on Vitória / ILI / EEG | A substitute for empirical multi-domain discharge |
| Ground-truth structural break \(t_{\mathrm{switch}}\) + planted \(t_{\mathrm{obs}}\) | Retuning \(\theta\) / \(w\) / lead after seeing field fails |
| Positive plant + null controls (sync-only, noise-only) | Claiming dengue / flu early-warning skill |
| Honest PASS/FAIL of the **instrument** under ideal signal | Permission to ignore empirical FAILs |

**Question answered:**  
Does `first_sustained_chaos_ascent` + lead window **[4, 6]** recover a known desynchronization break when the panel is built so that ordinal chaos appears *after* order?

If **PASS** → empirical 0/N is about **field signal**, not a broken scorer.  
If **FAIL** → the operational P1 definition cannot even fire under ideal conditions (instrument problem).

---

## 1. Canonical generative model

### 1.1 Panel construction (`p1_canonical_panel`)

| Phase | Rows | Construction |
|-------|------|----------------|
| **Order** | \(0 \le t < t_{\mathrm{switch}}\) | Shared seasonal driver + light noise (`synchronized_seasonal`) |
| **Chaos-like** | \(t \ge t_{\mathrm{switch}}\) | Independent Gaussian columns, amplitude-matched (`independent_noise`) |

| Param | Value | Notes |
|-------|-------|-------|
| \(T\) | 120 | weeks-like length |
| \(N\) | 6 | multi-channel (trap/region analogue) |
| \(t_{\mathrm{switch}}\) | 40 | a priori structural break |
| `noise_pre` | 0.02 | keep pre-break \(\lvert\tau_s\rvert\) high |
| seeds | **0 … 19** (plant) | fixed a priori; no seed fishing |

Post-break block is scaled so column std matches the pre-break block (same as `regime_switch`).

**Label:** `[OPERACIONAL]`. Not entomology, not clinical incidence.

### 1.2 Planted \(t_{\mathrm{obs}}\)

| Item | Value | Rationale |
|------|-------|-----------|
| Rule | \(t_{\mathrm{obs}} = t_{\mathrm{switch}} + \varphi\) | Phenomenological lag after structural break |
| \(\varphi\) | **13** \(= w\) | One full τ-window after generative break (same scale as measurement window) |
| Not allowed | Setting \(\varphi\) from post-hoc lead histograms of the same panel | — |

**Why not \(\varphi \in [4,6]\)?**  
Sliding Kendall-τ with \(w=13\) **must** lag the generative break (window still half-order until the break fills the window). Expecting lead 4–6 vs \(t_{\mathrm{switch}}\) itself is not a fair instrument test. The P1 story is lead vs an **observable event** that occurs *after* the ordinal transition; \(\varphi=w\) is the a priori synthetic event lag.

### 1.3 Null controls

| Panel | Construction | Expected under frozen P1 |
|-------|--------------|---------------------------|
| `pure_sync` | `synchronized_seasonal` entire \(T\) | `no_signal` (no sustained chaos-band run) |
| `pure_noise` | `independent_noise` entire \(T\) | Early \(t^*\) near first valid index; with mid-series \(t_{\mathrm{obs}}\) → **miss_lead**, not hit |

Null seeds: 100…109 (sync), 200…209 (noise). Fixed a priori.

---

## 2. Frozen operational params

**Identical** to P1-Aedes / P1-ILI v1.0.0:

| Param | Value |
|-------|-------|
| `window_size` \(w\) | 13 |
| \(\theta_{\mathrm{ch}}\) | 0.41 |
| \(\theta_{\mathrm{st}}\) | 0.50 |
| `t_star` | `first_sustained_chaos_ascent` |
| `min_run` | 4 |
| `lead` | \(t_{\mathrm{obs}} - t^*\) |
| `lead_window` | **[4, 6]** |
| \(\varphi\) (synthetic only) | 13 |

No re-fit after lock. Bump protocol version to change any of the above.

---

## 3. Pre-registration workflow

1. **Generate** plant + null matrices (deterministic seeds) → `data/synthetic/p1_canonical/`.  
2. **Endpoints** with `pre_registered: true`, `t_obs = t_switch + φ` (plant) or protocol null rule.  
3. **Lock** SHA-256 of endpoints + frozen params + generator config.  
4. **Score** — refuse hash mismatch / `pre_registered: false`.

CLI: `notebooks/16_p1_synthetic_canonical.py`.

---

## 4. Acceptance gates (a priori) — P1 instrument

| Gate | Panel | Criterion |
|------|-------|-----------|
| **G1** Detection lag | plant | For each scored series with \(t^*\): \(0 \le t^* - t_{\mathrm{switch}} \le w\) (no pre-break false ascent; lag ≤ one window) |
| **G2** P1 hit-rate | plant | hit-rate \(\ge 0.80\) over the 20 locked plant seeds |
| **G3** Null order | pure_sync | all scored → `no_signal` (hit-rate = 0) |
| **G4** Null chaos | pure_noise | hit-rate \(\le 0.10\) with \(t_{\mathrm{obs}} = T//2\) (early \(t^*\) must not manufacture **lead-window hits**) |

**P1 INSTRUMENT_PASS** iff G1–G4 all hold.  
**Instrument FAIL** if G1 or G2 fails under this plant.  
**Specificity FAIL (P1 score)** if G3 or G4 fails.

Note: G4 is **not** C1. G4 only asks whether pure noise + arbitrary mid-series \(t_{\mathrm{obs}}\) produces a lucky lead in \[4, 6\]. Ambient alerts without any event are challenge **C1** (§4b).

---

## 4b. C1 companion — false early warnings

Aligned with [`CHALLENGES.md`](CHALLENGES.md) **C1** and the EEG interictal panel (lab geometry, not clinical seconds).

| Item | Value |
|------|-------|
| Alert | \(t^*\) exists (`first_sustained_chaos_ascent`) |
| Horizon \(H\) | **13** \(= w\) (frozen `c1_horizon`) |
| Justified | critical event in \((t^*,\, t^*+H]\) |
| False positive | alert **and** not justified |

| Panel | Critical event? | Expected under chaos polarity |
|-------|-----------------|-------------------------------|
| plant | yes — planted \(t_{\mathrm{obs}}\) | alert; **not** FP (event in horizon) |
| pure_sync | no | no alert |
| pure_noise | no | alert → **FP** (ambient ordinal chaos) |

### C1 gates

| Gate | Criterion |
|------|-----------|
| **C1A** plant | FP rate \(\le 0.10\) |
| **C1B** pure_sync | alert rate \(= 0\) |
| **C1C** pure_noise | FP rate \(\le 0.20\) |

**C1_PASS** iff C1A–C1C hold.  
**C1_STRESS_FAIL** if C1C fails (ambient chaos on IID noise) — *expected* for chaos-band \(t^*\) (cf. EEG v1.0 C1 FP ≈ 1.0).  

C1 is a **companion** verdict: does **not** flip P1 `INSTRUMENT_PASS`. CLI exit code follows P1 gates unless `--strict-c1`.

---

## 5. Files

| Path | Role |
|------|------|
| `docs/P1_SYNTHETIC_CANONICAL.md` | This freeze |
| `docs/P1_SYNTHETIC_CANONICAL_REPORT.md` | Score report (after lock) |
| `data/synthetic/p1_canonical/` | Matrices, endpoints, lock, scores, **last_c1.json** |
| `python/core/synthetic.py` | `p1_canonical_panel` |
| `python/core/p1_synthetic.py` | Generate / lock / score / gates / **C1** |
| `notebooks/16_p1_synthetic_canonical.py` | CLI (`run`, `c1`, …) |
| `python/tests/test_p1_synthetic.py` | Unit + gate tests |

---

## 6. Relation to empirical P1 tracks

| Track | Result (context) | Role of this protocol |
|-------|------------------|------------------------|
| P1-Aedes Vitória | yearly 0/5 | Field residual |
| P1-ILI HHS→FluSurv | peak 0/10 | Field residual |
| P1-EEG CHB-MIT | 0–1/7 | Domain transfer residual |
| **P1-Synthetic Canonical** | (this doc) | Instrument: does the scorer work when signal is planted? |

A synthetic PASS **does not** discharge empirical challenges. A synthetic FAIL **does** force rethinking \(t^*\) / lead / window before more field domains.
