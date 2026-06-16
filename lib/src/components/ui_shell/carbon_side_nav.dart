// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.
//
// Spec sources (Apache-2.0 Carbon Design System; see NOTICE):
//   styles/scss/components/ui-shell/side-nav/_side-nav.scss
//   react/src/components/UIShell/{SideNav,SideNavItems,SideNavLink,SideNavMenu,
//     SideNavMenuItem,SideNavDivider}.tsx
//
// The UI Shell side navigation: a 256px panel (48px rail when collapsed) of
// links and collapsible menus. Uses the contextual `background` tokens.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundations/layout.dart';
import '../../foundations/motion.dart';
import '../../foundations/typography.dart';
import '../../icons/carbon_icon.dart';
import '../../icons/carbon_icon_data.dart';
import '../../icons/carbon_icons.dart';
import '../../theme/carbon_theme.dart';
import '../../theme/carbon_theme_data.dart';
import '../../utils/focus_ring.dart';

/// Shared side-nav state read by its items.
class _SideNavScope extends InheritedWidget {
  const _SideNavScope({required this.expanded, required super.child});

  final bool expanded;

  static bool expandedOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SideNavScope>()?.expanded ??
      true;

  @override
  bool updateShouldNotify(_SideNavScope old) => expanded != old.expanded;
}

/// The left navigation panel of the UI Shell.
///
/// ```dart
/// CarbonSideNav(
///   items: <Widget>[
///     CarbonSideNavLink(label: 'Dashboard', icon: CarbonIcons.dashboard,
///         current: true, onPressed: _dashboard),
///     CarbonSideNavMenu(label: 'Reports', children: <Widget>[
///       CarbonSideNavMenuItem(label: 'Daily', onPressed: _daily),
///     ]),
///   ],
/// )
/// ```
class CarbonSideNav extends StatelessWidget {
  /// Creates a side nav.
  const CarbonSideNav({required this.items, super.key, this.expanded = true});

  /// The nav items (links, menus, dividers).
  final List<Widget> items;

  /// Whether the panel is expanded (256px) or a rail (48px, icons only).
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final CarbonThemeData theme = CarbonTheme.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Side navigation',
      child: _SideNavScope(
        expanded: expanded,
        child: AnimatedContainer(
          duration: CarbonDuration.moderate01,
          curve: CarbonEasing.standardProductive,
          width: expanded ? 256 : 48,
          color: theme.background,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: items,
            ),
          ),
        ),
      ),
    );
  }
}

/// The shared row layout for a side-nav link.
class _NavRow extends StatefulWidget {
  const _NavRow({
    required this.label,
    required this.icon,
    required this.current,
    required this.onTap,
    required this.indent,
    required this.trailing,
  });

  final String label;
  final CarbonIconData? icon;
  final bool current;
  final VoidCallback? onTap;
  final double indent;
  final Widget? trailing;

  @override
  State<_NavRow> createState() => _NavRowState();
}

class _NavRowState extends State<_NavRow> {
  bool _hovered = false;
  bool _focused = false;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (widget.onTap != null &&
        event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space)) {
      widget.onTap!();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final CarbonThemeData theme = CarbonTheme.of(context);
    final bool expanded = _SideNavScope.expandedOf(context);
    final Color text = widget.current || _hovered
        ? theme.textPrimary
        : theme.textSecondary;
    final Color background = widget.current
        ? theme.layerSelected01
        : _hovered
        ? theme.backgroundHover
        : const Color(0x00000000);

    return Semantics(
      button: true,
      selected: widget.current,
      label: widget.label,
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: Focus(
              onKeyEvent: _onKey,
              onFocusChange: (bool f) => setState(() => _focused = f),
              child: CarbonFocusRing(
                visible: _focused,
                inset: true,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: background,
                    // The active 4px border-interactive selection marker.
                    border: Border(
                      left: BorderSide(
                        color: widget.current
                            ? theme.borderInteractive
                            : const Color(0x00000000),
                        width: 3,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    height: 32,
                    child: expanded
                        ? Padding(
                            padding: EdgeInsetsDirectional.only(
                              start: CarbonSpacing.spacing05 + widget.indent,
                              end: CarbonSpacing.spacing05,
                            ),
                            child: Row(
                              children: <Widget>[
                                if (widget.icon != null) ...<Widget>[
                                  CarbonIcon(widget.icon!, color: text),
                                  const SizedBox(
                                    width: CarbonSpacing.spacing05,
                                  ),
                                ],
                                Expanded(
                                  child: Text(
                                    widget.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: CarbonTypeStyles.headingCompact01
                                        .copyWith(
                                          color: text,
                                          fontWeight: widget.current
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                  ),
                                ),
                                ?widget.trailing,
                              ],
                            ),
                          )
                        // The rail shows just a centred icon.
                        : Center(
                            child: widget.icon != null
                                ? CarbonIcon(widget.icon!, color: text)
                                : const SizedBox.shrink(),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A side-nav navigation link.
class CarbonSideNavLink extends StatelessWidget {
  /// Creates a side-nav link.
  const CarbonSideNavLink({
    required this.label,
    super.key,
    this.icon,
    this.current = false,
    this.onPressed,
  });

  /// The link label.
  final String label;

  /// An optional leading icon.
  final CarbonIconData? icon;

  /// Whether this link is the current page.
  final bool current;

  /// The navigation action.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => _NavRow(
    label: label,
    icon: icon,
    current: current,
    onTap: onPressed,
    indent: 0,
    trailing: null,
  );
}

/// A side-nav sub-item inside a [CarbonSideNavMenu].
class CarbonSideNavMenuItem extends StatelessWidget {
  /// Creates a side-nav menu item.
  const CarbonSideNavMenuItem({
    required this.label,
    super.key,
    this.current = false,
    this.onPressed,
  });

  /// The item label.
  final String label;

  /// Whether this item is the current page.
  final bool current;

  /// The navigation action.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => _NavRow(
    label: label,
    icon: null,
    current: current,
    onTap: onPressed,
    indent: CarbonSpacing.spacing06,
    trailing: null,
  );
}

/// A collapsible side-nav menu grouping [children].
class CarbonSideNavMenu extends StatefulWidget {
  /// Creates a side-nav menu.
  const CarbonSideNavMenu({
    required this.label,
    required this.children,
    super.key,
    this.icon,
    this.initiallyExpanded = false,
  });

  /// The group label.
  final String label;

  /// The sub-items (typically [CarbonSideNavMenuItem]s).
  final List<Widget> children;

  /// An optional leading icon.
  final CarbonIconData? icon;

  /// Whether the group starts expanded.
  final bool initiallyExpanded;

  @override
  State<CarbonSideNavMenu> createState() => _CarbonSideNavMenuState();
}

class _CarbonSideNavMenuState extends State<CarbonSideNavMenu> {
  late bool _open = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final CarbonThemeData theme = CarbonTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          button: true,
          expanded: _open,
          child: _NavRow(
            label: widget.label,
            icon: widget.icon,
            current: false,
            onTap: () => setState(() => _open = !_open),
            indent: 0,
            trailing: AnimatedRotation(
              turns: _open ? 0.5 : 0,
              duration: CarbonDuration.fast02,
              curve: CarbonEasing.standardProductive,
              child: CarbonIcon(
                CarbonIcons.chevronDown,
                size: 16,
                color: theme.iconPrimary,
              ),
            ),
          ),
        ),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: _open ? 1 : 0),
          duration: CarbonDuration.fast02,
          curve: CarbonEasing.standardProductive,
          builder: (BuildContext context, double t, Widget? child) => ClipRect(
            child: Align(
              alignment: Alignment.topLeft,
              heightFactor: t,
              child: child,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.children,
          ),
        ),
      ],
    );
  }
}

/// A 1px divider between side-nav sections.
class CarbonSideNavDivider extends StatelessWidget {
  /// Creates a side-nav divider.
  const CarbonSideNavDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final CarbonThemeData theme = CarbonTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CarbonSpacing.spacing05,
        vertical: CarbonSpacing.spacing03,
      ),
      child: SizedBox(
        height: 1,
        child: ColoredBox(color: theme.borderSubtle00),
      ),
    );
  }
}
