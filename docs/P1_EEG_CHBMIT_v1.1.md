# P1-EEG v1.1.0 — a priori redesign (CHB-MIT)

**Document ID:** `P1_EEG_CHBMIT_v1.1`  
**Protocol id:** `P1_EEG_CHBMIT`  
**Protocol version:** **1.1.0**  
**Status:** **DESIGN FREEZE** (2026-07-27) — not scored  
**Claim class:** `[EMPÍRICO]` domain transfer C3 neuro  
**Parent pilot (historical FAIL):** [`P1_EEG_CHB01_PILOT_REPORT.md`](P1_EEG_CHB01_PILOT_REPORT.md) under **v1.0.0**  
**Base protocol (v1.0.0 frozen, immutable):** [`P1_EEG_CHBMIT.md`](P1_EEG_CHBMIT.md)

---

## 0. Mandate and hard prohibitions

This document freezes **feature, polarity, scale, lock tree, and precondition gates** for P1-EEG **before** any new τₛ scoring on CHB-MIT.

| Rule | Binding |
|------|---------|
| Do **not** re-fit θ, \(w\), `min_run`, bands, or lead windows using v1.0.0 hit/miss tables | **HARD** |
| Do **not** read `data/chbmit/last_p1_eeg_score.json` or `last_c1_eeg.json` to choose v1.1 params | **HARD** |
| Do **not** mutate v1.0.0 lock / endpoints / report | **HARD** |
| v1.1 artifacts live under a **separate tree** (`data/chbmit/v1.1/`) | **HARD** |
| Primary \(t^*\) is **order / hypersync polarity**, not first chaos ascent | **HARD** |
| Precondition gate on **interictal occupancy only** must pass **before** lock | **HARD** |
| If precondition gate fails → bump to v1.2 design; **do not** peek at seizure leads | **HARD** |

**Allowed after freeze:** implement code that matches this document; run precondition diagnostic; if gate passes, lock endpoints; then score once; publish report.

**Forbidden collapse:** “v1.1 hit ⇒ dengue P1” or “v1.0.0 FAIL ⇒ Tau false.”  
**Allowed:** “Under v1.1.0 frozen protocol, hit/C1 on listed cases is evidence for/against *this* feature+polarity package.”

---

## 1. Why v1.0.0 failed (motivation only — not a tuning knob)

From the locked chb01 pilot (integrity PASS; early-warning FAIL):

1. **Ambient chaos band:** epoch-RMS @ 1 s put \(\lvert\tau_s\rvert < 0.41\) almost continuously → first sustained chaos run at \(t^*\approx 12\,\mathrm{s}\) (window floor), not a pre-ictal event.  
2. **Polarity mismatch:** clinical seizure dynamics often involve **hypersynchrony / ordered coupling**, not “first ascent into chaos from ordered ground” (Aedes-like regime).  
3. **Process gap:** dataset was chosen for clean \(t_{\mathrm{obs}}\) without a **precondition checklist** on regime contrast.

v1.1 answers (1)–(3) with a **new** protocol version. It does **not** salvage v1.0.0 by silent re-fit.

---

## 2. Scientific hypotheses (a priori)

### H1 — Polarity (primary)

In multichannel scalp EEG, a useful pre-ictal ordinal signal under Systemic Tau is a **sustained entry into the stable / order band** of τₛ:

\[
\lvert\tau_s\rvert \ge \theta_{\mathrm{stable}} = 0.50
\]

interpreted as **hypersynchronous co-movement** of the chosen features across channels/bands — not the first chaos-band run \(\lvert\tau_s\rvert < 0.41\).

### H2 — Feature

**Log bandpower** in four fixed clinical bands, per EEG channel, at epoch scale 2 s, yields an \(X\in\mathbb{R}^{T\times N}\) whose τₛ trajectory is **not ambient-chaos** on interictal EEG (to be checked by the precondition gate, not by seizure leads).

### H3 — Scale

Epoch **2.0 s** balances spectral stability (FFT length @ 256 Hz → 512 samples) against a lead horizon of 30–300 s (enough epochs for \(w=13\), `min_run=4`).

### Explicit non-claims

- Not a clinical device claim.  
- Not proof of universal seizure physiology.  
- Not dengue / Aedes P1 discharge.  
- θ and \(w\) remain **paradigm operational defaults**, not EEG-optimized thresholds.

---

## 3. Frozen operational parameters (v1.1.0)

**`[OPERACIONAL]`** — changing any row requires protocol **1.2.0+** and a new design freeze.

| Parameter | v1.0.0 (immutable history) | **v1.1.0 (this freeze)** |
|-----------|----------------------------|---------------------------|
| `protocol_version` | `1.0.0` | **`1.1.0`** |
| `fs_hz_expected` | 256 | 256 |
| `epoch_s` | 1.0 | **2.0** |
| `feature` | `rms` | **`log_bandpower_4_chmean`** |
| `bands_hz` | — | **δ 0.5–4, θ 4–8, α 8–13, β 13–30** |
| `bandpower_collapse` | — | **`chmean`**: mean of 4 log-bandpowers **per channel** → \(N=N_{\mathrm{ch}}\) |
| `bandpower_eps` | — | **`1e-12`** (floor inside log10) |
| `fft_window` | — | **Hann on full epoch** (no zero-pad beyond epoch) |
| `channel_policy` | EEG 10–20 only | same as v1.0.0 |
| `min_channels` | 8 | 8 EEG channels |
| `feature_layout` | \(N = N_{\mathrm{ch}}\) | **\(N = N_{\mathrm{ch}}\)** after chmean collapse (see §3.0) |
| `window_size` \(w\) | 13 | **13** (paradigm default; not re-fit) |
| `stride` | 1 | 1 |
| `min_run` | 4 | **4** |
| `theta_chaos` | 0.41 | **0.41** |
| `theta_stable` | 0.50 | **0.50** |
| `min_preictal_s` | 300 | **300** |
| `lead_lo_s` / `lead_hi_s` | 30 / 300 | **30 / 300** |
| `eval_crop` | preictal to onset | same |
| **`t_star` definition** | `first_sustained_chaos_band_run` | **`first_sustained_order_band_run`** |
| `C1_horizon_s` | 600 | 600 |
| `C1_gap_from_seizure_s` | 1800 | 1800 |
| artifact tree | `data/chbmit/` | **`data/chbmit/v1.1/`** |

### 3.0 Feature-layout amendment (still a priori, pre-score)

Draft freeze text initially allowed \(N=4\cdot N_{\mathrm{ch}}\) full band×channel columns.  
That layout is **pairwise Kendall-infeasible** at CHB-MIT scale under library `compute_taus` (\(O(N^2)\) pairs per time index).

**Operational freeze (before any chb01 lock/score):** collapse to **per-channel mean of the four log-bandpowers**:

\[
X_{k,j} = \frac{1}{4}\sum_{b=1}^{4}\log_{10}\bigl(E_{k,j,b}+\varepsilon\bigr).
\]

- Keeps multi-band spectral content and cross-channel ordinal structure (\(N=N_{\mathrm{ch}}\)).  
- Does **not** use v1.0.0 hit/miss tables.  
- Full \(4\cdot N_{\mathrm{ch}}\) layout remains available only as diagnostic code path (`collapse="full"`), not primary scorer.

### 3.1 Aggregation formula

Raw multichannel EEG → EEG-only filter (same as v1.0.0) → non-overlapping epochs of length `epoch_s`.

For epoch \(k\), channel \(j\), band \(b=(\,f_{\mathrm{lo}},f_{\mathrm{hi}}\,)\):

1. Take samples \(x_{k,j}[\cdot]\) of length \(L=\lfloor f_s\cdot\mathrm{epoch\_s}\rfloor\).  
2. Apply Hann window \(w[\cdot]\).  
3. Periodogram / one-sided PSD estimate \(P_{k,j}(f)\) (rFFT; fixed implementation unit-tested).  
4. Band energy \(E_{k,j,b} = \sum_{f\in b} P_{k,j}(f)\).  
5. Collapse (§3.0) → \(X_{k,j}\).

Then:

```text
X_agg (T_epochs × N_ch)  →  τₛ (w=13)  →  t* (order run)  →  lead_s
```

### 3.2 \(t^*\) — order polarity (primary)

Let \(\tau_g[i]\) be the gated/global τₛ series on the pre-ictal crop (same `compute_taus` path as library default).

**Order indicator:**

\[
\mathrm{order}[i] = \bigl(\lvert\tau_g[i]\rvert \ge \theta_{\mathrm{stable}}\bigr) \land \mathrm{isfinite}(\tau_g[i]).
\]

**\(t^*\)** = first index \(i\) such that \(\mathrm{order}[i..i+\mathrm{min\_run}-1]\) are all true (first sustained **order-band** run).

**Pass:** \(t^* < t_{\mathrm{obs\_epoch}}\) and

\[
\mathrm{lead\_lo\_s} \le (t_{\mathrm{obs\_epoch}} - t^*)\cdot\mathrm{epoch\_s} \le \mathrm{lead\_hi\_s}.
\]

**Not used for primary verdict:** `first_sustained_chaos_ascent` (v1.0.0). Chaos polarity may appear only in an **appendix secondary table** after primary results are frozen — never to change v1.1 params.

### 3.3 Verdict taxonomy

Same codes as v1.0.0: `hit`, `miss_lead`, `no_signal`, `post_onset_only`, `precondition_fail`, `lock_fail`.

- `no_signal`: no sustained **order** run before onset.  
- `miss_lead`: order run exists but lead outside [30, 300] s.

Primary metric: **hit rate** among series with status ≠ `precondition_fail` / `lock_fail`.

---

## 4. Precondition sanity gate (before lock)

This is the process correction to the original EEG recommendation.

### 4.1 Diagnostic panel (interictal only)

Using the **same** featureization and τₛ settings as §3, on case **chb01** (or the pre-listed pilot case):

1. Build interictal windows with the **same** C1 geometry rules:  
   length ≥ `min_preictal_s`, gap ≥ `C1_gap_from_seizure_s` from any annotated seizure.  
2. Cap at **42 windows** or all available, whichever is smaller (match v1.0.0 C1 panel size when possible).  
3. On each window, compute τₛ series; record:

| Statistic | Definition |
|-----------|------------|
| `chaos_occ` | fraction of finite samples with \(\lvert\tau\rvert < 0.41\) |
| `order_occ` | fraction of finite samples with \(\lvert\tau\rvert \ge 0.50\) |
| `mid_occ` | fraction with \(0.41 \le \lvert\tau\rvert < 0.50\) |

**Do not** compute seizure leads during this gate.  
**Do not** use v1.0.0 score files.

### 4.2 Pass / fail (frozen thresholds)

Let \(\overline{c}\) = mean `chaos_occ`, \(\overline{o}\) = mean `order_occ` over diagnostic windows with enough epochs for at least one full Kendall window.

| Gate | Pass condition | Failure mode addressed |
|------|----------------|------------------------|
| G1 ambient chaos | \(\overline{c} \le 0.90\) | v1.0.0 always-chaos floor |
| G2 order exists | \(\overline{o} \ge 0.02\) | order polarity never fires |
| G3 not frozen order | \(\overline{o} \le 0.95\) | constant hypersync / dead feature |
| G4 sample size | ≥ 5 diagnostic windows | unreliable occupancy |

- **All G1–G4 pass** → may write endpoints + lock under `data/chbmit/v1.1/`.  
- **Any fail** → **stop**. Record diagnostic JSON. Open design v1.2 (new feature/scale). **No** scoring of seizures under v1.1.

Write artifact: `data/chbmit/v1.1/precondition_diagnostic.json` with per-window stats + gate booleans.

---

## 5. Cohort and endpoints (a priori)

### 5.1 Pilot cohort (first lock)

| Field | Value |
|-------|--------|
| Cases | **`chb01` only** |
| Eligibility | same as v1.0.0: \(t_{\mathrm{obs\_s}} \ge 300\) from `chb01-summary.txt` |
| Expected \(n\) | 7 seizures (same clinical list; **new** protocol hash) |
| Independent of | v1.0.0 SHA / lock commit |

Endpoints are **re-exported** for v1.1 (new `frozen_params`, `protocol_version`, aggregation block). Clinical times are identical by construction; the **document** is not a copy of v1.0.0 JSON (different schema payload for hashing).

### 5.2 Multi-case (only after pilot scored)

Case list must be written **before** any multi-case score, e.g. `data/chbmit/v1.1/case_list_prereg.json`.  
Default proposal (not yet locked): do **not** expand until chb01 v1.1 primary table exists.

---

## 6. Lock and artifact tree

```text
data/chbmit/v1.1/
  README.md
  precondition_diagnostic.json   # gate output (required before lock)
  endpoints.json                 # pre_registered series + frozen_params v1.1
  protocol_lock.json             # SHA-256(endpoints) + frozen_params + git commit
  last_p1_eeg_score.json         # after score only
  last_c1_eeg.json               # after C1 only
```

Lock schema: same spirit as v1.0.0 (`systemic-tau-formal/p1-eeg-protocol-lock/v1`) with:

- `protocol_version`: `"1.1.0"`  
- `frozen_params`: exact table §3  
- `precondition_diagnostic_sha256`: hash of diagnostic JSON that passed G1–G4  
- `endpoints_sha256`  
- `git_commit`

Score **refuses** if:

- protocol version ≠ code freeze `1.1.0`  
- endpoints hash mismatch  
- lock missing `precondition_diagnostic_sha256` or diagnostic gates not all true  
- any `pre_registered: false` on scored rows  

v1.0.0 files under `data/chbmit/` (root) remain the historical pilot; tooling must not overwrite them when running v1.1.

---

## 7. C1 companion (v1.1)

Same geometry as v1.0.0 C1, **detector = order-band first sustained run** (not chaos).

Report:

- FP rate per window  
- FP per hour of interictal  
- Compare **narrative only** to v1.0.0 FP=1.0 (no parameter search to “beat” it)

**A priori success framing (not a p-hack target):**

| Outcome class | Interpretation |
|---------------|----------------|
| hit ≥ 3/7 **and** C1 FP rate ≤ 0.5 | **promising** — justify multi-case pre-list |
| hit ≥ 1/7 **and** C1 FP ≪ 1.0 with order polarity | **partial** — feature non-ambient, polarity weak |
| hit 0/7 or C1 FP ≈ 1.0 | **FAIL under v1.1** — redesign v1.2 or pause EEG track |
| precondition G1–G4 fail | **no score** — design incomplete |

These brackets are **reporting classes**, not optimization objectives. Do not iterate bands to enter “promising.”

---

## 8. Software map (implementation obligations)

| Path | Role |
|------|------|
| `docs/P1_EEG_CHBMIT_v1.1.md` | **This freeze** (source of truth) |
| `python/core/chbmit_io.py` | Add `epoch_log_bandpower_4` (or sibling) without breaking RMS path |
| `python/core/p1_eeg.py` **or** `p1_eeg_v11.py` | Prefer **separate module** `p1_eeg_v11.py` so v1.0.0 imports stay bit-stable |
| `python/core/p1_endpoints.py` | Add `first_sustained_order_ascent` (symmetric to chaos helper) |
| `notebooks/13_chbmit_p1_eeg_v11.py` | CLI: `precondition` / `parse` / `lock` / `score` / `c1` / `report` |
| `python/tests/test_p1_eeg_v11.py` | Synthetic: bandpower shape, order \(t^*\), lock refuse, gate logic |
| `data/chbmit/v1.1/` | Artifacts (gitignored raw EDFs; lock/report text may be committed) |

**Implementation order (mandatory):**

1. Unit tests for bandpower + order \(t^*\) on synthetic signals.  
2. `precondition` CLI → diagnostic JSON.  
3. Human review of G1–G4.  
4. `lock` only if gates pass.  
5. `score` + `c1` once.  
6. Write `docs/P1_EEG_CHB01_PILOT_REPORT_v1.1.md`.

Do **not** skip step 2–3.

---

## 9. Relation to Systemic Tau layers

| Layer | Role in v1.1 |
|-------|----------------|
| `[TEOREMA]` | Unchanged Lean CT modules — no EEG discharge of Feigenbaum |
| `[OPERACIONAL]` | θ, \(w\), min_run, order/chaos band definitions |
| `[EMPÍRICO]` | CHB-MIT hit/C1 under this freeze |

**Precondition gate** is an **empirical regime-contrast filter**, not a theorem. It operationalizes: “do not run early-warning protocol when the feature lives permanently in one band.”

---

## 10. Versioning registry

| Version | Status | Change summary |
|---------|--------|----------------|
| 1.0.0 | **LOCKED + SCORED** (chb01 FAIL EWS) | RMS @ 1 s; first chaos run; lead 30–300 s |
| **1.1.0** | **DESIGN FREEZE** (this doc) | log-bandpower 4 @ 2 s; first **order** run; precondition G1–G4; separate artifact tree |
| 1.2.x | not opened | only if G1–G4 fail or honest v1.1 FAIL after one score |

---

## 11. One-paragraph claim template (for future report)

> Under P1-EEG protocol **v1.1.0** (log-bandpower 4 bands @ 2 s; \(t^*=\) first sustained order-band run; θ/w frozen at paradigm defaults; precondition gates G1–G4 passed on interictal occupancy before lock), locked pilot on CHB-MIT chb01 yielded hit rate **H/N** and C1 FP rate **R**. This does not discharge dengue P1 and does not alter the historical v1.0.0 FAIL under chaos polarity + RMS.

---

## 12. Decision log (prioritization — explicit)

| Choice | Trade-off stated up front |
|--------|---------------------------|
| Keep θ / \(w\) from paradigm defaults | May still be sub-optimal for EEG; preserves non-p-hack of thresholds |
| Flip polarity to order | Tests hypersync hypothesis; may yield many `no_signal` if H1 false |
| Change feature to log-bandpower | Addresses ambient-chaos of RMS; introduces spectral implementation risk |
| Precondition before lock | May block scoring entirely; preferred over another ambient FAIL |
| Stay on chb01 first | Comparable clinical list to v1.0.0; not independent multi-site proof |

If the program priority shifts to “prove Tau on regime-contrast domains first,” pause implementation after this freeze and return to Aedes external \(t_{\mathrm{obs}}\) — **without** discarding this design.

---

*End of v1.1.0 design freeze. No score under this document until precondition diagnostic passes and a new lock exists.*
