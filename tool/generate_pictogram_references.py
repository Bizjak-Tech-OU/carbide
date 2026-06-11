#!/usr/bin/env python3
"""Rasterize every Carbon pictogram into committed reference PNGs.

The pictogram analogue of tool/generate_icon_references.py: renders each
upstream SVG with rsvg-convert at 2x the 32-grid (64x64) into
test/pictograms/references/<name>_32.png. The committed corpus is external
ground truth for the per-PR pictogram fidelity sweep.

Run from the repository root:  python3 tool/generate_pictogram_references.py
Requires rsvg-convert (librsvg).
"""

from __future__ import annotations

import shutil
import subprocess
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

from generate_carbon_pictograms import collect_assets, parse_pictograms_yml, validate

ROOT = Path(__file__).resolve().parent.parent
REF_DIR = ROOT / "test/pictograms/references"

SCALE = 2


def main() -> None:
    pictograms = collect_assets()
    validate(pictograms, parse_pictograms_yml())

    if REF_DIR.exists():
        shutil.rmtree(REF_DIR)
    REF_DIR.mkdir(parents=True)

    size = 32 * SCALE

    def run(item) -> None:
        name, entry = item
        subprocess.run(
            [
                "rsvg-convert",
                "-w", str(size),
                "-h", str(size),
                str(entry["assets"][32]),
                "-o", str(REF_DIR / f"{name}_32.png"),
            ],
            check=True,
        )

    with ThreadPoolExecutor(max_workers=8) as pool:
        list(pool.map(run, sorted(pictograms.items())))

    total = sum(1 for _ in REF_DIR.glob("*.png"))
    size_kb = sum(p.stat().st_size for p in REF_DIR.glob("*.png")) // 1024
    print(f"pictogram references: {total} PNGs, {size_kb} KiB, scale {SCALE}x")


if __name__ == "__main__":
    main()
