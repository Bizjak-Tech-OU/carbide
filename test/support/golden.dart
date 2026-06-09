// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.

import 'package:carbide/carbide.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The four Carbon themes, used to snapshot a widget on each theme background.
///
/// The [background] is each theme's base background token (`$background`),
/// which is a fixed Carbon value independent of the rest of the semantic token
/// set. Once the full theme tokens land, the golden host will additionally
/// provide them to descendants; the variant set stays the same.
enum CarbonThemeVariant {
  /// The White theme.
  white('white', CarbonColors.white),

  /// The Gray 10 theme.
  gray10('g10', CarbonColors.gray10),

  /// The Gray 90 theme.
  gray90('g90', CarbonColors.gray90),

  /// The Gray 100 theme.
  gray100('g100', CarbonColors.gray100);

  const CarbonThemeVariant(this.label, this.background);

  /// Short, file-safe identifier used in golden file names.
  final String label;

  /// The theme's base background color.
  final Color background;
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
    );
    await tester.pump();
    await expectLater(
      find.byKey(key),
      matchesGoldenFile('goldens/$name.${variant.label}.png'),
    );
  }
}
