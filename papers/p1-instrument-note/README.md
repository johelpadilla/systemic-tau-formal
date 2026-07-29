# P1 instrument note (outline) — draft for short preprint

**Working title:**  
*Ordinal chaos-band early warning: instrument recovery under a synthetic plant, multi-domain field residual, and ambient false-alarm stress*

**Status:** outline only (not a frozen manuscript)  
**Software pin:** `systemic-tau-formal` **v0.1.12**  
**Canonical synthesis:** [`docs/P1_FAIL_TRIPTYCH.md`](../../docs/P1_FAIL_TRIPTYCH.md)

---

## 1. Claim (one paragraph)

A frozen multi-channel Kendall-τ chaos-band detector (\(w=13\), \(\theta_{\mathrm{ch}}=0.41\),
`min_run=4`, lead window \([4,6]\)) **recovers** a known order→chaos structural break on a
canonical synthetic plant (20/20 hits; instrument gates PASS) but **does not** support
deployable early warning: (i) multi-domain field panels (Aedes Vitória, ILI→FluSurv, EEG
CHB-MIT) fail primary lead claims under the same freeze; (ii) pure ambient noise yields
C1 false-positive rate 1.0. Instrument skill ≠ specificity under ambient chaos.

**Not claimed:** dengue/flu/seizure forecasting skill; ontological discharge; classical
Feigenbaum universality.

---

## 2. Suggested structure (~6–8 pages)

| § | Content | Repo sources |
|---|---------|--------------|
| 1 | Motivation: EWS vs ordinal τ; honesty labels | `docs/EPISTEMIC_LABELS.md` |
| 2 | Frozen detector + C1 definition | `docs/P1_SYNTHETIC_CANONICAL.md` §2–4b |
| 3 | Synthetic plant + nulls; G1–G4 | report + `last_gates.json` |
| 4 | C1A/B/C stress; G4 ≠ C1C | `last_c1.json` |
| 5 | Field residual table (Vitória / ILI / EEG) | domain reports |
| 6 | Fail-triptych logic | `P1_FAIL_TRIPTYCH.md` |
| 7 | Discussion: guard design (optional pointer) | `P1_C1_GUARD_DESIGN.md` |
| 8 | Reproduce + data/code availability | nb 16, Zenodo software DOI |

---

## 3. Tables to freeze in the paper

1. **Frozen parameters** (one row block).  
2. **Synthetic scoreboard:** plant hit-rate, lag median, C1A/B/C.  
3. **Field scoreboard:** domain × n × hit-rate × dominant failure × C1 if available.  
4. **Allowed/forbidden claims** (from triptych §5).

---

## 4. Figures (minimal)

1. Plant τ path: order → switch → planted \(t_{\mathrm{obs}}\); mark \(t^*\).  
2. Pure-noise τ path: early \(t^*\), no event in horizon.  
3. Optional: lead histogram plant vs miss modes field (schematic).

CLI seed material: `python notebooks/16_p1_synthetic_canonical.py run`.

---

## 5. Keywords

early warning signals · Kendall tau · ordinal dynamics · false positives · synthetic
validation · dengue · influenza · EEG · open science · negative results

---

## 6. Next drafting steps (when reopened)

- [ ] Draft §1–3 in Markdown under this folder  
- [ ] Export 2 figures from nb 16  
- [ ] Cite software concept DOI `10.5281/zenodo.21516059` + version DOI for v0.1.12  
- [ ] Submit as short note / arXiv cs.SI or q-bio.QM (author choice)  
- [ ] Do **not** wait for C1 guard implementation — the negative C1C result is the point  

---

## 7. Honesty footer

This README is an **outline**, not a deposited paper. The citable scientific package is the
software release + protocol/report markdown under `docs/P1_*`.
