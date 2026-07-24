# Zenodo deposit guide

## Published DOIs

| Role | DOI | Link |
|------|-----|------|
| **This version (v0.1.8)** | *set in `deposition_state.json` after publish* | concept latest |
| **Concept** (all versions → latest) | `10.5281/zenodo.21516059` | https://doi.org/10.5281/zenodo.21516059 |
| **v0.1.7** | `10.5281/zenodo.21522346` | https://doi.org/10.5281/zenodo.21522346 |
| **v0.1.6** | `10.5281/zenodo.21516523` | https://doi.org/10.5281/zenodo.21516523 |
| **v0.1.5** | `10.5281/zenodo.21516329` | https://doi.org/10.5281/zenodo.21516329 |
| **v0.1.4** | `10.5281/zenodo.21516060` | https://doi.org/10.5281/zenodo.21516060 |

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
| Version DOI in `CITATION.cff` / `deposition_state.json` | This formal monorepo (v0.1.8) |
| `10.5281/zenodo.21516059` | Concept / always-latest |
| `10.5281/zenodo.21522346` | Pin v0.1.7 |
| `10.5281/zenodo.21516523` | Pin v0.1.6 |
| `10.5281/zenodo.21516329` | Pin v0.1.5 |
| `10.5281/zenodo.21516060` | Pin v0.1.4 |
| `10.5281/zenodo.20576241` | Broader Systemic Tau corpus / prior software |
| PyPI `systemictau` | Production analysis pipeline |
