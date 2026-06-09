// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.
//
// Proves the golden pipeline end to end. It deliberately renders only solid
// rectangles (no text, no anti-aliased edges) so the baseline is pixel-stable
// across the development machine and CI. Component goldens that include text
// should be regenerated on the CI platform.

import 'package:carbide/carbide.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/golden.dart';

void main() {
  testWidgets('color ramps render on each theme background', (
    WidgetTester tester,
  ) async {
    await expectThemeGoldens(
      tester,
      name: 'color_swatch',
      size: const Size(416, 104),
      builder: (BuildContext context) => const _SwatchRamps(),
    );
  });
}

class _SwatchRamps extends StatelessWidget {
  const _SwatchRamps();

  static const List<Color> _blue = <Color>[
    CarbonColors.blue10,
    CarbonColors.blue20,
    CarbonColors.blue30,
    CarbonColors.blue40,
    CarbonColors.blue50,
    CarbonColors.blue60,
    CarbonColors.blue70,
    CarbonColors.blue80,
    CarbonColors.blue90,
    CarbonColors.blue100,
  ];

  static const List<Color> _green = <Color>[
    CarbonColors.green10,
    CarbonColors.green20,
    CarbonColors.green30,
    CarbonColors.green40,
    CarbonColors.green50,
    CarbonColors.green60,
    CarbonColors.green70,
    CarbonColors.green80,
    CarbonColors.green90,
    CarbonColors.green100,
  ];

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Ramp(colors: _blue),
          SizedBox(height: 8),
          _Ramp(colors: _green),
        ],
      ),
    );
  }
}

class _Ramp extends StatelessWidget {
  const _Ramp({required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final Color color in colors)
          SizedBox(width: 40, height: 40, child: ColoredBox(color: color)),
      ],
    );
  }
}
