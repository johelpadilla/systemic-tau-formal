# Zenodo deposit guide

## Published DOIs

| Role | DOI | Link |
|------|-----|------|
| **Concept** (all versions → latest) | `10.5281/zenodo.21516059` | https://doi.org/10.5281/zenodo.21516059 |
| **v0.1.4** | `10.5281/zenodo.21516060` | https://doi.org/10.5281/zenodo.21516060 |
| **v0.1.5** | *(see `zenodo/deposition_state.json` after publish)* | concept latest |

Distinct from the prior Magna/software archive `10.5281/zenodo.20576241`.

## New versions

```bash
# 1. Bump version in zenodo/metadata.json + CITATION.cff + README/STATUS
# 2. Commit + git tag vX.Y.Z + GitHub release
# 3. Publish under the same concept:
export ZENODO_TOKEN='...'   # or ~/.zenodo_token
python scripts/deposit_zenodo.py --newversion --publish
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
| `10.5281/zenodo.21516059` | Concept / always-latest formal monorepo |
| Version-specific DOI | Pinning a exact release (v0.1.4, v0.1.5, …) |
| `10.5281/zenodo.20576241` | Broader Systemic Tau corpus / prior software |
| PyPI `systemictau` | Production analysis pipeline |
