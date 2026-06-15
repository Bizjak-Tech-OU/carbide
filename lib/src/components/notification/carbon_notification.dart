// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.
//
// Spec sources (Apache-2.0 Carbon Design System; see NOTICE):
//   styles/scss/components/notification/_notification.scss
//   react/src/components/Notification/Notification.tsx
//
// Notifications: Inline, Toast and Actionable variants sharing a left status
// bar + icon, title/subtitle and a close control. Default (high contrast) uses
// the inverse palette; lowContrast uses the layer surface.

import 'package:flutter/widgets.dart';

import '../../foundations/layout.dart';
import '../../foundations/typography.dart';
import '../../icons/carbon_icon.dart';
import '../../icons/carbon_icons.dart';
import '../../icons/carbon_icon_data.dart';
import '../../theme/carbon_layer.dart';
import '../../theme/carbon_theme.dart';
import '../../theme/carbon_theme_data.dart';
import '../link/carbon_link.dart';

/// The status of a notification.
enum CarbonNotificationKind {
  /// An error.
  error,

  /// A success.
  success,

  /// A warning.
  warning,

  /// Informational.
  info,
}

/// Resolves per-kind tokens for a notification.
class _KindStyle {
  const _KindStyle(this.icon, this.accent);
  final CarbonIconData icon;
  final Color accent;

  static _KindStyle of(
    CarbonNotificationKind kind,
    CarbonThemeData theme,
    bool lowContrast,
  ) {
    switch (kind) {
      case CarbonNotificationKind.error:
        return _KindStyle(
          CarbonIcons.errorFilled,
          lowContrast ? theme.supportError : theme.supportErrorInverse,
        );
      case CarbonNotificationKind.success:
        return _KindStyle(
          CarbonIcons.checkmarkFilled,
          lowContrast ? theme.supportSuccess : theme.supportSuccessInverse,
        );
      case CarbonNotificationKind.warning:
        return _KindStyle(
          CarbonIcons.warningFilled,
          lowContrast ? theme.supportWarning : theme.supportWarningInverse,
        );
      case CarbonNotificationKind.info:
        return _KindStyle(
          CarbonIcons.informationFilled,
          lowContrast ? theme.supportInfo : theme.supportInfoInverse,
        );
    }
  }
}

/// An inline notification, shown within page content.
class CarbonInlineNotification extends StatelessWidget {
  /// Creates an inline notification.
  const CarbonInlineNotification({
    required this.kind,
    required this.title,
    super.key,
    this.subtitle,
    this.lowContrast = false,
    this.onClose,
    this.closeLabel = 'Close notification',
  });

  /// The notification status.
  final CarbonNotificationKind kind;

  /// The bold title.
  final String title;

  /// The optional subtitle.
  final String? subtitle;

  /// Whether to use the light low-contrast surface.
  final bool lowContrast;

  /// Called when the close control is activated; null hides it.
  final VoidCallback? onClose;

  /// The accessible label for the close control.
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    return _NotificationBase(
      kind: kind,
      title: title,
      subtitle: subtitle,
      lowContrast: lowContrast,
      stackText: false,
      onClose: onClose,
      closeLabel: closeLabel,
    );
  }
}

/// A floating toast notification with stacked title/subtitle and optional
/// [caption].
class CarbonToastNotification extends StatelessWidget {
  /// Creates a toast notification.
  const CarbonToastNotification({
    required this.kind,
    required this.title,
    super.key,
    this.subtitle,
    this.caption,
    this.lowContrast = false,
    this.onClose,
    this.closeLabel = 'Close notification',
  });

  /// The notification status.
  final CarbonNotificationKind kind;

  /// The bold title.
  final String title;

  /// The optional subtitle.
  final String? subtitle;

  /// The optional caption (for example a timestamp).
  final String? caption;

  /// Whether to use the light low-contrast surface.
  final bool lowContrast;

  /// Called when the close control is activated; null hides it.
  final VoidCallback? onClose;

  /// The accessible label for the close control.
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: _NotificationBase(
        kind: kind,
        title: title,
        subtitle: subtitle,
        caption: caption,
        lowContrast: lowContrast,
        stackText: true,
        onClose: onClose,
        closeLabel: closeLabel,
      ),
    );
  }
}

/// A notification with an inline action button (alertdialog role).
class CarbonActionableNotification extends StatelessWidget {
  /// Creates an actionable notification.
  const CarbonActionableNotification({
    required this.kind,
    required this.title,
    required this.actionLabel,
    super.key,
    this.subtitle,
    this.onAction,
    this.lowContrast = false,
    this.onClose,
    this.closeLabel = 'Close notification',
  });

  /// The notification status.
  final CarbonNotificationKind kind;

  /// The bold title.
  final String title;

  /// The optional subtitle.
  final String? subtitle;

  /// The action button label.
  final String actionLabel;

  /// The action.
  final VoidCallback? onAction;

  /// Whether to use the light low-contrast surface.
  final bool lowContrast;

  /// Called when the close control is activated; null hides it.
  final VoidCallback? onClose;

  /// The accessible label for the close control.
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    return _NotificationBase(
      kind: kind,
      title: title,
      subtitle: subtitle,
      lowContrast: lowContrast,
      stackText: false,
      actionLabel: actionLabel,
      onAction: onAction,
      onClose: onClose,
      closeLabel: closeLabel,
    );
  }
}

class _NotificationBase extends StatelessWidget {
  const _NotificationBase({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.lowContrast,
    required this.stackText,
    required this.onClose,
    required this.closeLabel,
    this.caption,
    this.actionLabel,
    this.onAction,
  });

  final CarbonNotificationKind kind;
  final String title;
  final String? subtitle;
  final String? caption;
  final bool lowContrast;
  final bool stackText;
  final VoidCallback? onClose;
  final String closeLabel;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final CarbonThemeData theme = CarbonTheme.of(context);
    final CarbonLayerTokens layer = CarbonLayer.of(context);
    final _KindStyle style = _KindStyle.of(kind, theme, lowContrast);

    final Color background = lowContrast
        ? layer.layer
        : theme.backgroundInverse;
    final Color textColor = lowContrast ? theme.textPrimary : theme.textInverse;

    final TextStyle titleStyle = CarbonTypeStyles.bodyCompact01.copyWith(
      color: textColor,
      fontWeight: FontWeight.w600,
    );
    final TextStyle subtitleStyle = CarbonTypeStyles.bodyCompact01.copyWith(
      color: textColor,
    );

    final Widget titleText = Text(title, style: titleStyle);
    final Widget? subtitleText = subtitle == null
        ? null
        : Text(subtitle!, style: subtitleStyle);

    final Widget body = stackText
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              titleText,
              if (subtitleText != null) ...<Widget>[
                const SizedBox(height: CarbonSpacing.spacing02),
                subtitleText,
              ],
              if (caption != null) ...<Widget>[
                const SizedBox(height: CarbonSpacing.spacing03),
                Text(
                  caption!,
                  style: CarbonTypeStyles.label01.copyWith(color: textColor),
                ),
              ],
            ],
          )
        : Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: CarbonSpacing.spacing03,
            children: <Widget>[titleText, ?subtitleText],
          );

    return Semantics(
      container: true,
      liveRegion: true,
      explicitChildNodes: true,
      // role status / alert / alertdialog (approximated via the live region);
      // the merged title + subtitle is the announcement.
      label: '$title. ${subtitle ?? ''}'.trim(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          // border: 1px on top/right/bottom in the accent colour (the left
          // edge is the status bar).
          border: Border(
            top: BorderSide(color: style.accent),
            right: BorderSide(color: style.accent),
            bottom: BorderSide(color: style.accent),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // The 3px left status bar.
              SizedBox(width: 3, child: ColoredBox(color: style.accent)),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  CarbonSpacing.spacing05,
                  CarbonSpacing.spacing05,
                  0,
                  CarbonSpacing.spacing05,
                ),
                child: CarbonIcon(style.icon, color: style.accent),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: CarbonSpacing.spacing05,
                    top: CarbonSpacing.spacing05,
                    bottom: CarbonSpacing.spacing05,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: body,
                  ),
                ),
              ),
              if (actionLabel != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CarbonSpacing.spacing05,
                  ),
                  child: Align(
                    child: CarbonLink(label: actionLabel!, onPressed: onAction),
                  ),
                ),
              if (onClose != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onClose,
                  child: SizedBox(
                    width: 48,
                    child: Center(
                      child: CarbonIcon(
                        CarbonIcons.close,
                        color: textColor,
                        semanticLabel: closeLabel,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
