# Carbide

**An unofficial Flutter port of the IBM Carbon Design System.**

> ⚠️ **Heavy work in progress.** Carbide is in early foundation work; the public
> API is not yet usable. Track progress in the GitHub milestones and project
> board.

Carbide brings the [IBM Carbon Design System][carbon] to Flutter, built
**strictly on Flutter's base widgets** — no Material, no Cupertino. Every design
token, theme, and component is implemented from `package:flutter/widgets.dart`
so the result follows Carbon's specification rather than Material's.

## Principles

1. **Base widgets only.** No `package:flutter/material.dart` or
   `package:flutter/cupertino.dart` in `lib/`. Theming, state, and styling are
   built from scratch on the widgets layer.
2. **Token-driven.** Components consume design tokens (color, type, layout,
   motion) resolved per theme — White, Gray 10, Gray 90, Gray 100 — exactly as
   Carbon defines them.
3. **Tested to a high bar.** Nothing ships without tests. Each token group and
   component lands with state-matrix widget tests, golden tests against the
   Carbon spec, and semantics/accessibility tests.
4. **Strict Dart.** The analyzer is configured to fail on a large set of lints
   (see `analysis_options.yaml`). No shortcuts.

## Architecture

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the layered design
(foundations → theme → components) and the no-Material theming approach.

## Status & roadmap

Work is planned on GitHub as milestones M0–M8 (foundation, tokens, theme,
icons, then component tiers) with one issue per token group and component. See
the repository's Issues, Milestones, and Project board.

## Licensing

Carbide is **dual-licensed**:

- **[AGPL-3.0-or-later](LICENSE)** for open-source use.
- A **[commercial license](COMMERCIAL.md)** for proprietary use.

Design tokens are derived from the Apache-2.0 licensed Carbon Design System and
the project bundles the SIL OFL 1.1 licensed IBM Plex fonts; see [`NOTICE`](NOTICE)
for attribution.

## Trademark

Carbide is **not affiliated with, endorsed by, or sponsored by IBM**. "IBM",
"Carbon", and "IBM Plex" are trademarks of International Business Machines
Corporation, used here only to identify the upstream design system.

[carbon]: https://carbondesignsystem.com
