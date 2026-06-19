// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.

import 'package:carbide/carbide.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden.dart';

Widget _host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: CarbonTheme(
    data: CarbonThemeData.white,
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 600, child: child),
    ),
  ),
);

void main() {
  final Map<String, Widget> all = <String, Widget>{
    'text input': const CarbonTextInputSkeleton(),
    'text area': const CarbonTextAreaSkeleton(),
    'number input': const CarbonNumberInputSkeleton(),
    'select': const CarbonSelectSkeleton(),
    'dropdown': const CarbonDropdownSkeleton(),
    'date picker': const CarbonDatePickerSkeleton(),
    'search': const CarbonSearchSkeleton(),
    'checkbox': const CarbonCheckboxSkeleton(),
    'radio': const CarbonRadioButtonSkeleton(),
    'toggle': const CarbonToggleSkeleton(),
    'slider': const CarbonSliderSkeleton(),
    'file uploader': const CarbonFileUploaderSkeleton(),
    'tabs': const CarbonTabsSkeleton(),
    'breadcrumb': const CarbonBreadcrumbSkeleton(),
    'pagination': const CarbonPaginationSkeleton(),
    'progress indicator': const CarbonProgressIndicatorSkeleton(),
    'accordion': const CarbonAccordionSkeleton(),
    'structured list': const CarbonStructuredListSkeleton(),
    'data table': const CarbonDataTableSkeleton(),
  };

  group('renders', () {
    all.forEach((String name, Widget widget) {
      testWidgets('$name skeleton renders shimmer shapes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(_host(widget));
        expect(tester.takeException(), isNull);
        expect(find.byType(CarbonSkeleton), findsWidgets);
      });
    });
  });

  group('geometry', () {
    testWidgets('a field skeleton has a label bar and a 40px field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const CarbonTextInputSkeleton()));
      expect(find.byType(CarbonSkeleton), findsNWidgets(2));
      // The field bar is 40px tall.
      expect(
        find.byWidgetPredicate(
          (Widget w) => w is CarbonSkeleton && w.height == 40,
        ),
        findsOneWidget,
      );
    });

    testWidgets('a text area skeleton field is 100px tall', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_host(const CarbonTextAreaSkeleton()));
      expect(
        find.byWidgetPredicate(
          (Widget w) => w is CarbonSkeleton && w.height == 100,
        ),
        findsOneWidget,
      );
    });

    testWidgets('hideLabel drops the label bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const CarbonTextInputSkeleton(hideLabel: true)),
      );
      expect(find.byType(CarbonSkeleton), findsOneWidget);
    });

    testWidgets('a data table skeleton fills header + body cells', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const CarbonDataTableSkeleton(rowCount: 3, columnCount: 4)),
      );
      // header (4) + 3 rows × 4 columns = 16 cells.
      expect(find.byType(CarbonSkeleton), findsNWidgets(16));
    });
  });

  group('goldens', () {
    Widget stack(double width, List<Widget> rows) => Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final Widget r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(width: width, child: r),
            ),
        ],
      ),
    );

    testWidgets('form skeletons', (WidgetTester tester) async {
      await expectThemeGoldens(
        tester,
        name: 'skeleton_form',
        size: const Size(280, 320),
        builder: (BuildContext context) => stack(240, const <Widget>[
          CarbonTextInputSkeleton(),
          CarbonCheckboxSkeleton(),
          CarbonToggleSkeleton(),
          CarbonSliderSkeleton(),
        ]),
      );
    });

    testWidgets('structural skeletons', (WidgetTester tester) async {
      await expectThemeGoldens(
        tester,
        name: 'skeleton_structural',
        size: const Size(360, 360),
        builder: (BuildContext context) => stack(320, const <Widget>[
          CarbonTabsSkeleton(count: 3),
          CarbonAccordionSkeleton(count: 3),
          CarbonDataTableSkeleton(rowCount: 3, columnCount: 3),
        ]),
      );
    });
  });
}
