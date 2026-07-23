# Zenodo deposit guide

## Published DOIs (v0.1.4)

| Role | DOI | Link |
|------|-----|------|
| **This version** | `10.5281/zenodo.21516060` | https://doi.org/10.5281/zenodo.21516060 |
| **Concept** (all versions) | `10.5281/zenodo.21516059` | https://doi.org/10.5281/zenodo.21516059 |
| Record page | — | https://zenodo.org/records/21516060 |

Distinct from the prior Magna/software archive `10.5281/zenodo.20576241`.

## New versions

```bash
# bump version in CITATION.cff / zenodo/metadata.json / archive name in script
export ZENODO_TOKEN='...'   # or ~/.zenodo_token
python scripts/deposit_zenodo.py --publish
```

Or use Zenodo “New version” on the existing concept record.

Metadata template: `zenodo/metadata.json`.

## What to cite

| Artifact | Cite when |
|----------|-----------|
| `10.5281/zenodo.21516060` | This formal Lean/Python monorepo (v0.1.4) |
| `10.5281/zenodo.21516059` | Concept (always points to latest) |
| `10.5281/zenodo.20576241` | Broader Systemic Tau corpus / prior software |
| PyPI `systemictau` | Production analysis pipeline |
