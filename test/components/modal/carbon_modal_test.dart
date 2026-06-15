// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.

import 'package:carbide/carbide.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/golden.dart';

Widget _host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: CarbonTheme(
    data: CarbonThemeData.white,
    child: Overlay(
      initialEntries: <OverlayEntry>[
        OverlayEntry(builder: (BuildContext context) => child),
      ],
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

  Widget modal({
    bool open = true,
    VoidCallback? onClose,
    bool danger = false,
    bool passiveModal = false,
    bool preventCloseOnClickOutside = false,
    CarbonModalAction? primaryButton,
    CarbonModalAction? secondaryButton,
  }) => _host(
    CarbonModal(
      open: open,
      title: 'Delete item',
      label: 'Account',
      onClose: onClose,
      danger: danger,
      passiveModal: passiveModal,
      preventCloseOnClickOutside: preventCloseOnClickOutside,
      primaryButton: primaryButton,
      secondaryButton: secondaryButton,
      child: const Text('This cannot be undone.'),
    ),
  );

  group('visibility', () {
    testWidgets('content shows only when open', (WidgetTester tester) async {
      late StateSetter set;
      bool open = false;
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              set = setState;
              return CarbonModal(
                open: open,
                title: 'Title',
                child: const Text('Body'),
              );
            },
          ),
        ),
      );
      expect(find.text('Body'), findsNothing);
      set(() => open = true);
      await tester.pumpAndSettle();
      expect(find.text('Body'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
    });
  });

  group('dismissal', () {
    testWidgets('close button requests close', (WidgetTester tester) async {
      int closes = 0;
      await tester.pumpWidget(modal(onClose: () => closes++));
      await tester.tap(find.bySemanticsLabel('Close'));
      await tester.pump();
      expect(closes, 1);
    });

    testWidgets('outside tap closes', (WidgetTester tester) async {
      int closes = 0;
      await tester.pumpWidget(modal(onClose: () => closes++));
      // Tap the scrim corner, away from the centered dialog.
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      expect(closes, 1);
    });

    testWidgets('preventCloseOnClickOutside blocks the outside tap', (
      WidgetTester tester,
    ) async {
      int closes = 0;
      await tester.pumpWidget(
        modal(onClose: () => closes++, preventCloseOnClickOutside: true),
      );
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      expect(closes, 0);
    });

    testWidgets('Escape requests close', (WidgetTester tester) async {
      int closes = 0;
      await tester.pumpWidget(modal(onClose: () => closes++));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(closes, 1);
    });
  });

  group('footer', () {
    testWidgets('primary + secondary fire; danger uses the danger kind', (
      WidgetTester tester,
    ) async {
      int primary = 0;
      int secondary = 0;
      await tester.pumpWidget(
        modal(
          danger: true,
          primaryButton: CarbonModalAction(
            label: 'Delete',
            onPressed: () => primary++,
          ),
          secondaryButton: CarbonModalAction(
            label: 'Cancel',
            onPressed: () => secondary++,
          ),
        ),
      );
      await tester.tap(find.text('Cancel'));
      await tester.tap(find.text('Delete'));
      await tester.pump();
      expect(secondary, 1);
      expect(primary, 1);
      final CarbonButton primaryBtn = tester.widget<CarbonButton>(
        find.widgetWithText(CarbonButton, 'Delete'),
      );
      expect(primaryBtn.kind, CarbonButtonKind.danger);
    });

    testWidgets('passiveModal hides the footer', (WidgetTester tester) async {
      await tester.pumpWidget(
        modal(
          passiveModal: true,
          primaryButton: const CarbonModalAction(label: 'OK'),
        ),
      );
      expect(find.text('OK'), findsNothing);
    });
  });

  group('semantics', () {
    testWidgets('dialog names the route by its title', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(modal());
      expect(
        tester.getSemantics(find.bySemanticsLabel('Delete item')),
        isSemantics(label: 'Delete item', namesRoute: true, scopesRoute: true),
      );
      handle.dispose();
    });
  });

  group('goldens', () {
    testWidgets('danger modal across themes', (WidgetTester tester) async {
      await expectThemeGoldens(
        tester,
        name: 'modal_danger',
        containsText: true,
        size: const Size(720, 360),
        builder: (BuildContext context) => Overlay(
          initialEntries: <OverlayEntry>[
            OverlayEntry(
              builder: (BuildContext context) => CarbonModal(
                open: true,
                title: 'Delete account',
                label: 'Danger zone',
                danger: true,
                size: CarbonModalSize.sm,
                onClose: () {},
                primaryButton: CarbonModalAction(
                  label: 'Delete',
                  onPressed: () {},
                ),
                secondaryButton: CarbonModalAction(
                  label: 'Cancel',
                  onPressed: () {},
                ),
                child: const Text(
                  'Deleting this account is permanent and cannot be undone.',
                ),
              ),
            ),
          ],
        ),
        afterPump: (WidgetTester tester) async {
          await tester.pumpAndSettle();
        },
      );
    });
  });
}
