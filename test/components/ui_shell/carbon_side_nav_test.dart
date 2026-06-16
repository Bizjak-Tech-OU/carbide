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

void main() {
  final CarbonThemeData theme = CarbonThemeData.white;

  setUp(() {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
  });
  tearDown(() {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
  });

  group('panel', () {
    testWidgets('expanded is 256px and shows labels; rail is 48px', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          CarbonSideNav(
            items: <Widget>[
              CarbonSideNavLink(
                label: 'Dashboard',
                icon: CarbonIcons.dashboard,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(CarbonSideNav)).width, 256);
      expect(find.text('Dashboard'), findsOneWidget);

      await tester.pumpWidget(
        _host(
          CarbonSideNav(
            expanded: false,
            items: <Widget>[
              CarbonSideNavLink(
                label: 'Dashboard',
                icon: CarbonIcons.dashboard,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(CarbonSideNav)).width, 48);
      // The rail hides labels (icon only).
      expect(find.text('Dashboard'), findsNothing);
    });
  });

  group('links', () {
    testWidgets('current link: layer-selected + 4px interactive marker', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          CarbonSideNav(
            items: <Widget>[
              CarbonSideNavLink(label: 'Home', current: true, onPressed: () {}),
            ],
          ),
        ),
      );
      final BoxDecoration deco =
          tester
                  .widget<DecoratedBox>(
                    find
                        .ancestor(
                          of: find.text('Home'),
                          matching: find.byType(DecoratedBox),
                        )
                        .first,
                  )
                  .decoration
              as BoxDecoration;
      expect(deco.color, theme.layerSelected01);
      expect((deco.border! as Border).left.width, 3);
      expect((deco.border! as Border).left.color, theme.borderInteractive);
      expect(
        tester.widget<Text>(find.text('Home')).style!.fontWeight,
        FontWeight.w600,
      );
    });

    testWidgets('tapping a link navigates', (WidgetTester tester) async {
      int went = 0;
      await tester.pumpWidget(
        _host(
          CarbonSideNav(
            items: <Widget>[
              CarbonSideNavLink(label: 'Docs', onPressed: () => went++),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Docs'));
      expect(went, 1);
    });
  });

  group('menu', () {
    testWidgets('a menu expands and collapses its children', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          CarbonSideNav(
            items: <Widget>[
              CarbonSideNavMenu(
                label: 'Reports',
                children: <Widget>[
                  CarbonSideNavMenuItem(label: 'Daily', onPressed: () {}),
                  CarbonSideNavMenuItem(label: 'Weekly', onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Children present but collapsed (height factor 0).
      final double collapsed = tester
          .widget<Align>(
            find
                .ancestor(of: find.text('Daily'), matching: find.byType(Align))
                .first,
          )
          .heightFactor!;
      expect(collapsed, 0);
      await tester.tap(find.text('Reports'));
      await tester.pumpAndSettle();
      final double open = tester
          .widget<Align>(
            find
                .ancestor(of: find.text('Daily'), matching: find.byType(Align))
                .first,
          )
          .heightFactor!;
      expect(open, 1);
    });
  });

  group('goldens', () {
    testWidgets('side nav across themes (gray-100 is the dark shell)', (
      WidgetTester tester,
    ) async {
      await expectThemeGoldens(
        tester,
        name: 'ui_shell_side_nav',
        containsText: true,
        size: const Size(280, 260),
        builder: (BuildContext context) => Align(
          alignment: Alignment.topLeft,
          child: CarbonSideNav(
            items: <Widget>[
              CarbonSideNavLink(
                label: 'Dashboard',
                icon: CarbonIcons.dashboard,
                current: true,
                onPressed: () {},
              ),
              CarbonSideNavLink(
                label: 'Documents',
                icon: CarbonIcons.document,
                onPressed: () {},
              ),
              const CarbonSideNavDivider(),
              CarbonSideNavMenu(
                label: 'Reports',
                icon: CarbonIcons.chartBar,
                initiallyExpanded: true,
                children: <Widget>[
                  CarbonSideNavMenuItem(label: 'Daily', onPressed: () {}),
                  CarbonSideNavMenuItem(label: 'Weekly', onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
        afterPump: (WidgetTester tester) async {
          await tester.pumpAndSettle();
        },
      );
    });
  });
}
