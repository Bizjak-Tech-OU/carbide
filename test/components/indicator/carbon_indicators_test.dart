// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.

import 'package:carbide/carbide.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden.dart';

Widget _host(Widget child, {CarbonThemeData? theme}) => Directionality(
  textDirection: TextDirection.ltr,
  child: CarbonTheme(
    data: theme ?? CarbonThemeData.white,
    child: Align(alignment: Alignment.topLeft, child: child),
  ),
);

void main() {
  group('badge indicator', () {
    testWidgets('renders a dot when no count is given', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const CarbonBadgeIndicator()));
      final Container dot = tester.widget<Container>(
        find.descendant(
          of: find.byType(CarbonBadgeIndicator),
          matching: find.byType(Container),
        ),
      );
      final BoxDecoration decoration = dot.decoration! as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, CarbonThemeData.white.supportError);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('shows a count and caps it at 999+', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const CarbonBadgeIndicator(count: 5)));
      expect(find.text('5'), findsOneWidget);

      await tester.pumpWidget(_host(const CarbonBadgeIndicator(count: 4000)));
      expect(find.text('999+'), findsOneWidget);
    });
  });

  group('icon indicator', () {
    testWidgets('renders the kind icon, colour, and label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const CarbonIconIndicator(
            kind: CarbonIconIndicatorKind.failed,
            label: 'Failed',
          ),
        ),
      );
      final CarbonIcon icon = tester.widget<CarbonIcon>(
        find.byType(CarbonIcon),
      );
      expect(icon.icon, CarbonIcons.errorFilled);
      expect(icon.color, CarbonColors.red60); // light theme: status-red = red60
      expect(icon.size, 16);
      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('status colour steps down on dark themes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const CarbonIconIndicator(
            kind: CarbonIconIndicatorKind.succeeded,
            label: 'Succeeded',
          ),
          theme: CarbonThemeData.gray100,
        ),
      );
      final CarbonIcon icon = tester.widget<CarbonIcon>(
        find.byType(CarbonIcon),
      );
      // status-green is green50 on light, green40 on dark.
      expect(icon.color, CarbonColors.green40);
    });

    testWidgets('the 20px size uses body-compact-02', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const CarbonIconIndicator(
            kind: CarbonIconIndicatorKind.normal,
            label: 'Normal',
            size: 20,
          ),
        ),
      );
      expect(tester.widget<CarbonIcon>(find.byType(CarbonIcon)).size, 20);
      expect(
        tester.widget<Text>(find.text('Normal')).style!.fontSize,
        CarbonTypeStyles.bodyCompact02.fontSize,
      );
    });
  });

  group('shape indicator', () {
    testWidgets('renders a distinct shape, colour, and label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const CarbonShapeIndicator(
            kind: CarbonShapeIndicatorKind.stable,
            label: 'Stable',
          ),
        ),
      );
      final CarbonIcon icon = tester.widget<CarbonIcon>(
        find.byType(CarbonIcon),
      );
      expect(icon.icon, CarbonIcons.circleFill);
      expect(icon.color, CarbonColors.green50);
      expect(find.text('Stable'), findsOneWidget);
    });

    testWidgets('failed and draft use different shapes', (
      WidgetTester tester,
    ) async {
      expect(
        CarbonShapeIndicatorKind.failed.shape,
        isNot(CarbonShapeIndicatorKind.draft.shape),
      );
    });
  });

  group('goldens', () {
    Widget column(List<Widget> rows) => Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final Widget r in rows)
            Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: r),
        ],
      ),
    );

    testWidgets('icon indicators', (WidgetTester tester) async {
      await expectThemeGoldens(
        tester,
        name: 'icon_indicator',
        containsText: true,
        size: const Size(220, 160),
        builder: (BuildContext context) => column(const <Widget>[
          CarbonIconIndicator(
            kind: CarbonIconIndicatorKind.failed,
            label: 'Failed',
          ),
          CarbonIconIndicator(
            kind: CarbonIconIndicatorKind.succeeded,
            label: 'Succeeded',
          ),
          CarbonIconIndicator(
            kind: CarbonIconIndicatorKind.inProgress,
            label: 'In progress',
          ),
          CarbonIconIndicator(
            kind: CarbonIconIndicatorKind.pending,
            label: 'Pending',
          ),
        ]),
      );
    });

    testWidgets('shape indicators', (WidgetTester tester) async {
      await expectThemeGoldens(
        tester,
        name: 'shape_indicator',
        containsText: true,
        size: const Size(200, 160),
        builder: (BuildContext context) => column(const <Widget>[
          CarbonShapeIndicator(
            kind: CarbonShapeIndicatorKind.critical,
            label: 'Critical',
          ),
          CarbonShapeIndicator(
            kind: CarbonShapeIndicatorKind.medium,
            label: 'Medium',
          ),
          CarbonShapeIndicator(
            kind: CarbonShapeIndicatorKind.stable,
            label: 'Stable',
          ),
        ]),
      );
    });

    testWidgets('badge indicators', (WidgetTester tester) async {
      await expectThemeGoldens(
        tester,
        name: 'badge_indicator',
        containsText: true,
        size: const Size(120, 80),
        builder: (BuildContext context) => column(const <Widget>[
          CarbonBadgeIndicator(),
          CarbonBadgeIndicator(count: 8),
          CarbonBadgeIndicator(count: 4000),
        ]),
      );
    });
  });
}
