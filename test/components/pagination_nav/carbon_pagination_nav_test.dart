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
  child: TapRegionSurface(
    child: CarbonTheme(
      data: CarbonThemeData.white,
      child: Overlay(
        initialEntries: <OverlayEntry>[
          OverlayEntry(builder: (BuildContext context) => Center(child: child)),
        ],
      ),
    ),
  ),
);

CarbonButton _arrow(WidgetTester tester, String label) =>
    tester.widget<CarbonButton>(
      find.byWidgetPredicate(
        (Widget w) => w is CarbonButton && w.label == label,
      ),
    );

void main() {
  setUp(() {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
  });
  tearDown(() {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
  });

  group('layout / spec-lock', () {
    testWidgets('renders every page when they fit, no overflow', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(CarbonPaginationNav(totalItems: 5, page: 0, onChange: (_) {})),
      );
      for (final String n in <String>['1', '2', '3', '4', '5']) {
        expect(find.text(n), findsOneWidget);
      }
      expect(find.byType(CarbonOverflowMenu), findsNothing);
    });

    testWidgets('page buttons take the size height', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          CarbonPaginationNav(
            totalItems: 3,
            page: 0,
            size: CarbonPaginationNavSize.md,
            onChange: (_) {},
          ),
        ),
      );
      final Size box = tester.getSize(
        find
            .ancestor(of: find.text('2'), matching: find.byType(Container))
            .first,
      );
      expect(box.height, 40);
      expect(box.width, greaterThanOrEqualTo(40));
    });

    testWidgets('the active page is bold', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(CarbonPaginationNav(totalItems: 5, page: 2, onChange: (_) {})),
      );
      expect(
        tester.widget<Text>(find.text('3')).style!.fontWeight,
        FontWeight.w600,
      );
      expect(
        tester.widget<Text>(find.text('1')).style!.fontWeight,
        FontWeight.w400,
      );
    });
  });

  group('navigation', () {
    testWidgets('tapping a page reports its index', (
      WidgetTester tester,
    ) async {
      int? changed;
      await tester.pumpWidget(
        _host(
          CarbonPaginationNav(
            totalItems: 5,
            page: 0,
            onChange: (int p) => changed = p,
          ),
        ),
      );
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();
      expect(changed, 3);
    });

    testWidgets('arrows are bounded without loop', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(CarbonPaginationNav(totalItems: 5, page: 0, onChange: (_) {})),
      );
      expect(_arrow(tester, 'Previous page').onPressed, isNull);
      expect(_arrow(tester, 'Next page').onPressed, isNotNull);
    });

    testWidgets('next advances the page', (WidgetTester tester) async {
      int? changed;
      await tester.pumpWidget(
        _host(
          CarbonPaginationNav(
            totalItems: 5,
            page: 1,
            onChange: (int p) => changed = p,
          ),
        ),
      );
      _arrow(tester, 'Next page').onPressed!();
      expect(changed, 2);
    });

    testWidgets('loop wraps the previous arrow at the first page', (
      WidgetTester tester,
    ) async {
      int? changed;
      await tester.pumpWidget(
        _host(
          CarbonPaginationNav(
            totalItems: 5,
            page: 0,
            loop: true,
            onChange: (int p) => changed = p,
          ),
        ),
      );
      final CarbonButton prev = _arrow(tester, 'Previous page');
      expect(prev.onPressed, isNotNull);
      prev.onPressed!();
      expect(changed, 4);
    });
  });

  group('truncation', () {
    testWidgets('collapses the middle into overflow menus', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          CarbonPaginationNav(
            totalItems: 20,
            page: 10,
            itemsShown: 7,
            onChange: (_) {},
          ),
        ),
      );
      // First and last pages are always shown.
      expect(find.text('1'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      // At least one overflow menu is rendered.
      expect(find.byType(CarbonOverflowMenu), findsWidgets);
    });
  });

  group('semantics', () {
    testWidgets('exposes the current page', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(CarbonPaginationNav(totalItems: 5, page: 2, onChange: (_) {})),
      );
      expect(find.bySemanticsLabel('Page 3 of 5'), findsOneWidget);
      handle.dispose();
    });
  });

  group('goldens', () {
    Widget overlaid(Widget child) => Overlay(
      initialEntries: <OverlayEntry>[
        OverlayEntry(builder: (BuildContext context) => Center(child: child)),
      ],
    );

    testWidgets('full range', (WidgetTester tester) async {
      await expectThemeGoldens(
        tester,
        name: 'pagination_nav_full',
        containsText: true,
        size: const Size(420, 80),
        builder: (BuildContext context) => overlaid(
          CarbonPaginationNav(totalItems: 5, page: 2, onChange: (_) {}),
        ),
      );
    });

    testWidgets('truncated', (WidgetTester tester) async {
      await expectThemeGoldens(
        tester,
        name: 'pagination_nav_truncated',
        containsText: true,
        size: const Size(480, 80),
        builder: (BuildContext context) => overlaid(
          CarbonPaginationNav(
            totalItems: 20,
            page: 10,
            itemsShown: 7,
            onChange: (_) {},
          ),
        ),
      );
    });
  });
}
