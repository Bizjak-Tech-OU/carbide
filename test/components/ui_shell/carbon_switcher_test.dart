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
    child: Align(alignment: Alignment.topRight, child: child),
  ),
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

  Widget switcher(VoidCallback onTap, {bool open = true}) => _host(
    CarbonHeaderPanel(
      open: open,
      child: CarbonSwitcher(
        children: <Widget>[
          CarbonSwitcherItem(
            label: 'Console',
            selected: true,
            onPressed: () {},
          ),
          const CarbonSwitcherDivider(),
          CarbonSwitcherItem(label: 'Catalog', onPressed: onTap),
        ],
      ),
    ),
  );

  group('header panel', () {
    testWidgets('open is 256px wide; closed collapses to 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(switcher(() {}));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(CarbonHeaderPanel)).width, 256);

      await tester.pumpWidget(switcher(() {}, open: false));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(CarbonHeaderPanel)).width, 0);
    });
  });

  group('switcher', () {
    testWidgets('items render; tapping navigates; selected is bold', (
      WidgetTester tester,
    ) async {
      int went = 0;
      await tester.pumpWidget(switcher(() => went++));
      await tester.pumpAndSettle();
      expect(find.text('Console'), findsOneWidget);
      expect(find.text('Catalog'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('Console')).style!.fontWeight,
        FontWeight.w600,
      );
      expect(
        tester.widget<Text>(find.text('Console')).style!.color,
        theme.textPrimary,
      );
      await tester.tap(find.text('Catalog'));
      expect(went, 1);
    });

    testWidgets('selected item exposes selected semantics', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(switcher(() {}));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.bySemanticsLabel('Console')),
        isSemantics(label: 'Console', isButton: true, isSelected: true),
      );
      handle.dispose();
    });
  });

  group('content', () {
    testWidgets('exposes a main-content region', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(const CarbonShellContent(child: Text('Body'))),
      );
      expect(find.text('Body'), findsOneWidget);
      expect(find.bySemanticsLabel('Main content'), findsOneWidget);
      handle.dispose();
    });
  });

  group('goldens', () {
    testWidgets('switcher panel across themes', (WidgetTester tester) async {
      await expectThemeGoldens(
        tester,
        name: 'ui_shell_switcher',
        containsText: true,
        size: const Size(280, 200),
        builder: (BuildContext context) => Align(
          alignment: Alignment.topRight,
          child: CarbonHeaderPanel(
            open: true,
            child: CarbonSwitcher(
              children: <Widget>[
                CarbonSwitcherItem(
                  label: 'Console',
                  selected: true,
                  onPressed: () {},
                ),
                CarbonSwitcherItem(label: 'Catalog', onPressed: () {}),
                const CarbonSwitcherDivider(),
                CarbonSwitcherItem(label: 'Account', onPressed: () {}),
              ],
            ),
          ),
        ),
        afterPump: (WidgetTester tester) async {
          await tester.pumpAndSettle();
        },
      );
    });
  });
}
