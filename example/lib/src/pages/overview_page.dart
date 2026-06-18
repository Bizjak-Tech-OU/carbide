// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of the Carbide gallery and is licensed under the GNU
// Affero General Public License v3.0 or later.

import 'package:carbide/carbide.dart';
import 'package:flutter/widgets.dart';

import '../gallery_controller.dart';

/// The landing page: what Carbide is, the active theme, and quick links.
class OverviewPage extends StatelessWidget {
  /// Creates the overview page.
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CarbonThemeData theme = CarbonTheme.of(context);
    final GalleryController controller = GalleryScope.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Carbide', style: CarbonTypeStyles.productiveHeading06),
          const SizedBox(height: CarbonSpacing.spacing03),
          Text(
            'An unofficial Flutter port of the IBM Carbon Design System, built '
            'strictly on Flutter’s base widgets — no Material, no '
            'Cupertino.',
            style: CarbonTypeStyles.body02.copyWith(color: theme.textSecondary),
          ),
          const SizedBox(height: CarbonSpacing.spacing07),
          _InfoTile(heading: 'Active theme', body: controller.theme.label),
          const SizedBox(height: CarbonSpacing.spacing05),
          const _InfoTile(
            heading: 'Browse',
            body:
                'Pick a component from the navigation to see it live, tweak '
                'its props, and copy the code.',
          ),
          const SizedBox(height: CarbonSpacing.spacing07),
          Wrap(
            spacing: CarbonSpacing.spacing05,
            runSpacing: CarbonSpacing.spacing05,
            children: <Widget>[
              CarbonButton(
                label: 'Source on GitHub',
                kind: CarbonButtonKind.tertiary,
                icon: CarbonIcons.logoGithub,
                onPressed: () {},
              ),
              CarbonButton(
                label: 'Switch theme',
                kind: CarbonButtonKind.secondary,
                icon: CarbonIcons.colorPalette,
                onPressed: controller.cycleTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.heading, required this.body});

  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    final CarbonThemeData theme = CarbonTheme.of(context);
    return CarbonTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(heading, style: CarbonTypeStyles.productiveHeading03),
          const SizedBox(height: CarbonSpacing.spacing03),
          Text(
            body,
            style: CarbonTypeStyles.body01.copyWith(color: theme.textSecondary),
          ),
        ],
      ),
    );
  }
}
