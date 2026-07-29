# Zenodo deposit guide

## Published DOIs

### Software monorepo (`systemic-tau-formal`)

| Role | DOI | Link |
|------|-----|------|
| **This version (v0.1.12)** | *(Zenodo pending — GitHub release live)* | https://github.com/johelpadilla/systemic-tau-formal/releases/tag/v0.1.12 |
| **Prior (v0.1.11)** | `10.5281/zenodo.21581189` | https://doi.org/10.5281/zenodo.21581189 |
| **Prior (v0.1.10)** | `10.5281/zenodo.21537465` | https://doi.org/10.5281/zenodo.21537465 |
| **Prior (v0.1.9)** | `10.5281/zenodo.21536462` | https://doi.org/10.5281/zenodo.21536462 |
| **Concept** (all versions → latest) | `10.5281/zenodo.21516059` | https://doi.org/10.5281/zenodo.21516059 |
| Record page (v0.1.11) | — | https://zenodo.org/records/21581189 |
| Record page (v0.1.10) | — | https://zenodo.org/records/21537465 |
| Record page (v0.1.9) | — | https://zenodo.org/records/21536462 |
| **v0.1.8** | `10.5281/zenodo.21522882` | https://doi.org/10.5281/zenodo.21522882 |
| **v0.1.7** | `10.5281/zenodo.21522346` | https://doi.org/10.5281/zenodo.21522346 |
| **v0.1.6** | `10.5281/zenodo.21516523` | https://doi.org/10.5281/zenodo.21516523 |
| **v0.1.5** | `10.5281/zenodo.21516329` | https://doi.org/10.5281/zenodo.21516329 |
| **v0.1.4** | `10.5281/zenodo.21516060` | https://doi.org/10.5281/zenodo.21516060 |

### Module CT technical note (publication)

| Role | DOI | Link |
|------|-----|------|
| **Module CT note v0.1** | `10.5281/zenodo.21582078` | https://doi.org/10.5281/zenodo.21582078 |
| **Concept** (note series) | `10.5281/zenodo.21582077` | https://doi.org/10.5281/zenodo.21582077 |
| Record page | — | https://zenodo.org/records/21582078 |
| Deposit script | `scripts/deposit_module_ct_note_zenodo.py` | metadata `zenodo/module_ct_note_metadata.json` |
| State | `zenodo/module_ct_note_deposition_state.json` | — |
| Source path | `papers/module-ct-note/` | PDF + Markdown + README |

Distinct concept from the software monorepo and from the operational-standard preprint series.

### Operational-standard preprint (publication)

| Role | DOI | Link |
|------|-----|------|
| **Preprint 0.1.10-r2** | `10.5281/zenodo.21537494` | https://doi.org/10.5281/zenodo.21537494 |
| **Prior preprint 0.1.10-r1** | `10.5281/zenodo.21537484` | https://doi.org/10.5281/zenodo.21537484 |
| **Prior preprint 0.1.9-r2** | `10.5281/zenodo.21537494` | https://doi.org/10.5281/zenodo.21537494 |
| **Concept** (preprint series) | `10.5281/zenodo.21523231` | https://doi.org/10.5281/zenodo.21523231 |
| Record page | — | https://zenodo.org/records/21536484 |
| Prior preprint 0.1.9-r1 | `10.5281/zenodo.21536465` | https://doi.org/10.5281/zenodo.21536465 |
| Prior preprint 0.1.8-r3 | `10.5281/zenodo.21523232` | https://doi.org/10.5281/zenodo.21523232 |
| Deposit script | `scripts/deposit_preprint_zenodo.py` | metadata `zenodo/preprint_metadata.json` |
| State | `zenodo/preprint_deposition_state.json` | — |

Distinct from the prior Magna/software archive `10.5281/zenodo.20576241`.

## v0.1.12 description source

Deposit description is in `zenodo/metadata.json` (**P1 instrument + multi-domain residual**
pack: synthetic INSTRUMENT_PASS, C1_STRESS_FAIL, Vitória/ILI/EEG residuals, fail-triptych).
Synthesis: [`P1_FAIL_TRIPTYCH.md`](P1_FAIL_TRIPTYCH.md). Short-note outline:
[`papers/p1-instrument-note/`](../papers/p1-instrument-note/).

## v0.1.11 description source

Module CT residual pack + prior Feigenbaum honesty. See also
[`RECD_vs_Thermodynamic_Time.md`](RECD_vs_Thermodynamic_Time.md).

Do **not** claim classical Feigenbaum universality, termwise superstable roots,
Skorokhod continuum limits, or field-derived τₛ return in the Zenodo abstract.
Lab / pathwise discrete discharge is OK.

## New versions

```bash
# 1. Bump version in zenodo/metadata.json + CITATION.cff + README/STATUS
#    (paste/adapt FORMAL_OBLIGATIONS §7 into metadata description)
# 2. Commit + git tag vX.Y.Z + GitHub release
# 3. Publish under the same concept:
export ZENODO_TOKEN='...'   # or ~/.zenodo_token
python3 scripts/deposit_zenodo.py --newversion --publish
# 4. Record the new version DOI in README / CITATION.cff / this file
```

Script flags:

| Flag | Meaning |
|------|---------|
| (none) | Brand-new deposition (new concept) |
| `--newversion` | New version of concept from `deposition_state.json` |
| `--publish` | Publish after upload (irreversible) |
| `--sandbox` | Use sandbox.zenodo.org |

Metadata template: `zenodo/metadata.json` (version field drives the zip name).

## What to cite

| Artifact | Cite when |
|----------|-----------|
| `10.5281/zenodo.21582078` | **Module CT technical note** (RECD vs classical thermodynamic time) |
| `10.5281/zenodo.21582077` | Module CT note concept / always-latest document version |
| `10.5281/zenodo.21537494` | **English operational-standard preprint** (0.1.9-r2) |
| `10.5281/zenodo.21523232` | Prior preprint 0.1.8-r3 |
| `10.5281/zenodo.21523231` | Preprint concept / always-latest document version |
| `10.5281/zenodo.21516059` | Software concept / always-latest (use until v0.1.12 version DOI lands) |
| `10.5281/zenodo.21581189` | Formal monorepo v0.1.11 |
| `10.5281/zenodo.21537465` | Prior monorepo v0.1.10 |
| `10.5281/zenodo.21536462` | Prior monorepo v0.1.9 |
| `10.5281/zenodo.21522882` | Prior monorepo v0.1.8 |
| `10.5281/zenodo.21522346` | Pin v0.1.7 |
| `10.5281/zenodo.21516523` | Pin v0.1.6 |
| `10.5281/zenodo.21516329` | Pin v0.1.5 |
| `10.5281/zenodo.21516060` | Pin v0.1.4 |
| `10.5281/zenodo.20576241` | Broader Systemic Tau corpus / prior software |
| PyPI `systemictau` | Production analysis pipeline |

## New preprint document versions

```bash
# 1. Bump papers/preprint-standard-formal/VERSION (e.g. 0.1.8-r4)
# 2. Freeze pins/standard-formal-v….pdf + update zenodo/preprint_metadata.json
# 3. python3 scripts/deposit_preprint_zenodo.py --newversion --publish
#    (currently creates a *new* concept each run; for concept continuity,
#     extend the script with newversion against preprint_deposition_state.json)
# 4. Record DOI in this file + papers/preprint-standard-formal/README.md
```

## Module CT technical note versions

```bash
# 1. Update papers/module-ct-note/ (md + rebuild PDF)
# 2. Bump version in zenodo/module_ct_note_metadata.json
# 3. python3 scripts/deposit_module_ct_note_zenodo.py --newversion --publish
# 4. Record DOI in this file + papers/module-ct-note/README.md + STATUS.md
```

## v0.1.12 publish log (2026-07-29)

- Git tag + GitHub release: **v0.1.12** (commit `76c1641`), zip attached (~1.95 MB; no EDFs).
- Zenodo `--newversion` created draft `21661989` then **file upload returned HTTP 400**
  (`The file upload transfer failed`) for both bucket PUT and multipart; tiny-file
  repro also failed. Empty draft discarded. Prior published state remains v0.1.11
  (`deposition_id` 21581189).
- Retry when Zenodo storage accepts uploads:
  `python3 scripts/deposit_zenodo.py --newversion --publish`
  then record the new version DOI in README / CITATION.cff / this table.
- Pending note (local): `zenodo/deposition_state.v0.1.12-pending.json` (gitignored pattern optional).
