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
    child: Center(child: SizedBox(width: 480, child: child)),
  ),
);

BoxDecoration _box(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find
                  .ancestor(
                    of: find.byType(IntrinsicHeight),
                    matching: find.byType(DecoratedBox),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration;

void main() {
  final CarbonThemeData theme = CarbonThemeData.white;

  setUp(() {
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
  });
  tearDown(() {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
  });

  group('InlineNotification', () {
    testWidgets('title, subtitle, status icon; close fires', (
      WidgetTester tester,
    ) async {
      int closes = 0;
      await tester.pumpWidget(
        _host(
          CarbonInlineNotification(
            kind: CarbonNotificationKind.error,
            title: 'Error',
            subtitle: 'Something failed',
            onClose: () => closes++,
          ),
        ),
      );
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Something failed'), findsOneWidget);
      // The status icon is ErrorFilled in the inverse error accent.
      final CarbonIconPainter icon =
          tester
                  .widget<CustomPaint>(
                    find
                        .descendant(
                          of: find.byType(CarbonIcon),
                          matching: find.byType(CustomPaint),
                        )
                        .first,
                  )
                  .painter!
              as CarbonIconPainter;
      expect(icon.color, theme.supportErrorInverse);
      await tester.tap(find.bySemanticsLabel('Close notification'));
      expect(closes, 1);
    });

    testWidgets('default is high-contrast; lowContrast uses the layer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const CarbonInlineNotification(
            kind: CarbonNotificationKind.success,
            title: 'Done',
          ),
        ),
      );
      expect(_box(tester).color, theme.backgroundInverse);
      expect(
        tester.widget<Text>(find.text('Done')).style!.color,
        theme.textInverse,
      );

      await tester.pumpWidget(
        _host(
          const CarbonInlineNotification(
            kind: CarbonNotificationKind.success,
            title: 'Done',
            lowContrast: true,
          ),
        ),
      );
      expect(_box(tester).color, theme.layer01);
      expect(
        tester.widget<Text>(find.text('Done')).style!.color,
        theme.textPrimary,
      );
    });
  });

  group('ToastNotification', () {
    testWidgets('stacks title, subtitle and caption', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const CarbonToastNotification(
            kind: CarbonNotificationKind.info,
            title: 'Heads up',
            subtitle: 'A new version is available',
            caption: '00:00:00',
          ),
        ),
      );
      expect(find.text('Heads up'), findsOneWidget);
      expect(find.text('A new version is available'), findsOneWidget);
      expect(find.text('00:00:00'), findsOneWidget);
      // Stacked: the subtitle sits below the title.
      expect(
        tester.getTopLeft(find.text('A new version is available')).dy,
        greaterThan(tester.getTopLeft(find.text('Heads up')).dy),
      );
    });
  });

  group('ActionableNotification', () {
    testWidgets('action link fires', (WidgetTester tester) async {
      int acted = 0;
      await tester.pumpWidget(
        _host(
          CarbonActionableNotification(
            kind: CarbonNotificationKind.warning,
            title: 'Careful',
            actionLabel: 'Undo',
            onAction: () => acted++,
          ),
        ),
      );
      await tester.tap(find.text('Undo'));
      expect(acted, 1);
    });
  });

  group('semantics', () {
    testWidgets('is a live region with a labelled close', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          CarbonInlineNotification(
            kind: CarbonNotificationKind.info,
            title: 'Note',
            onClose: () {},
          ),
        ),
      );
      expect(find.bySemanticsLabel('Close notification'), findsOneWidget);
      handle.dispose();
    });
  });

  group('goldens', () {
    testWidgets('notification kinds across themes', (
      WidgetTester tester,
    ) async {
      await expectThemeGoldens(
        tester,
        name: 'notifications',
        containsText: true,
        size: const Size(480, 320),
        builder: (BuildContext context) => Center(
          child: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CarbonInlineNotification(
                  kind: CarbonNotificationKind.error,
                  title: 'Error',
                  subtitle: 'A problem occurred.',
                  onClose: () {},
                ),
                const SizedBox(height: 12),
                CarbonInlineNotification(
                  kind: CarbonNotificationKind.success,
                  title: 'Success',
                  subtitle: 'Saved.',
                  lowContrast: true,
                  onClose: () {},
                ),
                const SizedBox(height: 12),
                CarbonActionableNotification(
                  kind: CarbonNotificationKind.warning,
                  title: 'Warning',
                  subtitle: 'Unsaved changes.',
                  actionLabel: 'Save',
                  onAction: () {},
                  onClose: () {},
                ),
              ],
            ),
          ),
        ),
      );
    });
  });
}
