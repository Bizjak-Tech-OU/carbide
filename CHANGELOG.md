# Changelog

## 0.0.2

Maintenance release — no API or component changes.

- Refresh the gallery screenshots in the README, regenerated from the current
  build (the previous images were from an earlier, broken render).
- Packaging & tooling: trim the published archive with `.pubignore` and scope
  the `.gitignore` lock/editor rules so they no longer reach into the
  `documentation/` submodules, giving a clean `dart pub publish` run.
- Automated pub.dev publishing on `vX.Y.Z` tags via OIDC trusted publishing.

## 0.0.1

Initial public release of **Carbide** — an unofficial Flutter port of the IBM
Carbon Design System, built strictly on Flutter's base widgets (no Material, no
Cupertino).

### Foundations

- Color tokens and the four Carbon themes (White, Gray 10, Gray 90, Gray 100),
  with `CarbonTheme`, `AnimatedCarbonTheme`, and the `CarbonLayer` contextual
  layering model.
- Typography (bundled IBM Plex Sans, Mono, and Serif), spacing/layout tokens,
  motion tokens, and the Carbon icon and pictogram sets.

### Components

- **Foundational:** Button, Tag, Link, Tile, Loading, Progress bar, List,
  Stack, Heading.
- **Forms:** Text input, Text area, Number input, Select, Search, Checkbox,
  Radio button, Toggle, Slider.
- **Composite:** Dropdown, Combo box, Multi-select, Tooltip, Toggletip,
  Overflow menu, Tabs, Accordion, Content switcher, Breadcrumb, Pagination,
  Modal, Notification, Progress indicator, Structured list.
- **Complex & data:** Data table, Date picker, Time picker, File uploader,
  Tree view, Page header, and the UI Shell (header, side nav, switcher).

Every component ships with state-matrix widget tests, golden tests against the
Carbon spec, and semantics/accessibility tests, and is documented on its public
API.

Supports Android, iOS, web, Windows, macOS, and Linux.
