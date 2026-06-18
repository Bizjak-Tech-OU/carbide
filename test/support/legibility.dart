// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.
//
// Assertions that a widget is not just *present* but actually *rendered
// legibly*. `find.text('2')` passing only proves the widget exists in the
// tree; a fixed-height or over-padded ancestor can still squeeze the glyphs
// into an unreadable sliver (and a self-referential golden will happily lock
// that in). These helpers close that gap.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Asserts the [Text] found by [finder] is not vertically clipped: its
/// laid-out height is at least the line height implied by its style.
///
/// A squished badge (e.g. a 24px pill padded to an 8px content box) clamps the
/// glyph box below its line height; this catches that without needing a human
/// to eyeball a low-resolution golden.
void expectTextNotClipped(
  WidgetTester tester,
  Finder finder, {
  double slack = 0.5,
}) {
  final Text text = tester.widget<Text>(finder);
  final Size rendered = tester.getSize(finder);
  final TextStyle? style = text.style;
  final double fontSize = style?.fontSize ?? 14;
  final double lineHeight = fontSize * (style?.height ?? 1.0);
  expect(
    rendered.height,
    greaterThanOrEqualTo(lineHeight - slack),
    reason:
        'Text "${text.data}" is clipped: the glyph box rendered '
        '${rendered.height.toStringAsFixed(2)}px tall but its line box needs '
        '${lineHeight.toStringAsFixed(2)}px. A parent is constraining it below '
        'its line height.',
  );
}

/// Asserts the widget found by [finder] fits inside the widget found by
/// [within] — i.e. it is not overflowing (and therefore being clipped or
/// painting outside) its container.
void expectFitsWithin(
  WidgetTester tester,
  Finder finder, {
  required Finder within,
  double slack = 0.5,
}) {
  final Rect inner = tester.getRect(finder);
  final Rect outer = tester.getRect(within);
  expect(
    inner.height,
    lessThanOrEqualTo(outer.height + slack),
    reason:
        'Widget overflows its container vertically '
        '(${inner.height.toStringAsFixed(2)} > ${outer.height.toStringAsFixed(2)}).',
  );
  expect(
    inner.width,
    lessThanOrEqualTo(outer.width + slack),
    reason:
        'Widget overflows its container horizontally '
        '(${inner.width.toStringAsFixed(2)} > ${outer.width.toStringAsFixed(2)}).',
  );
}
