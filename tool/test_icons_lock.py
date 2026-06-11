#!/usr/bin/env python3
"""Self-tests for the icon lockfile differ (run in CI).

Plain asserts on synthetic locks — no test framework needed.
Run from anywhere:  python3 tool/test_icons_lock.py
"""

from __future__ import annotations

from icons_lock import diff_locks, format_report, has_changes


def lock(assets: dict[str, str], deprecated: list[str] | None = None) -> dict:
    return {
        "carbonCommit": "test",
        "assets": assets,
        "deprecated": deprecated or [],
    }


def main() -> None:
    base = lock({"add_32": "h1", "apps_16": "h2", "apps_32": "h3"}, ["old-icon"])

    # No changes.
    diff = diff_locks(base, base)
    assert not has_changes(diff), diff
    assert format_report(diff) == "icon diff: no changes"

    # One of each category.
    changed = lock(
        {"add_32": "h1", "apps_16": "MUTATED", "new-icon_32": "h9"},
        ["apps"],
    )
    diff = diff_locks(base, changed)
    assert diff["added"] == ["new-icon_32"], diff
    assert diff["removed"] == ["apps_32"], diff
    assert diff["modified"] == ["apps_16"], diff
    assert diff["newlyDeprecated"] == ["apps"], diff
    assert diff["undeprecated"] == ["old-icon"], diff
    assert has_changes(diff)

    report = format_report(diff)
    for fragment in (
        "added (1):",
        "new-icon_32",
        "modified (1):",
        "removed (1):",
        "newlyDeprecated (1):",
        "undeprecated (1):",
        "regenerate references",
    ):
        assert fragment in report, f"missing {fragment!r} in:\n{report}"

    # Size variants are tracked independently.
    grew = lock({"add_32": "h1", "add_16": "h4", "apps_16": "h2", "apps_32": "h3"},
                ["old-icon"])
    diff = diff_locks(base, grew)
    assert diff["added"] == ["add_16"], diff
    assert diff["modified"] == [], diff

    print("icons_lock self-tests passed")


if __name__ == "__main__":
    main()
