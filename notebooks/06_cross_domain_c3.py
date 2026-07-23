"""
06 — C3 cross-domain *synthetic* starters (finance / EEG / grid-like).

[OPERACIONAL] Lab panels only — not markets, not clinical EEG, not SCADA.
Real domain transfers must follow docs/EXPERIMENTAL_PROTOCOL.md and use
licensed data; file results on GitHub with label `new-domain` (issue #4).

See docs/CROSS_DOMAIN.md.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))

from core import (  # noqa: E402
    eeg_like_channels,
    finance_like_returns,
    format_report,
    grid_like_loads,
    pipeline_report,
)


def main():
    print("=== 06_cross_domain_c3 ===")
    print("[OPERACIONAL] Synthetic domain *shape* demos for C3 track.\n")

    demos = []

    X, meta = finance_like_returns(T=500, N=5, seed=10)
    demos.append(pipeline_report(X, name="finance_like_returns", meta=meta))

    X, meta = eeg_like_channels(T=800, N=6, seed=11)
    demos.append(pipeline_report(X, name="eeg_like_channels", meta=meta))

    X, meta = grid_like_loads(T=400, N=4, seed=12)
    demos.append(pipeline_report(X, name="grid_like_loads", meta=meta))

    for rep in demos:
        print(format_report(rep))
        print()

    print("Predictions P1–P4: docs/FALSIFIABLE_PREDICTIONS.md")
    print("Challenge C3: docs/CHALLENGES.md · tracking issue #4")
    print("Protocol report format: docs/EXPERIMENTAL_PROTOCOL.md §7")
    # machine-readable for optional tooling
    out = ROOT / "data" / "synthetic" / "cross_domain_last_run.json"
    try:
        out.write_text(json.dumps(demos, indent=2) + "\n", encoding="utf-8")
        print(f"\nWrote {out.relative_to(ROOT)} (gitignored if large; fine if missing)")
    except OSError:
        pass


if __name__ == "__main__":
    main()
