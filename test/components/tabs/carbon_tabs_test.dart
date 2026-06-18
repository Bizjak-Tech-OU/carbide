// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.

import 'package:carbide/carbide.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden.dart';
import '../../support/legibility.dart';

Widget _host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: CarbonTheme(
    data: CarbonThemeData.white,
    child: Center(child: SizedBox(width: 420, child: child)),
  ),
);

const List<CarbonTab> _tabs = <CarbonTab>[
  CarbonTab(label: 'Overview'),
  CarbonTab(label: 'Details'),
  CarbonTab(label: 'Settings', disabled: true),
  CarbonTab(label: 'Activity'),
];

const List<Widget> _panels = <Widget>[
  Text('Overview panel'),
  Text('Details panel'),
  Text('Settings panel'),
  Text('Activity panel'),
];

void main() {
  final CarbonThemeData theme = CarbonThemeData.white;

  setUp(() {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
  });
  tearDown(() {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
  });

  BoxDecoration decorationOf(WidgetTester tester, String label) =>
      tester
              .widget<AnimatedContainer>(
                find
                    .ancestor(
                      of: find.text(label),
                      matching: find.byType(AnimatedContainer),
                    )
                    .first,
              )
              .decoration!
          as BoxDecoration;

  group('selection', () {
    testWidgets('first panel shown by default; tapping switches', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const CarbonTabs(tabs: _tabs, panels: _panels)),
      );
      expect(find.text('Overview panel'), findsOneWidget);
      expect(find.text('Details panel'), findsNothing);
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(find.text('Details panel'), findsOneWidget);
      expect(find.text('Overview panel'), findsNothing);
    });

    testWidgets('disabled tab does not activate', (WidgetTester tester) async {
      await tester.pumpWidget(
        _host(const CarbonTabs(tabs: _tabs, panels: _panels)),
      );
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings panel'), findsNothing);
      expect(find.text('Overview panel'), findsOneWidget);
    });

    testWidgets('controlled selectedIndex + onChanged', (
      WidgetTester tester,
    ) async {
      int? changed;
      await tester.pumpWidget(
        _host(
          CarbonTabs(
            tabs: _tabs,
            panels: _panels,
            selectedIndex: 1,
            onChanged: (int i) => changed = i,
          ),
        ),
      );
      expect(find.text('Details panel'), findsOneWidget);
      await tester.tap(find.text('Activity'));
      await tester.pumpAndSettle();
      expect(changed, 3);
      // Controlled: panel stays until the parent updates selectedIndex.
      expect(find.text('Details panel'), findsOneWidget);
    });
  });

  group('keyboard roving', () {
    testWidgets('Right/Left move + activate, skipping disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const CarbonTabs(tabs: _tabs, panels: _panels)),
      );
      // Focus the first tab, then arrow across.
      tester
          .widget<Focus>(
            find
                .ancestor(
                  of: find.text('Overview'),
                  matching: find.byType(Focus),
                )
                .first,
          )
          .focusNode!
          .requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.text('Details panel'), findsOneWidget);
      // Right again skips the disabled 'Settings' and lands on 'Activity'.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.text('Activity panel'), findsOneWidget);
      // End/Home jump to the last/first enabled tab.
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(find.text('Overview panel'), findsOneWidget);
    });
  });

  group('chrome', () {
    testWidgets('line: selected tab has a 2px interactive underline', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const CarbonTabs(tabs: _tabs, panels: _panels)),
      );
      await tester.pumpAndSettle();
      final Border border = decorationOf(tester, 'Overview').border! as Border;
      expect(border.bottom.width, 2);
      expect(border.bottom.color, theme.borderInteractive);
      // An unselected tab uses the 1px subtle underline.
      final Border other = decorationOf(tester, 'Details').border! as Border;
      expect(other.bottom.width, 1);
      expect(other.bottom.color, theme.borderSubtle00);
      // Tab labels sit in a fixed-height tab; keep them legible.
      expectTextNotClipped(tester, find.text('Overview'));
    });

    testWidgets('contained: selected tab is filled with the layer token', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const CarbonTabs(
            tabs: _tabs,
            panels: _panels,
            variant: CarbonTabVariant.contained,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(decorationOf(tester, 'Overview').color, theme.layer01);
      expect(decorationOf(tester, 'Details').color, theme.layerAccent01);
    });

    testWidgets('dismissable tab exposes a labelled close', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      int dismissed = 0;
      await tester.pumpWidget(
        _host(
          CarbonTabs(
            tabs: <CarbonTab>[
              CarbonTab(
                label: 'Draft',
                dismissable: true,
                onDismiss: () => dismissed++,
              ),
            ],
            panels: const <Widget>[Text('Draft panel')],
          ),
        ),
      );
      expect(find.bySemanticsLabel('Dismiss Draft'), findsOneWidget);
      await tester.tap(find.byType(CarbonIcon));
      expect(dismissed, 1);
      handle.dispose();
    });
  });

  group('semantics', () {
    testWidgets('tabs expose selected state', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(const CarbonTabs(tabs: _tabs, panels: _panels)),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Overview')),
        isSemantics(label: 'Overview', isSelected: true),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Details')),
        isSemantics(label: 'Details', isSelected: false),
      );
      handle.dispose();
    });
  });

  group('goldens', () {
    testWidgets('line + contained across themes', (WidgetTester tester) async {
      await expectThemeGoldens(
        tester,
        name: 'tabs_variants',
        containsText: true,
        size: const Size(440, 220),
        builder: (BuildContext context) => Center(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const <Widget>[
                CarbonTabs(tabs: _tabs, panels: _panels),
                SizedBox(height: 24),
                CarbonTabs(
                  tabs: _tabs,
                  panels: _panels,
                  variant: CarbonTabVariant.contained,
                ),
              ],
            ),
          ),
        ),
      );
    });
  });
}
