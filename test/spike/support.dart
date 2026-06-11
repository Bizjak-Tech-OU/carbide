// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.
//
// Spike #29 support: dart:ui rendering and pixel comparison against
// upstream reference rasters. The renderer and comparator here are the
// prototypes for the #32 fidelity sweep; the path parser graduated to
// lib/src/icons/svg_path_parser.dart.

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:carbide/src/icons/svg_path_parser.dart';

/// One extracted icon: shape data plus the sizes to verify at.
class SpikeIcon {
  const SpikeIcon({
    required this.name,
    required this.viewBox,
    required this.renderSizes,
    required this.shapes,
  });

  final String name;
  final double viewBox;
  final List<int> renderSizes;
  final List<SpikeShape> shapes;
}

/// One visible shape: an SVG path, its fill rule, and an optional 2D matrix.
class SpikeShape {
  const SpikeShape({required this.d, this.evenOdd = false, this.matrix});

  final String d;
  final bool evenOdd;

  /// SVG-style 2D affine matrix `[a, b, c, d, e, f]`, if not identity.
  final List<double>? matrix;
}

/// Renders [icon] at [size]×[size] and returns its alpha channel.
Future<Uint8List> renderIconAlpha(SpikeIcon icon, int size) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);
  final double scale = size / icon.viewBox;
  canvas.scale(scale, scale);
  final ui.Paint paint = ui.Paint()..color = const ui.Color(0xFF000000);
  for (final SpikeShape shape in icon.shapes) {
    ui.Path path = parseSvgPath(shape.d);
    final List<double>? m = shape.matrix;
    if (m != null) {
      path = path.transform(
        Float64List.fromList(<double>[
          m[0],
          m[1],
          0,
          0,
          m[2],
          m[3],
          0,
          0,
          0,
          0,
          1,
          0,
          m[4],
          m[5],
          0,
          1,
        ]),
      );
    }
    path.fillType = shape.evenOdd
        ? ui.PathFillType.evenOdd
        : ui.PathFillType.nonZero;
    canvas.drawPath(path, paint);
  }
  final ui.Image image = await recorder.endRecording().toImage(size, size);
  return _alphaChannel(image);
}

/// Decodes a reference PNG and returns its alpha channel.
Future<Uint8List> decodeReferenceAlpha(Uint8List png, int size) async {
  final ui.Codec codec = await ui.instantiateImageCodec(png);
  final ui.Image image = (await codec.getNextFrame()).image;
  if (image.width != size || image.height != size) {
    throw StateError('reference is ${image.width}x${image.height}, want $size');
  }
  return _alphaChannel(image);
}

Future<Uint8List> _alphaChannel(ui.Image image) async {
  final ByteData data = (await image.toByteData())!;
  final Uint8List rgba = data.buffer.asUint8List();
  final Uint8List alpha = Uint8List(rgba.length ~/ 4);
  for (int i = 0; i < alpha.length; i++) {
    alpha[i] = rgba[i * 4 + 3];
  }
  return alpha;
}

/// The result of comparing a render against its upstream reference.
class FidelityResult {
  const FidelityResult({
    required this.mismatchFraction,
    required this.coverageMismatchFraction,
    required this.meanAbsDiff,
  });

  /// Fraction of pixels whose raw alpha differs by more than the band.
  ///
  /// Sensitive to anti-aliasing differences between renderers along curved
  /// edges (Skia draws arcs as conics; rsvg approximates with béziers), so
  /// it overstates visual difference on arc-heavy icons.
  final double mismatchFraction;

  /// Fraction of pixels differing after a 3×3 box blur of both images.
  ///
  /// Blurring forgives sub-pixel edge-sampling differences while still
  /// catching real geometry errors: a shape displaced by a full pixel or a
  /// missing/extra shape survives the blur. This is the fidelity gate.
  final double coverageMismatchFraction;

  /// Mean absolute alpha difference, normalized to 0–1.
  final double meanAbsDiff;
}

Uint8List _boxBlur(Uint8List src, int size) {
  final Uint8List out = Uint8List(src.length);
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      int sum = 0, n = 0;
      for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
          final int nx = x + dx, ny = y + dy;
          if (nx >= 0 && nx < size && ny >= 0 && ny < size) {
            sum += src[ny * size + nx];
            n++;
          }
        }
      }
      out[y * size + x] = sum ~/ n;
    }
  }
  return out;
}

/// Compares two alpha channels with a per-pixel band of [band] (0–255).
FidelityResult compareAlpha(
  Uint8List ours,
  Uint8List reference, {
  int band = 32,
}) {
  assert(ours.length == reference.length);
  final int size = _isqrt(ours.length);
  int mismatches = 0;
  int totalDiff = 0;
  for (int i = 0; i < ours.length; i++) {
    final int diff = (ours[i] - reference[i]).abs();
    totalDiff += diff;
    if (diff > band) {
      mismatches++;
    }
  }
  final Uint8List blurredOurs = _boxBlur(ours, size);
  final Uint8List blurredRef = _boxBlur(reference, size);
  int coverageMismatches = 0;
  for (int i = 0; i < blurredOurs.length; i++) {
    if ((blurredOurs[i] - blurredRef[i]).abs() > band) {
      coverageMismatches++;
    }
  }
  return FidelityResult(
    mismatchFraction: mismatches / ours.length,
    coverageMismatchFraction: coverageMismatches / ours.length,
    meanAbsDiff: totalDiff / ours.length / 255,
  );
}

int _isqrt(int value) {
  final int root = math.sqrt(value).round();
  assert(root * root == value, 'images must be square');
  return root;
}
