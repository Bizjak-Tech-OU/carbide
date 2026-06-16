// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.

import 'package:carbide/carbide.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden.dart';

/// CarbonHeaderMenu's dropdown needs an Overlay + TapRegionSurface + backdrop.
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
                Align(alignment: Alignment.topCenter, child: child),
              ],
            ),
          ),
        ],
      ),
    ),
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

  group('structure', () {
    testWidgets('48px bar with name, nav and global actions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          CarbonHeader(
            name: const CarbonHeaderName(prefix: 'IBM', name: 'Carbide'),
            navigation: <Widget>[
              CarbonHeaderMenuItem(label: 'Catalog', onPressed: () {}),
            ],
            globalActions: <Widget>[
              CarbonHeaderGlobalAction(
                icon: CarbonIcons.notification,
                label: 'Notifications',
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      expect(find.text('IBM'), findsOneWidget);
      expect(find.text('Carbide'), findsOneWidget);
      expect(find.text('Catalog'), findsOneWidget);
      expect(tester.getSize(find.byType(CarbonHeader)).height, 48);
      expect(find.bySemanticsLabel('Notifications'), findsOneWidget);
    });

    testWidgets('selected nav item has the 2px interactive underline', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          CarbonHeader(
            name: const CarbonHeaderName(name: 'App'),
            navigation: <Widget>[
              CarbonHeaderMenuItem(
                label: 'Home',
                selected: true,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      final Border border =
          (tester
                          .widget<DecoratedBox>(
                            find
                                .ancestor(
                                  of: find.text('Home'),
                                  matching: find.byType(DecoratedBox),
                                )
                                .first,
                          )
                          .decoration
                      as BoxDecoration)
                  .border!
              as Border;
      expect(border.bottom.width, 2);
      expect(border.bottom.color, theme.borderInteractive);
    });
  });

  group('interaction', () {
    testWidgets('nav item + global action fire', (WidgetTester tester) async {
      int nav = 0;
      int action = 0;
      await tester.pumpWidget(
        _host(
          CarbonHeader(
            name: const CarbonHeaderName(name: 'App'),
            navigation: <Widget>[
              CarbonHeaderMenuItem(label: 'Docs', onPressed: () => nav++),
            ],
            globalActions: <Widget>[
              CarbonHeaderGlobalAction(
                icon: CarbonIcons.search,
                label: 'Search',
                onPressed: () => action++,
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Docs'));
      await tester.tap(find.bySemanticsLabel('Search'));
      expect(nav, 1);
      expect(action, 1);
    });

    testWidgets('menu button swaps to a close icon when open', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const CarbonHeader(
            menuButton: CarbonHeaderMenuButton(
              label: 'Open menu',
              isOpen: true,
            ),
            name: CarbonHeaderName(name: 'App'),
          ),
        ),
      );
      final bool hasClose = tester
          .widgetList<CarbonIcon>(find.byType(CarbonIcon))
          .any((CarbonIcon i) => i.icon == CarbonIcons.close);
      expect(hasClose, isTrue);
    });

    testWidgets('header dropdown menu opens its items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          CarbonHeader(
            name: const CarbonHeaderName(name: 'App'),
            navigation: <Widget>[
              CarbonHeaderMenu(
                label: 'Products',
                items: <Widget>[
                  CarbonMenuItem(label: 'Cloud', onPressed: () {}),
                  CarbonMenuItem(label: 'AI', onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
      );
      expect(find.text('Cloud'), findsNothing);
      await tester.tap(find.text('Products'));
      await tester.pumpAndSettle();
      expect(find.text('Cloud'), findsOneWidget);
      expect(find.text('AI'), findsOneWidget);
    });
  });

  group('goldens', () {
    testWidgets('header across themes (gray-100 is the dark shell)', (
      WidgetTester tester,
    ) async {
      await expectThemeGoldens(
        tester,
        name: 'ui_shell_header',
        containsText: true,
        size: const Size(640, 48),
        builder: (BuildContext context) => CarbonHeader(
          menuButton: CarbonHeaderMenuButton(
            label: 'Open menu',
            onPressed: () {},
          ),
          name: const CarbonHeaderName(prefix: 'IBM', name: 'Carbide'),
          navigation: <Widget>[
            CarbonHeaderMenuItem(
              label: 'Catalog',
              selected: true,
              onPressed: () {},
            ),
            CarbonHeaderMenuItem(label: 'Docs', onPressed: () {}),
          ],
          globalActions: <Widget>[
            CarbonHeaderGlobalAction(
              icon: CarbonIcons.search,
              label: 'Search',
              onPressed: () {},
            ),
            CarbonHeaderGlobalAction(
              icon: CarbonIcons.notification,
              label: 'Notifications',
              onPressed: () {},
            ),
          ],
        ),
      );
    });
  });
}
