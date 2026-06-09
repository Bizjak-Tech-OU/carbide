// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.

import 'package:carbide/carbide.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bundled IBM Plex font assets, grouped by family.
///
/// Mirrors the `fonts:` declaration in `pubspec.yaml`. Kept here so tests and
/// the golden harness register exactly the fonts the package ships.
const Map<String, List<String>> carbidePlexFontAssets = <String, List<String>>{
  CarbonFontFamily.sans: <String>[
    'fonts/IBMPlexSans-Light.ttf',
    'fonts/IBMPlexSans-Regular.ttf',
    'fonts/IBMPlexSans-SemiBold.ttf',
  ],
  CarbonFontFamily.mono: <String>[
    'fonts/IBMPlexMono-Regular.ttf',
    'fonts/IBMPlexMono-SemiBold.ttf',
  ],
};

/// Loads the bundled IBM Plex fonts into the test font registry.
///
/// Widget tests render with a placeholder font unless real fonts are loaded.
/// Call this (typically in `setUpAll`) before any golden or layout assertion
/// that depends on Plex metrics. Requires an initialized test binding, which
/// `testWidgets` and `flutter_test`'s default `main` provide.
Future<void> loadCarbidePlexFonts() async {
  for (final MapEntry<String, List<String>> family
      in carbidePlexFontAssets.entries) {
    final FontLoader loader = FontLoader(family.key);
    for (final String asset in family.value) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}
