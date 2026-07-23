# Zenodo deposit guide

Goal: citable DOI for **this** formal monorepo (distinct from the Magna/software archive `10.5281/zenodo.20576241`).

## Option A — GitHub ↔ Zenodo (recommended)

1. Log in at [zenodo.org](https://zenodo.org) with the same GitHub account.  
2. **GitHub** → enable the `systemic-tau-formal` repository.  
3. On GitHub: create a release (or use the existing `v0.1.4`).  
4. Zenodo mints a DOI automatically for the release archive.  
5. Paste the DOI into `CITATION.cff` and `STATUS.md`, then commit.

## Option B — Manual API deposit

```bash
export ZENODO_TOKEN='...'   # deposit:write (+ deposit:actions to publish)
python scripts/deposit_zenodo.py           # draft only
python scripts/deposit_zenodo.py --publish # irreversible publish
```

Metadata template: `zenodo/metadata.json`.

## What to cite

| Artifact | Cite when |
|----------|-----------|
| This monorepo DOI (pending first deposit) | Formal Lean/Python verification package |
| `10.5281/zenodo.20576241` | Broader Systemic Tau corpus / prior software |
| PyPI `systemictau` | Production analysis pipeline |

## Version alignment

Release tags should match `CITATION.cff` `version` (currently **0.1.4**).
