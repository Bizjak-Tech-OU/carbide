# Contributing to Carbide

Thanks for your interest. Carbide aims for a faithful, well-tested Carbon port,
so contributions are held to a deliberately high bar.

## Contributor License Agreement (CLA)

Carbide is dual-licensed (AGPL-3.0-or-later and commercial; see COMMERCIAL.md).
So that the project can keep offering a commercial license, **all contributions
are accepted under a CLA** granting Bizjak Tech OÜ the right to relicense
contributed code. By opening a pull request you agree your contribution is
provided under those terms. For substantial contributions we may ask you to sign
the CLA explicitly.

## Ground rules

- **Base widgets only.** Do not import `package:flutter/material.dart` or
  `package:flutter/cupertino.dart` in `lib/`. Build from
  `package:flutter/widgets.dart`.
- **Fidelity to Carbon.** Port values and behaviour from the upstream sources in
  `documentation/` (tokens from `documentation/carbon/packages`, design guidance
  from `documentation/carbon-website`). Cite the source in the PR.
- **Tests are not optional.** See the definition of done below.
- **Strict analyzer.** `dart analyze` must report zero issues. Format with
  `dart format`.

## Workflow

1. Pick or open an issue; one component / token group per branch.
2. Branch from `master` (e.g. `feat/button`, `tokens/motion`).
3. Implement, document public APIs with `///`, and add tests.
4. Run the checks below locally.
5. Open a PR linked to the issue. CI must be green.

## Local checks

```sh
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

### Golden tests

The bundled IBM Plex fonts are loaded automatically for every test by
`test/flutter_test_config.dart`, so golden output uses real glyphs. Snapshot a
widget on all four themes at once with `expectThemeGoldens` from
`test/support/golden.dart`; baselines are written next to the test under
`goldens/<name>.<variant>.png`.

Generate or update baselines with `flutter test --update-goldens` and review the
images. A small tolerance (0.5%) absorbs sub-pixel anti-aliasing differences
between machines. Vector geometry renders identically across platforms, but
**glyph rasterization does not** (macOS CoreText vs Linux FreeType differ by
~8–9% of pixels on the same text), so text goldens are **Linux-authoritative**:

- Pass `containsText: true` to `expectThemeGoldens` for any snapshot that
  renders glyphs. The golden is named `<name>.text.<variant>.png`; the
  comparator checks it strictly (0.5%) on Linux and leniently (15%) elsewhere,
  so local macOS runs still catch gross errors without false failures.
- Generate text goldens with the **“Regenerate goldens” workflow**
  (`gh workflow run regenerate-goldens.yml --ref <branch>`), which runs
  `--update-goldens` on Linux and commits the result back to the branch. The
  bot commit does not retrigger CI; pull and push (or open the PR) afterwards.

### Icon fidelity sweep

Every icon asset is verified on every PR against committed rasterizations of
the **upstream SVGs** (`test/icons/references/`, produced by `rsvg-convert` at
2× scale — external ground truth, not our own renderer). The sweep
(`test/icons/icon_fidelity_sweep_test.dart`) renders each asset through the
production parser/painter and gates on **blurred-coverage mismatch ≤ 0.5%**
(ADR 0001). On failure, our renders are written to `test/icons/failures/` for
side-by-side comparison with the reference; fix the data (or regenerate after
a deliberate upstream bump) rather than loosening the gate.

When bumping the Carbon submodule, follow [docs/ICON_UPDATES.md](docs/ICON_UPDATES.md):
regenerate data + references, review the lockfile diff report, and commit it
all together — CI's drift guard rejects a bump without regeneration.

## Definition of done

A token group or component is done only when it has:

- All variants, sizes, and interaction states Carbon specifies.
- Correct rendering under all four themes (White, Gray 10, Gray 90, Gray 100).
- Accessibility: `Semantics`, focus traversal, keyboard handling.
- **State-matrix widget tests**, **golden tests**, and **semantics tests**.
- `///` documentation on public APIs with at least one example.
- Public symbols exported from `lib/carbide.dart`.

## Commit messages

Use clear, imperative messages (Conventional Commits encouraged:
`feat(button): …`, `tokens(motion): …`, `test: …`, `docs: …`).
