// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.
//
// Spike #29 support: SVG path parsing, dart:ui rendering, and pixel
// comparison against upstream reference rasters. The parser and renderer
// here are the prototypes for the real icon pipeline.

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

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

/// Parses an SVG path `d` string into a [ui.Path].
///
/// Supports the full command set used by the Carbon sources: M/L/H/V/C/S/Q/T/
/// A/Z in absolute and relative forms, implicit command repetition, and
/// compact arc flags.
ui.Path parseSvgPath(String d) {
  final _PathScanner s = _PathScanner(d);
  final ui.Path path = ui.Path();
  double x = 0, y = 0;
  double startX = 0, startY = 0;
  double cx = 0, cy = 0;
  String previous = '';

  while (true) {
    final String? command = s.nextCommand();
    if (command == null) {
      break;
    }
    switch (command) {
      case 'M':
      case 'm':
        final bool rel = command == 'm';
        double px = s.nextNumber(), py = s.nextNumber();
        if (rel) {
          px += x;
          py += y;
        }
        path.moveTo(px, py);
        x = startX = px;
        y = startY = py;
        while (s.hasNumber) {
          double lx = s.nextNumber(), ly = s.nextNumber();
          if (rel) {
            lx += x;
            ly += y;
          }
          path.lineTo(lx, ly);
          x = lx;
          y = ly;
        }
      case 'L':
      case 'l':
        do {
          double lx = s.nextNumber(), ly = s.nextNumber();
          if (command == 'l') {
            lx += x;
            ly += y;
          }
          path.lineTo(lx, ly);
          x = lx;
          y = ly;
        } while (s.hasNumber);
      case 'H':
      case 'h':
        do {
          double lx = s.nextNumber();
          if (command == 'h') {
            lx += x;
          }
          path.lineTo(lx, y);
          x = lx;
        } while (s.hasNumber);
      case 'V':
      case 'v':
        do {
          double ly = s.nextNumber();
          if (command == 'v') {
            ly += y;
          }
          path.lineTo(x, ly);
          y = ly;
        } while (s.hasNumber);
      case 'C':
      case 'c':
        do {
          double x1 = s.nextNumber(), y1 = s.nextNumber();
          double x2 = s.nextNumber(), y2 = s.nextNumber();
          double ex = s.nextNumber(), ey = s.nextNumber();
          if (command == 'c') {
            x1 += x;
            y1 += y;
            x2 += x;
            y2 += y;
            ex += x;
            ey += y;
          }
          path.cubicTo(x1, y1, x2, y2, ex, ey);
          cx = x2;
          cy = y2;
          x = ex;
          y = ey;
        } while (s.hasNumber);
      case 'S':
      case 's':
        do {
          double x2 = s.nextNumber(), y2 = s.nextNumber();
          double ex = s.nextNumber(), ey = s.nextNumber();
          if (command == 's') {
            x2 += x;
            y2 += y;
            ex += x;
            ey += y;
          }
          final bool reflect = 'CcSs'.contains(previous);
          final double x1 = reflect ? 2 * x - cx : x;
          final double y1 = reflect ? 2 * y - cy : y;
          path.cubicTo(x1, y1, x2, y2, ex, ey);
          cx = x2;
          cy = y2;
          x = ex;
          y = ey;
          previous = command;
        } while (s.hasNumber);
      case 'Q':
      case 'q':
        do {
          double x1 = s.nextNumber(), y1 = s.nextNumber();
          double ex = s.nextNumber(), ey = s.nextNumber();
          if (command == 'q') {
            x1 += x;
            y1 += y;
            ex += x;
            ey += y;
          }
          path.quadraticBezierTo(x1, y1, ex, ey);
          cx = x1;
          cy = y1;
          x = ex;
          y = ey;
        } while (s.hasNumber);
      case 'T':
      case 't':
        do {
          double ex = s.nextNumber(), ey = s.nextNumber();
          if (command == 't') {
            ex += x;
            ey += y;
          }
          final bool reflect = 'QqTt'.contains(previous);
          final double x1 = reflect ? 2 * x - cx : x;
          final double y1 = reflect ? 2 * y - cy : y;
          path.quadraticBezierTo(x1, y1, ex, ey);
          cx = x1;
          cy = y1;
          x = ex;
          y = ey;
          previous = command;
        } while (s.hasNumber);
      case 'A':
      case 'a':
        do {
          final double rx = s.nextNumber(), ry = s.nextNumber();
          final double rotation = s.nextNumber();
          final bool largeArc = s.nextFlag(), sweep = s.nextFlag();
          double ex = s.nextNumber(), ey = s.nextNumber();
          if (command == 'a') {
            ex += x;
            ey += y;
          }
          path.arcToPoint(
            ui.Offset(ex, ey),
            radius: ui.Radius.elliptical(rx, ry),
            rotation: rotation,
            largeArc: largeArc,
            clockwise: sweep,
          );
          x = ex;
          y = ey;
        } while (s.hasNumber);
      case 'Z':
      case 'z':
        path.close();
        x = startX;
        y = startY;
      default:
        throw FormatException('unsupported path command: $command in $d');
    }
    previous = command;
  }
  return path;
}

class _PathScanner {
  _PathScanner(this.source);

  final String source;
  int _i = 0;

  static bool _isCommand(int c) =>
      (c >= 0x41 && c <= 0x5A || c >= 0x61 && c <= 0x7A) &&
      c != 0x65 &&
      c != 0x45;

  void _skip() {
    while (_i < source.length) {
      final int c = source.codeUnitAt(_i);
      if (c == 0x20 || c == 0x2C || c == 0x09 || c == 0x0A || c == 0x0D) {
        _i++;
      } else {
        break;
      }
    }
  }

  String? nextCommand() {
    _skip();
    if (_i >= source.length) {
      return null;
    }
    final int c = source.codeUnitAt(_i);
    if (_isCommand(c)) {
      _i++;
      return String.fromCharCode(c);
    }
    throw FormatException('expected command at $_i in: $source');
  }

  bool get hasNumber {
    _skip();
    if (_i >= source.length) {
      return false;
    }
    final int c = source.codeUnitAt(_i);
    return c == 0x2D || c == 0x2B || c == 0x2E || (c >= 0x30 && c <= 0x39);
  }

  double nextNumber() {
    _skip();
    final int start = _i;
    if (_i < source.length &&
        (source.codeUnitAt(_i) == 0x2D || source.codeUnitAt(_i) == 0x2B)) {
      _i++;
    }
    bool dot = false;
    while (_i < source.length) {
      final int c = source.codeUnitAt(_i);
      if (c >= 0x30 && c <= 0x39) {
        _i++;
      } else if (c == 0x2E && !dot) {
        dot = true;
        _i++;
      } else if (c == 0x65 || c == 0x45) {
        _i++;
        if (_i < source.length &&
            (source.codeUnitAt(_i) == 0x2D || source.codeUnitAt(_i) == 0x2B)) {
          _i++;
        }
      } else {
        break;
      }
    }
    return double.parse(source.substring(start, _i));
  }

  bool nextFlag() {
    _skip();
    final int c = source.codeUnitAt(_i);
    _i++;
    return switch (c) {
      0x30 => false,
      0x31 => true,
      _ => throw FormatException('expected arc flag at ${_i - 1}: $source'),
    };
  }
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
