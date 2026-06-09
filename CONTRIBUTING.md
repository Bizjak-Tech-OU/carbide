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

For golden tests, generate with `flutter test --update-goldens` only on the
pinned CI platform/image to keep them deterministic, and review the images.

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
