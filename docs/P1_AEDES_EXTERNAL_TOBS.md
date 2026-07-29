# P1-Aedes — multi-trap field τₛ with external domain \(t_{\mathrm{obs}}\)

**Document ID:** `P1_AEDES_EXTERNAL_TOBS`  
**Protocol version:** `1.0.0`  
**Claim class:** `[EMPÍRICO]` dengue / vector early-warning residual  
**Software pin:** `systemic-tau-formal` (commit at lock time)

---

## 0. What this is / is not

| This is | This is not |
|---------|-------------|
| Pre-registered P1 on **multi-trap Aedes** matrices under `data/aedes/raw/` | Trap-surge / max-total leads (exploratory only) |
| \(t_{\mathrm{obs}}\) from an **external** clinical or operational domain series | Re-use of P1-EEG code or CHB-MIT claims |
| Lead window **4–6 weeks** (paradigm P1 default) | Dengue P1 “proved” from synthetic or proxy CSVs |
| Honest FAIL / miss / no_signal under frozen params | Post-hoc \(t_{\mathrm{obs}}\) after looking at \(\tau^*\) |

**Forbidden collapse:** “exploratory trap-surge hit ⇒ P1 discharged.”  
**Allowed:** “Under protocol v1.0.0, locked multi-site score vs external \(t_{\mathrm{obs}}\) supports / fails P1.”

**EEG track:** paused (2026-07-29). This document is the **priority empirical residual**.

---

## 1. Data (field series)

Committed 2018 San Juan multi-trap matrices (`data/aedes/raw/`):

| File | T × N | Calendar |
|------|-------|----------|
| `San_Juan_SJU1_Repto_Metropolitano_2018.csv` | 49 × 21 | thesis **epi weeks 4–52** (row 0 = week 4) |
| `San_Juan_SJU2_2018_epiweeks.csv` | 46 × 22 | thesis **epi weeks 7–52** (row 0 = week 7) |
| `San_Juan_SJU3_2018_12traps.csv` | 30 × 12 | `DATE` column → ISO week (irregular gaps) |

Machine-readable map: `data/aedes/raw/calendar_map.json`.

Provenance: thesis / PRVCU trap program (see `data/aedes/raw/README.md`).  
**Label:** `[EMPÍRICO]` for committed matrices in `manifest.json`.

---

## 2. External \(t_{\mathrm{obs}}\) (mandatory)

### 2.1 Allowed sources (priority order)

1. **Municipal / island clinical dengue** weekly cases for the **same calendar year** as the trap series (CDC ArboNET, PRDH / Instituto de Estadísticas, PAHO PLISA), with citation + download date.  
2. **Documented vector-control intervention** start week (agency report), if clinical incidence unavailable.  
3. **Not allowed:** trap totals, max_total, first_q90, any transform of the same matrix used for \(\tau_s\).

### 2.2 Known gap (honest)

As of protocol freeze **v1.0.0** (updated intake 2026-07-28):

- DengAI / DSIS San Juan incidence ends **~2013** (calendar mismatch with traps).  
- Field traps are **2018 San Juan**.  
- External clinical **2018** series **are now available** (OpenDengue national PRI, CDC NNDSS, PRDH Informes) — see `data/aedes/external/SOURCES_2018.md`.  
- Those series show **near-zero confirmed dengue** island-wide in 2018 (post-Zika low transmission).  
  → no clinical domain peak for `peak_week` / `first_exceed_year_p75`; `choose_external_week` returns `ok: false`.

**Consequence:** endpoints stay `t_obs: null` / `pre_registered: false` for **clinical** \(t_{\mathrm{obs}}\) until either (a) a real incidence peak year/geo is paired with traps, or (b) a documented **intervention** start week is used.  
**Do not invent** 2018 outbreak weeks from trap dynamics or from all-zero clinical CSVs.

### 2.3 A priori endpoint rules (when incidence CSV is present)

Frozen methods (choose one **before** lock; record in endpoints):

| Method ID | Definition |
|-----------|------------|
| `peak_week` | Week of **maximum** `total_cases` in the calendar span overlapping the trap series |
| `first_exceed_year_p75` | First week with `total_cases` ≥ 75th percentile of **that year’s** weekly cases (within trap span) |

Both use **only** the external incidence table.  
Map week → row via `calendar_map.json` (nearest row by epi/ISO week for SJU3 gaps).

### 2.4 Spatial honesty

Trap clusters are **neighborhood-scale**; clinical series is typically **municipal / island**.  
Document scale mismatch in every scored report. A hit does **not** prove household-level forecast skill.

---

## 3. Frozen operational params (`[OPERACIONAL]`)

| Param | Value | Notes |
|-------|-------|-------|
| `window_size` \(w\) | 13 | weekly samples |
| \(\theta_{\mathrm{ch}}\) | 0.41 | chaos band \(\lvert\tau_s\rvert < 0.41\) |
| \(\theta_{\mathrm{st}}\) | 0.50 | stable band (report only) |
| `t_star` | first sustained **chaos-band** run, length ≥ `min_run` | `core.p1_endpoints.first_sustained_chaos_ascent` |
| `min_run` | 4 | weeks |
| `lead` | \(t_{\mathrm{obs}} - t^*\) | row units ≈ weeks |
| `lead_window` | **[4, 6]** | paradigm P1 |

**No re-fit** after lock. Bump protocol version to change any of the above.

---

## 4. Pre-registration workflow

1. **Freeze** this protocol version + git commit.  
2. Place external weekly incidence (or intervention) under  
   `data/aedes/external/` (see README there).  
3. `python notebooks/14_aedes_p1_external.py propose --method peak_week`  
   → writes **candidates** only (`endpoints_candidates.json`).  
4. Human review → copy to `endpoints.json`, set `pre_registered: true` **only** for series with trusted mapping.  
5. `… lock` → SHA-256 of canonical endpoints + frozen params + commit.  
6. `… score` only if endpoints hash matches lock.  
7. Report: hits / misses / no_signal; never auto-promote exploratory leads.

### Refuse score when

| Condition | Action |
|-----------|--------|
| `pre_registered` false | refuse |
| `t_obs` null | not scored |
| endpoints hash ≠ lock | refuse |
| series stem not loaded | skip with reason |

---

## 5. Verdict classes

| Verdict | Meaning |
|---------|---------|
| `hit` | lead ∈ [4, 6] |
| `miss_lead` | \(t^*\) found, lead outside window |
| `no_signal` | no sustained chaos-band run for \(t^*\) |
| `not_scored` | null / not pre-registered / lock fail |

**P1 discharge (multi-site):** pre-registered score on ≥2 series with explicit hit-rate table.  
Single-series pilot is **characterization**, not full multi-site discharge.

---

## 6. Artifacts

| Path | Role |
|------|------|
| `docs/P1_AEDES_EXTERNAL_TOBS.md` | this protocol |
| `data/aedes/raw/calendar_map.json` | epi/ISO week ↔ row |
| `data/aedes/raw/endpoints.example.json` | scaffold |
| `data/aedes/raw/endpoints.json` | pre-registered (gitignored) |
| `data/aedes/raw/protocol_lock.json` | lock (gitignored) |
| `data/aedes/external/` | clinical / intervention intake |
| `python/core/p1_aedes.py` | propose / lock / score / report |
| `notebooks/14_aedes_p1_external.py` | CLI |
| `python/tests/test_p1_aedes.py` | synthetic integrity tests |

---

## 7. Relation to other tracks

| Track | Relation |
|-------|----------|
| Exploratory trap-surge (`exploratory_lead_scan`) | characterization only; never `pre_registered` |
| P1-EEG CHB-MIT | paused; orthogonal domain |
| DengAI 1990–2013 incidence | **not** calendar-aligned to 2018 traps; separate C3 if revived |
| Lean Feigenbaum | lab construction; does not discharge field P1 |

---

## 8. Version history

| Version | Status | Notes |
|---------|--------|-------|
| `1.0.0` | **DESIGN FREEZE** | External clinical/intervention \(t_{\mathrm{obs}}\); chaos \(t^*\); lead 4–6; calendar map for SJU1–3; 2018 cases intake pending |

Last updated: 2026-07-29.
