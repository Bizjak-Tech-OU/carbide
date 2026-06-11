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


def main() -> int:
    lock = icons_lock.read_lock()
    if lock is None:
        print("missing tool/carbon_icons.lock.json — run the icon generator")
        return 1
    recorded = lock.get("carbonCommit", "")
    pinned = icons_lock.carbon_commit_from_gitlink()
    if recorded != pinned:
        print(
            "icon lockfile drift:\n"
            f"  lockfile generated from carbon {recorded[:12]}\n"
            f"  repository pins carbon       {pinned[:12]}\n"
            "  -> run tool/generate_carbon_icons.py and "
            "tool/generate_icon_references.py, review the diff report, and "
            "commit the result (see docs/ICON_UPDATES.md)."
        )
        return 1
    print(f"icon lockfile in sync with carbon {pinned[:12]}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
