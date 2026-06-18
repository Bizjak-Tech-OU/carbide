# Upstream fidelity pipeline (W3)

Compares Carbide components against **real IBM Carbon** rendering, so divergence
from the source design system is caught — not just divergence from our own past
output (which the golden tests lock in) or from the SCSS spec (which the
spec-lock tests assert).

It has two phases:

## 1. Capture references (manual, needs network)

`capture_references.mjs` drives Playwright over the published Carbon React
Storybook and screenshots each story in [`stories.json`](stories.json), once per
theme (`white` / `g10` / `g90` / `g100`), into
`test/fidelity/references/<component>/<theme>.png`. A `manifest.json` records the
source URL, capture time, and per-story result.

```sh
# Local Playwright (simplest):
tool/fidelity/capture.sh

# Or fully hermetic, version-matched Docker image:
docker run --rm -v "$PWD":/work -w /work/tool/fidelity \
  -e HOME=/work/tool/fidelity -e OUT=/work/test/fidelity/references \
  --user "$(id -u):$(id -g)" \
  mcr.microsoft.com/playwright:v1.61.0-jammy \
  sh -c "npm ci || npm install; node capture_references.mjs"
```

The captured PNGs **are committed** — they are the ground truth the offline test
compares against. Re-run capture (and commit the diff) when you bump the
`documentation/carbon` submodule or add stories.

## 2. Compare (offline, runs in CI)

[`test/fidelity/fidelity_test.dart`](../../test/fidelity/fidelity_test.dart)
renders the Carbide equivalent of each captured story (a builder keyed by the
same `component` slug) and writes a side-by-side
`Carbon | Carbide` image to `test/fidelity/comparisons/<component>_<theme>.png`.
CI uploads those as an artifact on every PR.

**This is not a strict pixel gate.** Carbon renders in Chromium and Carbide in
Flutter, so exact pixels can never match. The only hard assertion is that the
Carbide render is non-blank/non-flat (a reliable cross-renderer sanity check); a
coarse, framing-tolerant difference score is shown on each comparison for
context, and a human reviews the side-by-side.

## Extending coverage

1. Add `{ "component": "<slug>", "storyId": "<storybook-id>" }` to `stories.json`
   (find ids in `https://react.carbondesignsystem.com/index.json`).
2. Re-run `capture.sh` and commit the new references.
3. Add a matching `'<slug>': () => <Carbide widget>` to `_builders` in
   `fidelity_test.dart`.
