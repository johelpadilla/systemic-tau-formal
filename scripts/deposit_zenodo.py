#!/usr/bin/env python3
"""Create a Zenodo deposition draft (or publish) for systemic-tau-formal.

Environment
-----------
  ZENODO_TOKEN   PAT with deposit:write (+ deposit:actions to publish)
  ZENODO_BASE    default https://zenodo.org

Usage
-----
  python scripts/deposit_zenodo.py              # draft + upload archive
  python scripts/deposit_zenodo.py --publish    # publish (irreversible)
"""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

try:
    import requests
except ImportError:
    sys.exit("Need requests: pip install requests")

ROOT = Path(__file__).resolve().parents[1]
META_PATH = ROOT / "zenodo" / "metadata.json"
STATE_PATH = ROOT / "zenodo" / "deposition_state.json"

INCLUDE_DIRS = ["lean", "python", "notebooks", "docs", "fixtures", "data", "papers", ".github"]
INCLUDE_FILES = [
    "README.md",
    "STATUS.md",
    "LICENSE",
    "CITATION.cff",
    "CONTRIBUTING.md",
    "zenodo/metadata.json",
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
        sys.exit(
            "Missing ZENODO_TOKEN.\n"
            "Create one at https://zenodo.org/account/settings/applications/tokens/new/\n"
            "Scopes: deposit:write and deposit:actions\n"
            "Then: export ZENODO_TOKEN='...'\n"
            "Or use GitHub↔Zenodo (docs/ZENODO.md Option A)."
        )
    base = os.environ.get("ZENODO_BASE", "https://zenodo.org").rstrip("/")
    return tok, base


def build_archive(dest: Path) -> Path:
    """Zip releasable tree (no .git, no venv, no .lake)."""
    zip_path = dest / "systemic-tau-formal-0.1.4.zip"
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for rel in INCLUDE_FILES:
            p = ROOT / rel
            if p.is_file():
                zf.write(p, arcname=f"systemic-tau-formal/{rel}")
        for d in INCLUDE_DIRS:
            base = ROOT / d
            if not base.exists():
                continue
            for p in base.rglob("*"):
                if not p.is_file():
                    continue
                if any(part in {".venv", ".lake", "__pycache__", ".pytest_cache", "egg-info"} for part in p.parts):
                    continue
                if p.suffix in {".pyc", ".olean"}:
                    continue
                arc = p.relative_to(ROOT)
                zf.write(p, arcname=f"systemic-tau-formal/{arc}")
    return zip_path


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--publish", action="store_true", help="Publish after upload (irreversible)")
    ap.add_argument("--sandbox", action="store_true", help="Use sandbox.zenodo.org")
    args = ap.parse_args()

    tok, base = token_and_base()
    if args.sandbox:
        base = "https://sandbox.zenodo.org"

    headers = {"Authorization": f"Bearer {tok}"}
    meta = json.loads(META_PATH.read_text(encoding="utf-8"))

    print(f"Creating deposition at {base} ...")
    r = requests.post(f"{base}/api/deposit/depositions", json={}, headers=headers, timeout=60)
    r.raise_for_status()
    dep = r.json()
    dep_id = dep["id"]
    bucket = dep["links"]["bucket"]
    print(f"  deposition id = {dep_id}")

    with tempfile.TemporaryDirectory() as td:
        archive = build_archive(Path(td))
        print(f"  uploading {archive.name} ({archive.stat().st_size} bytes) ...")
        with archive.open("rb") as fh:
            ur = requests.put(
                f"{bucket}/{archive.name}",
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
    mr.raise_for_status()
    dep = mr.json()

    state = {
        "deposition_id": dep_id,
        "base": base,
        "conceptrecid": dep.get("conceptrecid"),
        "doi": dep.get("metadata", {}).get("prereserve_doi", {}).get("doi"),
        "links": dep.get("links", {}),
        "published": False,
    }

    if args.publish:
        print("  publishing ...")
        pr = requests.post(
            f"{base}/api/deposit/depositions/{dep_id}/actions/publish",
            headers=headers,
            timeout=60,
        )
        pr.raise_for_status()
        dep = pr.json()
        state["published"] = True
        state["doi"] = dep.get("doi") or state["doi"]
        state["links"] = dep.get("links", state["links"])
        print(f"  PUBLISHED DOI: {state['doi']}")
    else:
        print(f"  DRAFT ready. Prereserved DOI: {state['doi']}")
        print(f"  Edit: {state['links'].get('html', dep.get('links', {}).get('html'))}")

    STATE_PATH.parent.mkdir(parents=True, exist_ok=True)
    STATE_PATH.write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")
    print(f"  state → {STATE_PATH}")


if __name__ == "__main__":
    main()
