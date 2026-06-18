#!/usr/bin/env bash
# Regenerate the upstream Carbon Storybook fidelity references (epic W3).
#
# Screenshots every story in stories.json per theme into
# test/fidelity/references/ using Playwright (pinned in package.json). Needs
# Node and network access to the published Storybook. Re-run when bumping the
# Carbon submodule or adding stories, then commit the updated references +
# manifest. The committed references are what the offline fidelity test compares
# against in CI — capture never runs in CI.
#
# For a fully hermetic run you can instead use the version-matched Playwright
# Docker image (see README.md), but local Playwright is the simplest path.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$DIR/../.." && pwd)"

echo "Installing pinned Playwright + Chromium…"
(cd "$DIR" && npm install --no-audit --no-fund && npx playwright install chromium)

echo "Capturing Carbon references…"
cd "$REPO"
node tool/fidelity/capture_references.mjs
