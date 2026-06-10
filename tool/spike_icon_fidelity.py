#!/usr/bin/env python3
"""Spike #29: extract representative Carbon icons and upstream references.

Parses a feature-exercising sample of Carbon icon/pictogram SVGs into shape
data, emits a Dart test fixture, and rasterizes the *upstream SVGs* with
rsvg-convert into reference PNGs. The Dart spike test then renders the
extracted data via dart:ui and compares it pixel-wise against those
references — establishing the empirical fidelity numbers for the icon
rendering ADR.

Run from the repository root:  python3 tool/spike_icon_fidelity.py
Requires rsvg-convert (librsvg) for reference rasterization.
"""

from __future__ import annotations

import math
import re
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ICONS = ROOT / "documentation/carbon/packages/icons/src/svg"
PICTOS = ROOT / "documentation/carbon/packages/pictograms/src/svg"
FIXTURE = ROOT / "test/spike/spike_icon_data.dart"
REF_DIR = ROOT / "test/spike/references"

# (logical name, source file, render sizes). Chosen to exercise: polygons,
# bespoke 16px artwork, invisible-element normalization, evenodd fill rule,
# real rotate transforms, namespaces (watson-health, Q), circles, pictograms.
# Icons get the Carbon sizes (16/20/24/32) plus 64 (2x); pictograms render at
# native size and up only (their display sizes are 48px+, never 16).
ICON_SIZES = [16, 20, 24, 32, 64]
ASSETS = [
    ("add", ICONS / "32/add.svg", ICON_SIZES),
    ("apps_16", ICONS / "16/apps.svg", [16, 32]),
    ("apps_32", ICONS / "32/apps.svg", ICON_SIZES),
    ("arrow_down_16", ICONS / "16/arrow--down.svg", [16, 32]),
    ("arrow_down_32", ICONS / "32/arrow--down.svg", ICON_SIZES),
    ("misuse", ICONS / "32/misuse.svg", ICON_SIZES),
    ("logo_wechat", ICONS / "32/logo--wechat.svg", ICON_SIZES),
    ("airport_location", ICONS / "32/airport-location.svg", ICON_SIZES),
    ("wh_3d_cursor_alt", ICONS / "32/watson-health/3D-cursor--alt.svg", ICON_SIZES),
    ("q_bloch_sphere", ICONS / "32/Q/bloch-sphere.svg", ICON_SIZES),
    ("accessibility_alt", ICONS / "32/accessibility--alt.svg", ICON_SIZES),
    ("picto_solar_panel", PICTOS / "solar--panel.svg", [32, 64, 128]),
]

# Render sizes per artwork: native, 2x native; for 32px masters also 16
# (the downscale path CarbonIcon will take) and 64 covers 2x.
DROP_TAGS = {"style", "defs", "title", "desc", "switch", "foreignObject", "i"}
SHAPE_TAGS = {"path", "rect", "circle", "ellipse", "polygon", "polyline"}

CSS_RULE = re.compile(r"\.([\w-]+)\s*\{([^}]*)\}")
TRANSFORM_CALL = re.compile(r"(\w+)\s*\(([^)]*)\)")


def strip_ns(tag: str) -> str:
    return tag.split("}", 1)[1] if "}" in tag else tag


def parse_css(root: ET.Element) -> dict[str, dict[str, str]]:
    classes: dict[str, dict[str, str]] = {}
    for el in root.iter():
        if strip_ns(el.tag) == "style" and el.text:
            for m in CSS_RULE.finditer(el.text):
                props: dict[str, str] = {}
                for decl in m.group(2).split(";"):
                    if ":" in decl:
                        key, value = decl.split(":", 1)
                        props[key.strip()] = value.strip()
                classes.setdefault(m.group(1), {}).update(props)
    return classes


def style_of(el: ET.Element, classes: dict) -> dict[str, str]:
    style: dict[str, str] = {}
    for cls in (el.get("class") or "").split():
        style.update(classes.get(cls, {}))
    inline = el.get("style") or ""
    for decl in inline.split(";"):
        if ":" in decl:
            key, value = decl.split(":", 1)
            style[key.strip()] = value.strip()
    for attr in ("fill", "fill-rule", "opacity", "fill-opacity"):
        if el.get(attr) is not None:
            style[attr] = el.get(attr)
    return style


def invisible(style: dict[str, str]) -> bool:
    if style.get("fill") == "none":
        return True
    for key in ("opacity", "fill-opacity"):
        try:
            if float(style.get(key, "1")) == 0:
                return True
        except ValueError:
            pass
    return False


def mat_mul(a, b):
    return (
        a[0] * b[0] + a[2] * b[1],
        a[1] * b[0] + a[3] * b[1],
        a[0] * b[2] + a[2] * b[3],
        a[1] * b[2] + a[3] * b[3],
        a[0] * b[4] + a[2] * b[5] + a[4],
        a[1] * b[4] + a[3] * b[5] + a[5],
    )


IDENTITY = (1.0, 0.0, 0.0, 1.0, 0.0, 0.0)


def parse_transform(text: str | None):
    matrix = IDENTITY
    if not text:
        return matrix
    for call in TRANSFORM_CALL.finditer(text):
        name, args_text = call.group(1), call.group(2)
        args = [float(v) for v in re.split(r"[,\s]+", args_text.strip()) if v]
        if name == "translate":
            tx, ty = args[0], args[1] if len(args) > 1 else 0.0
            m = (1, 0, 0, 1, tx, ty)
        elif name == "rotate":
            angle = math.radians(args[0])
            cos, sin = math.cos(angle), math.sin(angle)
            m = (cos, sin, -sin, cos, 0, 0)
            if len(args) == 3:
                cx, cy = args[1], args[2]
                m = mat_mul(
                    mat_mul((1, 0, 0, 1, cx, cy), m), (1, 0, 0, 1, -cx, -cy)
                )
        elif name == "scale":
            sx = args[0]
            sy = args[1] if len(args) > 1 else sx
            m = (sx, 0, 0, sy, 0, 0)
        elif name == "matrix":
            m = tuple(args)
        else:
            raise ValueError(f"unsupported transform: {name}")
        matrix = mat_mul(matrix, m)
    return matrix


def fnum(value: float) -> str:
    return f"{value:.6g}"


def shape_to_path(el: ET.Element, tag: str) -> str:
    g = el.get
    if tag == "path":
        return g("d") or ""
    if tag == "rect":
        assert g("rx") is None and g("ry") is None, "rounded rect unsupported"
        x, y = float(g("x") or 0), float(g("y") or 0)
        w, h = float(g("width")), float(g("height"))
        return (
            f"M{fnum(x)},{fnum(y)} h{fnum(w)} v{fnum(h)} h{fnum(-w)} z"
        )
    if tag in ("circle", "ellipse"):
        cx, cy = float(g("cx") or 0), float(g("cy") or 0)
        rx = float(g("r") or g("rx"))
        ry = float(g("r") or g("ry"))
        return (
            f"M{fnum(cx - rx)},{fnum(cy)} "
            f"a{fnum(rx)},{fnum(ry)} 0 1 0 {fnum(2 * rx)},0 "
            f"a{fnum(rx)},{fnum(ry)} 0 1 0 {fnum(-2 * rx)},0 z"
        )
    if tag in ("polygon", "polyline"):
        nums = [v for v in re.split(r"[,\s]+", (g("points") or "").strip()) if v]
        pairs = [
            f"{nums[i]},{nums[i + 1]}" for i in range(0, len(nums), 2)
        ]
        close = " z" if tag == "polygon" else ""
        return "M" + " L".join(pairs) + close
    raise ValueError(f"unsupported shape: {tag}")


def extract(svg_file: Path):
    root = ET.parse(svg_file).getroot()
    view_box = root.get("viewBox")
    if view_box is None:
        width = re.sub(r"px$", "", root.get("width"))
        view_box = f"0 0 {width} {width}"
    vb = [float(v) for v in view_box.split()]
    assert vb[0] == 0 and vb[1] == 0 and vb[2] == vb[3], f"odd viewBox: {vb}"
    classes = parse_css(root)
    shapes = []

    def walk(el: ET.Element, transform):
        tag = strip_ns(el.tag)
        if tag in DROP_TAGS:
            return
        matrix = mat_mul(transform, parse_transform(el.get("transform")))
        if tag in SHAPE_TAGS:
            style = style_of(el, classes)
            if invisible(style):
                return
            rule = style.get("fill-rule", "nonzero")
            shapes.append((shape_to_path(el, tag), rule == "evenodd", matrix))
            return
        for child in el:
            walk(child, matrix)

    for child in root:
        walk(child, IDENTITY)
    assert shapes, f"no visible shapes in {svg_file}"
    return vb[2], shapes


def emit_dart(extracted) -> str:
    lines = [
        "// Copyright 2026 Bizjak Tech OÜ",
        "//",
        "// This file is part of Carbide and is licensed under the GNU Affero",
        "// General Public License v3.0 or later. See the LICENSE file in the",
        "// project root.",
        "//",
        "// GENERATED by tool/spike_icon_fidelity.py — do not edit by hand.",
        "// Shape data extracted from the Apache-2.0 licensed Carbon Design",
        "// System icon sources; see NOTICE.",
        "",
        "import 'support.dart';",
        "",
        "/// The representative icon sample for the rendering spike.",
        "const List<SpikeIcon> spikeIcons = <SpikeIcon>[",
    ]
    for name, viewbox, sizes, shapes in extracted:
        lines.append("  SpikeIcon(")
        lines.append(f"    name: '{name}',")
        lines.append(f"    viewBox: {fnum(viewbox)},")
        lines.append(f"    renderSizes: <int>[{', '.join(map(str, sizes))}],")
        lines.append("    shapes: <SpikeShape>[")
        for d, evenodd, matrix in shapes:
            lines.append("      SpikeShape(")
            lines.append(f"        d: '{d}',")
            if evenodd:
                lines.append("        evenOdd: true,")
            if matrix != IDENTITY:
                values = ", ".join(fnum(v) for v in matrix)
                lines.append(f"        matrix: <double>[{values}],")
            lines.append("      ),")
        lines.append("    ],")
        lines.append("  ),")
    lines.append("];")
    lines.append("")
    return "\n".join(lines)


def main() -> None:
    REF_DIR.mkdir(parents=True, exist_ok=True)
    extracted = []
    for name, svg_file, sizes in ASSETS:
        viewbox, shapes = extract(svg_file)
        extracted.append((name, viewbox, sizes, shapes))
        for size in sizes:
            out = REF_DIR / f"{name}_{size}.png"
            subprocess.run(
                [
                    "rsvg-convert",
                    "-w", str(size),
                    "-h", str(size),
                    str(svg_file),
                    "-o", str(out),
                ],
                check=True,
            )
        print(f"{name}: {len(shapes)} shapes, sizes {sizes}")
    FIXTURE.write_text(emit_dart(extracted))
    print(f"wrote {FIXTURE.relative_to(ROOT)} and {len(list(REF_DIR.iterdir()))} references")


if __name__ == "__main__":
    main()
