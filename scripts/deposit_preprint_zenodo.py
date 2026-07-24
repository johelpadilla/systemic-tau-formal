#!/usr/bin/env python3
"""Deposit the operational-standard preprint PDF (+ source) to Zenodo.

Creates a *new* publication concept (not a software newversion).

  export ZENODO_TOKEN=...   # or ~/.zenodo_token
  python3 scripts/deposit_preprint_zenodo.py --publish
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

try:
    import requests
except ImportError:
    sys.exit("Need requests: pip install requests")

ROOT = Path(__file__).resolve().parents[1]
META_PATH = ROOT / "zenodo" / "preprint_metadata.json"
STATE_PATH = ROOT / "zenodo" / "preprint_deposition_state.json"
PAPER = ROOT / "papers" / "preprint-standard-formal"

FILES = [
    PAPER / "pins" / "standard-formal-v0.1.8-r3.pdf",
    PAPER / "main.tex",
    PAPER / "VERSION",
    PAPER / "CHANGELOG.md",
    PAPER / "README.md",
    PAPER / "pins" / "SHA256SUMS",
]


def token_and_base() -> tuple[str, str]:
    tok = os.environ.get("ZENODO_TOKEN", "").strip()
    if not tok:
        for cand in (ROOT / ".zenodo_token", Path.home() / ".zenodo_token"):
            if cand.is_file():
                tok = cand.read_text(encoding="utf-8").strip().splitlines()[0].strip()
                if tok:
                    break
    if not tok:
        sys.exit("Missing ZENODO_TOKEN (env or ~/.zenodo_token)")
    base = os.environ.get("ZENODO_BASE", "https://zenodo.org").rstrip("/")
    return tok, base


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--publish", action="store_true")
    ap.add_argument("--sandbox", action="store_true")
    args = ap.parse_args()

    tok, base = token_and_base()
    if args.sandbox:
        base = "https://sandbox.zenodo.org"

    headers = {"Authorization": f"Bearer {tok}"}
    meta = json.loads(META_PATH.read_text(encoding="utf-8"))

    missing = [str(p) for p in FILES if not p.is_file()]
    if missing:
        sys.exit("Missing files:\n  " + "\n  ".join(missing))

    print(f"Creating preprint deposition at {base} ...")
    r = requests.post(f"{base}/api/deposit/depositions", json={}, headers=headers, timeout=60)
    r.raise_for_status()
    dep = r.json()
    dep_id = dep["id"]
    bucket = dep["links"]["bucket"]
    print(f"  deposition id = {dep_id}")

    for path in FILES:
        name = path.name
        print(f"  uploading {name} ({path.stat().st_size} bytes) ...")
        with path.open("rb") as fh:
            ur = requests.put(
                f"{bucket}/{name}",
                data=fh,
                headers={**headers, "Content-Type": "application/octet-stream"},
                timeout=300,
            )
            ur.raise_for_status()

    print("  putting metadata ...")
    mr = requests.put(
        f"{base}/api/deposit/depositions/{dep_id}",
        data=json.dumps(meta),
        headers={**headers, "Content-Type": "application/json"},
        timeout=60,
    )
    if not mr.ok:
        print(mr.text[:2000], file=sys.stderr)
        mr.raise_for_status()
    dep = mr.json()

    state = {
        "deposition_id": dep_id,
        "base": base,
        "conceptrecid": dep.get("conceptrecid"),
        "doi": dep.get("metadata", {}).get("prereserve_doi", {}).get("doi"),
        "version": meta["metadata"]["version"],
        "links": dep.get("links", {}),
        "published": False,
        "kind": "preprint-standard-formal",
    }

    if args.publish:
        print("  publishing ...")
        pr = requests.post(
            f"{base}/api/deposit/depositions/{dep_id}/actions/publish",
            headers=headers,
            timeout=60,
        )
        if not pr.ok:
            print(pr.text[:2000], file=sys.stderr)
            pr.raise_for_status()
        dep = pr.json()
        state["published"] = True
        state["doi"] = dep.get("doi") or state["doi"]
        state["links"] = dep.get("links", state["links"])
        state["conceptrecid"] = dep.get("conceptrecid") or state["conceptrecid"]
        print(f"  PUBLISHED DOI: {state['doi']}")
        print(f"  Concept: 10.5281/zenodo.{state.get('conceptrecid')}")
        print(f"  HTML: {state['links'].get('html')}")
    else:
        print(f"  DRAFT. Prereserved DOI: {state['doi']}")
        print(f"  Edit: {state['links'].get('html')}")

    STATE_PATH.write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")
    print(f"  state → {STATE_PATH}")


if __name__ == "__main__":
    main()
