// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.

import 'package:carbide/carbide.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden.dart';

/// OverlayPortal needs an Overlay ancestor; TapRegion needs a surface + a
/// hittable backdrop.
Widget _host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: TapRegionSurface(
    child: CarbonTheme(
      data: CarbonThemeData.white,
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
                Center(child: child),
              ],
            ),
          ),
        ],
      ),
    ),
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

  List<Widget> items(void Function(String) sink) => <Widget>[
    CarbonMenuItem(label: 'Edit', onPressed: () => sink('edit')),
    CarbonMenuItem(label: 'Duplicate', onPressed: () => sink('dup')),
    CarbonMenuItem(
      label: 'Delete',
      kind: CarbonMenuItemKind.danger,
      onPressed: () => sink('del'),
    ),
  ];

  group('CarbonOverflowMenu', () {
    testWidgets('icon trigger opens the menu; an item runs + closes', (
      WidgetTester tester,
    ) async {
      String? ran;
      await tester.pumpWidget(
        _host(CarbonOverflowMenu(items: items((String s) => ran = s))),
      );
      expect(find.byType(CarbonMenu), findsNothing);
      await tester.tap(find.byType(CarbonButton));
      await tester.pumpAndSettle();
      expect(find.byType(CarbonMenu), findsOneWidget);
      await tester.tap(find.text('Duplicate'));
      await tester.pumpAndSettle();
      expect(ran, 'dup');
      expect(find.byType(CarbonMenu), findsNothing);
    });

    testWidgets('outside tap closes the menu', (WidgetTester tester) async {
      await tester.pumpWidget(_host(CarbonOverflowMenu(items: items((_) {}))));
      await tester.tap(find.byType(CarbonButton));
      await tester.pumpAndSettle();
      expect(find.byType(CarbonMenu), findsOneWidget);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.byType(CarbonMenu), findsNothing);
    });

    testWidgets('trigger has an accessible label', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          CarbonOverflowMenu(
            items: items((_) {}),
            iconDescription: 'Row actions',
          ),
        ),
      );
      expect(find.bySemanticsLabel('Row actions'), findsOneWidget);
      handle.dispose();
    });
  });

  group('CarbonMenuButton', () {
    testWidgets('labelled button opens the menu', (WidgetTester tester) async {
      String? ran;
      await tester.pumpWidget(
        _host(
          CarbonMenuButton(
            label: 'Actions',
            items: items((String s) => ran = s),
          ),
        ),
      );
      expect(find.text('Actions'), findsOneWidget);
      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();
      expect(find.byType(CarbonMenu), findsOneWidget);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(ran, 'edit');
    });
  });

  group('CarbonComboButton', () {
    testWidgets('primary action fires; chevron opens the menu', (
      WidgetTester tester,
    ) async {
      int primary = 0;
      String? ran;
      await tester.pumpWidget(
        _host(
          CarbonComboButton(
            label: 'Save',
            onPressed: () => primary++,
            items: items((String s) => ran = s),
          ),
        ),
      );
      // The primary half runs its own action.
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(primary, 1);
      expect(find.byType(CarbonMenu), findsNothing);
      // The chevron half opens the secondary menu.
      await tester.tap(find.bySemanticsLabel('Additional actions'));
      await tester.pumpAndSettle();
      expect(find.byType(CarbonMenu), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(ran, 'del');
    });
  });

  group('goldens', () {
    testWidgets('open overflow menu across themes', (
      WidgetTester tester,
    ) async {
      await expectThemeGoldens(
        tester,
        name: 'overflow_menu_open',
        containsText: true,
        size: const Size(220, 180),
        builder: (BuildContext context) => Overlay(
          initialEntries: <OverlayEntry>[
            OverlayEntry(
              builder: (BuildContext context) => Padding(
                padding: const EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: CarbonOverflowMenu(
                    menuAlignment: CarbonMenuAlignment.start,
                    items: <Widget>[
                      CarbonMenuItem(label: 'Edit', onPressed: () {}),
                      CarbonMenuItem(label: 'Duplicate', onPressed: () {}),
                      const CarbonMenuItemDivider(),
                      CarbonMenuItem(
                        label: 'Delete',
                        kind: CarbonMenuItemKind.danger,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        afterPump: (WidgetTester tester) async {
          await tester.tap(find.byType(CarbonButton));
          await tester.pumpAndSettle();
        },
      );
    });
  });
}
