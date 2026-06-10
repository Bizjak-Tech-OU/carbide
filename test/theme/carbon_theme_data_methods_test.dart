// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.

import 'dart:ui';

import 'package:carbide/carbide.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('copyWith', () {
    test('replaces only the named tokens', () {
      final CarbonThemeData themed = CarbonThemeData.white.copyWith(
        background: CarbonColors.blue60,
      );
      expect(themed.background, CarbonColors.blue60);
      expect(themed.textPrimary, CarbonThemeData.white.textPrimary);
      expect(themed.brightness, CarbonThemeData.white.brightness);
    });

    test('is equal to the original when given no arguments', () {
      expect(CarbonThemeData.white.copyWith(), CarbonThemeData.white);
    });
  });

  group('lerp', () {
    test('returns the endpoints at t = 0 and t = 1', () {
      expect(
        CarbonThemeData.lerp(CarbonThemeData.white, CarbonThemeData.gray100, 0),
        CarbonThemeData.white,
      );
      expect(
        CarbonThemeData.lerp(CarbonThemeData.white, CarbonThemeData.gray100, 1),
        CarbonThemeData.gray100,
      );
    });

    test('interpolates tokens at the midpoint', () {
      final CarbonThemeData mid = CarbonThemeData.lerp(
        CarbonThemeData.white,
        CarbonThemeData.gray100,
        0.5,
      );
      expect(
        mid.background,
        Color.lerp(
          CarbonThemeData.white.background,
          CarbonThemeData.gray100.background,
          0.5,
        ),
      );
    });

    test('brightness snaps to b from the midpoint', () {
      CarbonThemeData at(double t) => CarbonThemeData.lerp(
        CarbonThemeData.white,
        CarbonThemeData.gray100,
        t,
      );
      expect(at(0.4).brightness, Brightness.light);
      expect(at(0.5).brightness, Brightness.dark);
      expect(at(0.6).brightness, Brightness.dark);
    });
  });

  group('equality', () {
    test('a theme equals itself and a field-identical copy', () {
      expect(CarbonThemeData.white, CarbonThemeData.white);
      expect(CarbonThemeData.white.copyWith(), equals(CarbonThemeData.white));
      expect(
        CarbonThemeData.white.hashCode,
        CarbonThemeData.white.copyWith().hashCode,
      );
    });

    test('themes differing by one token are not equal', () {
      final CarbonThemeData changed = CarbonThemeData.white.copyWith(
        focus: CarbonColors.blue40,
      );
      expect(changed, isNot(CarbonThemeData.white));
      expect(CarbonThemeData.white, isNot(CarbonThemeData.gray100));
    });
  });
}
