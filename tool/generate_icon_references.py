#!/usr/bin/env python3
"""Rasterize every Carbon icon asset into committed reference PNGs.

For each of the 2,767 icon assets, renders the *upstream SVG* with
rsvg-convert at 2x its nominal size (2x the viewBox for bespoke glyphs) into
test/icons/references/<bucket>/<name>_<size>.png. These PNGs are the external
ground truth for the per-PR fidelity sweep (ADR 0001): they derive from
Carbon's artwork, not from our renderer, and CI compares our renders against
them without needing rsvg.

The 2x scale catches sub-pixel path errors that 1x anti-aliasing would hide,
at a modest repository cost. Re-run alongside tool/generate_carbon_icons.py
when bumping the Carbon submodule.

Run from the repository root:  python3 tool/generate_icon_references.py
Requires rsvg-convert (librsvg).
"""

from __future__ import annotations

import re
import shutil
import subprocess
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
from xml.etree import ElementTree as ET

from generate_carbon_icons import collect_assets, parse_icons_yml, validate

ROOT = Path(__file__).resolve().parent.parent
REF_DIR = ROOT / "test/icons/references"

SCALE = 2


def viewbox_of(svg_file: Path) -> tuple[float, float]:
    root = ET.parse(svg_file).getroot()
    view_box = root.get("viewBox")
    if view_box is None:
        width = re.sub(r"px$", "", root.get("width"))
        height = re.sub(r"px$", "", root.get("height") or width)
        return float(width), float(height)
    vb = [float(v) for v in view_box.split()]
    return vb[2], vb[3]


def main() -> None:
    registry = parse_icons_yml()
    icons = collect_assets()
    validate(icons, registry)

    if REF_DIR.exists():
        shutil.rmtree(REF_DIR)

    jobs = []
    for name in sorted(icons):
        for size, path in icons[name]["assets"].items():
            if size == "glyph":
                vbw, vbh = viewbox_of(path)
                width, height = round(vbw * SCALE), round(vbh * SCALE)
            else:
                width = height = size * SCALE
            out = REF_DIR / f"{name}_{size}.png"
            out.parent.mkdir(parents=True, exist_ok=True)
            jobs.append((path, width, height, out))

    def run(job) -> None:
        path, width, height, out = job
        subprocess.run(
            [
                "rsvg-convert",
                "-w", str(width),
                "-h", str(height),
                str(path),
                "-o", str(out),
            ],
            check=True,
        )

    with ThreadPoolExecutor(max_workers=8) as pool:
        list(pool.map(run, jobs))

    total = sum(1 for _ in REF_DIR.rglob("*.png"))
    size_kb = sum(p.stat().st_size for p in REF_DIR.rglob("*.png")) // 1024
    print(f"references: {total} PNGs, {size_kb} KiB, scale {SCALE}x")


if __name__ == "__main__":
    main()
