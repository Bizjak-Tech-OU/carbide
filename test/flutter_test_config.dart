// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.
//
// Loaded automatically by `flutter_test` for every test in this package. It
// registers the bundled IBM Plex fonts (so text renders with real glyphs
// instead of the placeholder font) and installs a golden comparator with a
// small tolerance to absorb sub-pixel anti-aliasing differences between the
// development machine and CI.

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/load_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadCarbidePlexFonts();

  final GoldenFileComparator comparator = goldenFileComparator;
  if (comparator is LocalFileComparator) {
    goldenFileComparator = _CarbideGoldenComparator(comparator.basedir);
  }

  await testMain();
}

/// A [LocalFileComparator] that accepts a tiny fraction of differing pixels.
///
/// Golden baselines are compared across platforms. Vector geometry renders
/// bit-identically everywhere (validated empirically by the icon spike), but
/// **glyph rasterization does not**: macOS (CoreText) and Linux (FreeType)
/// produce ~8–9% differing pixels on the same text. So:
///
/// - Goldens whose name contains `.text.` are generated **on Linux** (CI is
///   authoritative; use the “Regenerate goldens” workflow) and compared
///   strictly there; on other platforms they get a lenient bound that still
///   catches gross errors (missing text, wrong layout) without false
///   failures from rasterizer differences.
/// - All other goldens use a small tolerance everywhere.
class _CarbideGoldenComparator extends LocalFileComparator {
  _CarbideGoldenComparator(Uri baseDir)
    : super(Uri.parse('$baseDir$_dummyTestFile'));

  // LocalFileComparator derives its base directory from the directory of the
  // file it is given; the file itself never needs to exist.
  static const String _dummyTestFile = 'carbide_goldens.dart';

  // Fractions (0..1) of pixels allowed to differ. `diffPercent` is reported
  // as a fraction by the framework, so 0.005 is 0.5%.
  static const double _maxDiffFraction = 0.005;
  static const double _maxTextDiffFractionOffCi = 0.15;

  static double _toleranceFor(Uri golden) {
    if (golden.path.contains('.text.') && !Platform.isLinux) {
      return _maxTextDiffFractionOffCi;
    }
    return _maxDiffFraction;
  }

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= _toleranceFor(golden)) {
      return true;
    }
    final String error = await generateFailureOutput(result, golden, basedir);
    throw FlutterError(error);
  }
}
