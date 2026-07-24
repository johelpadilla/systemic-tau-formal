# Zenodo deposit guide

## Published DOIs

### Software monorepo (`systemic-tau-formal`)

| Role | DOI | Link |
|------|-----|------|
| **This version (v0.1.8)** | `10.5281/zenodo.21522882` | https://doi.org/10.5281/zenodo.21522882 |
| **Concept** (all versions → latest) | `10.5281/zenodo.21516059` | https://doi.org/10.5281/zenodo.21516059 |
| Record page (v0.1.8) | — | https://zenodo.org/records/21522882 |
| **v0.1.7** | `10.5281/zenodo.21522346` | https://doi.org/10.5281/zenodo.21522346 |
| **v0.1.6** | `10.5281/zenodo.21516523` | https://doi.org/10.5281/zenodo.21516523 |
| **v0.1.5** | `10.5281/zenodo.21516329` | https://doi.org/10.5281/zenodo.21516329 |
| **v0.1.4** | `10.5281/zenodo.21516060` | https://doi.org/10.5281/zenodo.21516060 |

### Operational-standard preprint (publication)

| Role | DOI | Link |
|------|-----|------|
| **Preprint 0.1.8-r3** | `10.5281/zenodo.21523232` | https://doi.org/10.5281/zenodo.21523232 |
| **Concept** (preprint series) | `10.5281/zenodo.21523231` | https://doi.org/10.5281/zenodo.21523231 |
| Record page | — | https://zenodo.org/records/21523232 |
| Deposit script | `scripts/deposit_preprint_zenodo.py` | metadata `zenodo/preprint_metadata.json` |
| State | `zenodo/preprint_deposition_state.json` | — |

Distinct from the prior Magna/software archive `10.5281/zenodo.20576241`.

## v0.1.8 description source

Deposit description is in `zenodo/metadata.json` (adapted from
[`FORMAL_OBLIGATIONS.md` §7.2](FORMAL_OBLIGATIONS.md)).

Do **not** claim classical Feigenbaum universality, termwise superstable roots,
or field-derived τₛ return in the Zenodo abstract. Lab / construction discharge is OK.

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
| `10.5281/zenodo.21523232` | **English operational-standard preprint** (0.1.8-r3) |
| `10.5281/zenodo.21523231` | Preprint concept / always-latest document version |
| `10.5281/zenodo.21522882` | This formal monorepo (v0.1.8) |
| `10.5281/zenodo.21516059` | Software concept / always-latest |
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
# 3. python3 scripts/deposit_preprint_zenodo.py --publish
#    (currently creates a *new* concept each run; for concept continuity,
#     extend the script with newversion against preprint_deposition_state.json)
# 4. Record DOI in this file + papers/preprint-standard-formal/README.md
```
