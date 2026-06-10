// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.

import 'package:carbide/carbide.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The four Carbon themes, used to snapshot a widget on each one.
///
/// Each variant exposes its full [theme] token set, so goldens render against
/// the real semantic tokens. [background] is a convenience for the host
/// backdrop.
enum CarbonThemeVariant {
  /// The White theme.
  white('white'),

  /// The Gray 10 theme.
  gray10('g10'),

  /// The Gray 90 theme.
  gray90('g90'),

  /// The Gray 100 theme.
  gray100('g100');

  const CarbonThemeVariant(this.label);

  /// Short, file-safe identifier used in golden file names.
  final String label;

  /// The full semantic token set for this theme.
  CarbonThemeData get theme => switch (this) {
    CarbonThemeVariant.white => CarbonThemeData.white,
    CarbonThemeVariant.gray10 => CarbonThemeData.gray10,
    CarbonThemeVariant.gray90 => CarbonThemeData.gray90,
    CarbonThemeVariant.gray100 => CarbonThemeData.gray100,
  };

  /// The theme's base background color, used as the golden backdrop.
  Color get background => theme.background;
}

/// Pumps [child] in a deterministic host and snapshots it on every
/// [CarbonThemeVariant] background.
///
/// Produces one golden per theme at `goldens/<name>.<variant>.png`. The host
/// fixes text scaling, surface size, and direction so output depends only on
/// the widget under test. Builds with [builder] so the widget can read its
/// `BuildContext` (and, later, theme tokens).
Future<void> expectThemeGoldens(
  WidgetTester tester, {
  required String name,
  required Size size,
  required WidgetBuilder builder,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  for (final CarbonThemeVariant variant in CarbonThemeVariant.values) {
    final Key key = ValueKey<String>('carbide-golden-${variant.label}');
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: key,
          child: MediaQuery(
            data: const MediaQueryData(),
            child: CarbonTheme(
              data: variant.theme,
              child: SizedBox.fromSize(
                size: size,
                child: ColoredBox(
                  color: variant.background,
                  child: Builder(builder: builder),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await expectLater(
      find.byKey(key),
      matchesGoldenFile('goldens/$name.${variant.label}.png'),
    );
  }
}
