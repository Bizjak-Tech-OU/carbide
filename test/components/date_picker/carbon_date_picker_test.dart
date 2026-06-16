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
    child: Align(alignment: Alignment.topLeft, child: child),
  ),
);

/// The date-picker field always mounts a [CarbonPopover] (OverlayPortal), so it
/// needs an Overlay + TapRegionSurface — a real app's scaffold supplies both.
Widget _overlay(Widget child) => TapRegionSurface(
  child: Overlay(
    initialEntries: <OverlayEntry>[
      OverlayEntry(
        builder: (BuildContext context) => Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
              ),
            ),
            Align(alignment: Alignment.topLeft, child: child),
          ],
        ),
      ),
    ],
  ),
);

/// Hosts a date-picker field with the Directionality + theme + overlay it needs.
Widget _fieldHost(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: CarbonTheme(data: CarbonThemeData.white, child: _overlay(child)),
);

void main() {
  final CarbonThemeData theme = CarbonThemeData.white;

  setUp(() {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
  });
  tearDown(() {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
  });

  group('calendar', () {
    testWidgets('renders the month, weekday headers and every day', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: CarbonCalendar(
              value: DateTime(2026, 6, 15),
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('June 2026'), findsOneWidget);
      expect(find.text('Su'), findsOneWidget);
      expect(find.text('Sa'), findsOneWidget);
      // June has 30 days.
      expect(find.text('30'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('the selected day fills with button-primary / text-on-color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: CarbonCalendar(
              value: DateTime(2026, 6, 15),
              onChanged: (_) {},
            ),
          ),
        ),
      );
      final ColoredBox box = tester.widget<ColoredBox>(
        find
            .ancestor(of: find.text('15'), matching: find.byType(ColoredBox))
            .first,
      );
      expect(box.color, theme.buttonPrimary);
      expect(
        tester.widget<Text>(find.text('15')).style!.color,
        theme.textOnColor,
      );
    });

    testWidgets('tapping a day reports it', (WidgetTester tester) async {
      DateTime? picked;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: CarbonCalendar(
              value: DateTime(2026, 6, 15),
              onChanged: (DateTime d) => picked = d,
            ),
          ),
        ),
      );
      await tester.tap(find.text('20'));
      expect(picked, DateTime(2026, 6, 20));
    });

    testWidgets('next/previous arrows change the visible month', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: CarbonCalendar(
              value: DateTime(2026, 6, 15),
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Next month'));
      await tester.pump();
      expect(find.text('July 2026'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Previous month'));
      await tester.tap(find.bySemanticsLabel('Previous month'));
      await tester.pump();
      expect(find.text('May 2026'), findsOneWidget);
    });

    testWidgets('days outside min/max are disabled and unselectable', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: CarbonCalendar(
              value: DateTime(2026, 6, 15),
              firstDate: DateTime(2026, 6, 10),
              lastDate: DateTime(2026, 6, 20),
              onChanged: (_) => taps++,
            ),
          ),
        ),
      );
      expect(
        tester.widget<Text>(find.text('5')).style!.color,
        theme.textDisabled,
      );
      await tester.tap(find.text('5'));
      expect(taps, 0);
      await tester.tap(find.text('12'));
      expect(taps, 1);
    });

    testWidgets('the selected day exposes selected semantics', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 320,
            child: CarbonCalendar(
              value: DateTime(2026, 6, 15),
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('15')),
        isSemantics(label: '15', isButton: true, isSelected: true),
      );
      handle.dispose();
    });
  });

  group('date picker field', () {
    testWidgets('shows the placeholder when empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _fieldHost(
          SizedBox(
            width: 320,
            child: CarbonDatePicker(labelText: 'Date', onChanged: (_) {}),
          ),
        ),
      );
      expect(find.text('mm/dd/yyyy'), findsOneWidget);
    });

    testWidgets('shows the formatted date when set', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _fieldHost(
          SizedBox(
            width: 320,
            child: CarbonDatePicker(
              labelText: 'Date',
              value: DateTime(2026, 6, 5),
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('06/05/2026'), findsOneWidget);
    });

    testWidgets('tapping opens the calendar; picking closes and reports', (
      WidgetTester tester,
    ) async {
      DateTime? picked;
      await tester.pumpWidget(
        _fieldHost(
          SizedBox(
            width: 320,
            child: CarbonDatePicker(
              labelText: 'Date',
              value: DateTime(2026, 6, 15),
              onChanged: (DateTime d) => picked = d,
            ),
          ),
        ),
      );
      expect(find.text('June 2026'), findsNothing);
      await tester.tap(find.text('06/15/2026'));
      await tester.pumpAndSettle();
      expect(find.text('June 2026'), findsOneWidget);
      await tester.tap(find.text('22'));
      await tester.pumpAndSettle();
      expect(picked, DateTime(2026, 6, 22));
      expect(find.text('June 2026'), findsNothing);
    });

    testWidgets('a disabled field does not open', (WidgetTester tester) async {
      await tester.pumpWidget(
        _fieldHost(
          SizedBox(
            width: 320,
            child: CarbonDatePicker(
              labelText: 'Date',
              disabled: true,
              value: DateTime(2026, 6, 15),
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.tap(find.text('06/15/2026'));
      await tester.pumpAndSettle();
      expect(find.text('June 2026'), findsNothing);
    });

    testWidgets('invalid shows the error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        _fieldHost(
          SizedBox(
            width: 320,
            child: CarbonDatePicker(
              labelText: 'Date',
              invalid: true,
              invalidText: 'Date is required',
              onChanged: (_) {},
            ),
          ),
        ),
      );
      expect(find.text('Date is required'), findsOneWidget);
    });
  });

  group('goldens', () {
    testWidgets('calendar across themes', (WidgetTester tester) async {
      await expectThemeGoldens(
        tester,
        name: 'date_picker_calendar',
        containsText: true,
        size: const Size(360, 400),
        builder: (BuildContext context) => Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 320,
            child: CarbonCalendar(
              value: DateTime(2026, 6, 15),
              firstDate: DateTime(2026, 6, 3),
              onChanged: (_) {},
            ),
          ),
        ),
      );
    });

    testWidgets('date picker field across themes', (WidgetTester tester) async {
      await expectThemeGoldens(
        tester,
        name: 'date_picker_field',
        containsText: true,
        size: const Size(320, 90),
        builder: (BuildContext context) => _overlay(
          SizedBox(
            width: 288,
            child: CarbonDatePicker(
              labelText: 'Date',
              value: DateTime(2026, 6, 15),
              onChanged: (_) {},
            ),
          ),
        ),
      );
    });
  });
}
