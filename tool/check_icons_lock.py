#!/usr/bin/env python3
"""CI drift guard: the icon lockfile must match the pinned Carbon submodule.

Compares the submodule commit recorded in tool/carbon_icons.lock.json against
the gitlink in the repository tree. A mismatch means the submodule was bumped
without regenerating the icons — which must not merge. Works without the
submodule being checked out, so CI stays light.

If the bump did not touch the icons package, regeneration produces no Dart or
reference changes — only the refreshed lockfile commit — which is exactly the
auditable record we want.

Exits non-zero on drift. Run from the repository root (or CI).
"""

from __future__ import annotations

import sys

import icons_lock


LOCKFILES = {
    "icon": icons_lock.LOCKFILE,
    "pictogram": icons_lock.ROOT / "tool/carbon_pictograms.lock.json",
}


def main() -> int:
    pinned = icons_lock.carbon_commit_from_gitlink()
    failures = 0
    for kind, lockfile in LOCKFILES.items():
        lock = icons_lock.read_lock(lockfile)
        if lock is None:
            print(f"missing {lockfile.name} — run the {kind} generator")
            failures += 1
            continue
        recorded = lock.get("carbonCommit", "")
        if recorded != pinned:
            print(
                f"{kind} lockfile drift:\n"
                f"  lockfile generated from carbon {recorded[:12]}\n"
                f"  repository pins carbon       {pinned[:12]}\n"
                f"  -> run tool/generate_carbon_{kind}s.py and "
                f"tool/generate_{kind}_references.py, review the diff "
                "report, and commit the result (see docs/ICON_UPDATES.md)."
            )
            failures += 1
        else:
            print(f"{kind} lockfile in sync with carbon {pinned[:12]}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
