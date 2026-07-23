#!/usr/bin/env python3
"""Export golden constants to fixtures/golden_constants.json."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from core.golden import golden_payload  # noqa: E402


def main() -> None:
    out = ROOT.parent / "fixtures" / "golden_constants.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    payload = golden_payload()
    out.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {out}")


if __name__ == "__main__":
    main()
