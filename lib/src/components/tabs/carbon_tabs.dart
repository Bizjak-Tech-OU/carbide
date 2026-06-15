// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.
//
// Spec sources (Apache-2.0 Carbon Design System; see NOTICE):
//   styles/scss/components/tabs/_tabs.scss
//   react/src/components/Tabs/Tabs.tsx
//
// Tabs: a TabList of Tabs over matching TabPanels, in line (underline) and
// contained (filled) variants. Roving keyboard selection with automatic
// activation. (Overflow scroll buttons are a follow-up.)

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundations/layout.dart';
import '../../foundations/motion.dart';
import '../../foundations/typography.dart';
import '../../icons/carbon_icon.dart';
import '../../icons/carbon_icon_data.dart';
import '../../icons/carbon_icons.dart';
import '../../theme/carbon_layer.dart';
import '../../theme/carbon_theme.dart';
import '../../theme/carbon_theme_data.dart';
import '../../utils/focus_ring.dart';
import '../form/carbon_form.dart' show CarbonFieldSize;

/// The visual style of a [CarbonTabs].
enum CarbonTabVariant {
  /// An underline indicator beneath the selected tab.
  line,

  /// Filled tabs with a top indicator on the selected tab.
  contained,
}

/// A single tab in a [CarbonTabs].
class CarbonTab {
  /// Creates a tab.
  const CarbonTab({
    required this.label,
    this.icon,
    this.disabled = false,
    this.dismissable = false,
    this.onDismiss,
  });

  /// The tab label.
  final String label;

  /// An optional leading icon.
  final CarbonIconData? icon;

  /// Whether the tab is disabled.
  final bool disabled;

  /// Whether the tab shows a close control.
  final bool dismissable;

  /// Called when the close control is activated.
  final VoidCallback? onDismiss;
}

/// A tabbed interface: a row of [tabs] with a matching panel each.
///
/// Selection is controlled when [onChanged] is provided, otherwise managed
/// internally. Left/Right (Home/End) move and activate tabs.
///
/// ```dart
/// CarbonTabs(
///   tabs: const <CarbonTab>[
///     CarbonTab(label: 'Overview'),
///     CarbonTab(label: 'Details'),
///   ],
///   panels: const <Widget>[Text('Overview'), Text('Details')],
/// )
/// ```
class CarbonTabs extends StatefulWidget {
  /// Creates a tabbed interface.
  const CarbonTabs({
    required this.tabs,
    required this.panels,
    super.key,
    this.selectedIndex,
    this.onChanged,
    this.variant = CarbonTabVariant.line,
    this.size = CarbonFieldSize.lg,
  });

  /// The tabs.
  final List<CarbonTab> tabs;

  /// The panels, one per tab.
  final List<Widget> panels;

  /// The selected index (controlled); null lets the widget manage it.
  final int? selectedIndex;

  /// Called when the selection changes.
  final ValueChanged<int>? onChanged;

  /// The visual variant.
  final CarbonTabVariant variant;

  /// The tab height.
  final CarbonFieldSize size;

  @override
  State<CarbonTabs> createState() => _CarbonTabsState();
}

class _CarbonTabsState extends State<CarbonTabs> {
  late int _selected = widget.selectedIndex ?? 0;
  late List<FocusNode> _nodes = _makeNodes();

  List<FocusNode> _makeNodes() =>
      List<FocusNode>.generate(widget.tabs.length, (_) => FocusNode());

  int get _current => widget.selectedIndex ?? _selected;

  @override
  void didUpdateWidget(CarbonTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs.length != oldWidget.tabs.length) {
      for (final FocusNode node in _nodes) {
        node.dispose();
      }
      _nodes = _makeNodes();
      if (_selected >= widget.tabs.length) _selected = 0;
    }
  }

  @override
  void dispose() {
    for (final FocusNode node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _select(int index) {
    if (index < 0 ||
        index >= widget.tabs.length ||
        widget.tabs[index].disabled) {
      return;
    }
    widget.onChanged?.call(index);
    if (widget.selectedIndex == null) setState(() => _selected = index);
    _nodes[index].requestFocus();
  }

  void _move(int delta) {
    final int n = widget.tabs.length;
    int next = _current;
    for (int i = 0; i < n; i++) {
      next = (next + delta + n) % n;
      if (!widget.tabs[next].disabled) {
        _select(next);
        return;
      }
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowRight:
      case LogicalKeyboardKey.arrowDown:
        _move(1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
      case LogicalKeyboardKey.arrowUp:
        _move(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.home:
        _select(widget.tabs.indexWhere((CarbonTab t) => !t.disabled));
        return KeyEventResult.handled;
      case LogicalKeyboardKey.end:
        _select(widget.tabs.lastIndexWhere((CarbonTab t) => !t.disabled));
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabWidgets = <Widget>[
      for (int i = 0; i < widget.tabs.length; i++)
        _TabButton(
          tab: widget.tabs[i],
          variant: widget.variant,
          size: widget.size,
          selected: i == _current,
          focusNode: _nodes[i],
          onKey: _onKey,
          onTap: () => _select(i),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          explicitChildNodes: true,
          container: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.variant == CarbonTabVariant.contained
                ? tabWidgets
                : <Widget>[...tabWidgets, const Expanded(child: _LineFiller())],
          ),
        ),
        if (widget.panels.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: CarbonSpacing.spacing05),
            child: Semantics(
              container: true,
              child: KeyedSubtree(
                key: ValueKey<int>(_current),
                child: widget.panels[_current],
              ),
            ),
          ),
      ],
    );
  }
}

/// The 1px subtle baseline that line tabs sit on, filling the unused width.
class _LineFiller extends StatelessWidget {
  const _LineFiller();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CarbonLayer.of(context).borderSubtle),
        ),
      ),
      child: const SizedBox(height: 1),
    );
  }
}

class _TabButton extends StatefulWidget {
  const _TabButton({
    required this.tab,
    required this.variant,
    required this.size,
    required this.selected,
    required this.focusNode,
    required this.onKey,
    required this.onTap,
  });

  final CarbonTab tab;
  final CarbonTabVariant variant;
  final CarbonFieldSize size;
  final bool selected;
  final FocusNode focusNode;
  final KeyEventResult Function(FocusNode, KeyEvent) onKey;
  final VoidCallback onTap;

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final CarbonThemeData theme = CarbonTheme.of(context);
    final CarbonLayerTokens layer = CarbonLayer.of(context);
    final bool enabled = !widget.tab.disabled;
    final bool line = widget.variant == CarbonTabVariant.line;
    final bool active = enabled && (_hovered);

    final Color text = widget.tab.disabled
        ? theme.textDisabled
        : widget.selected || active
        ? theme.textPrimary
        : theme.textSecondary;

    // Line: a bottom underline (1px subtle / hover strong / 2px interactive
    // selected). Contained: a filled cell with a top indicator when selected.
    final BoxDecoration decoration = line
        ? BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.selected
                    ? theme.borderInteractive
                    : active
                    ? theme.borderStrong01
                    : layer.borderSubtle,
                width: widget.selected ? 2 : 1,
              ),
            ),
          )
        : BoxDecoration(
            color: widget.selected
                ? layer.layer
                : active
                ? layer.layerAccentHover
                : layer.layerAccent,
            border: Border(
              top: BorderSide(
                color: widget.selected
                    ? theme.borderInteractive
                    : const Color(0x00000000),
                width: 2,
              ),
              right: BorderSide(color: layer.borderSubtle),
            ),
          );

    final Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.tab.icon != null) ...<Widget>[
          CarbonIcon(widget.tab.icon!, color: text),
          const SizedBox(width: CarbonSpacing.spacing03),
        ],
        ExcludeSemantics(
          child: Text(
            widget.tab.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CarbonTypeStyles.bodyCompact01.copyWith(color: text),
          ),
        ),
        if (widget.tab.dismissable) ...<Widget>[
          const SizedBox(width: CarbonSpacing.spacing03),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? widget.tab.onDismiss : null,
            child: CarbonIcon(
              CarbonIcons.close,
              size: 16,
              color: text,
              semanticLabel: 'Dismiss ${widget.tab.label}',
            ),
          ),
        ],
      ],
    );

    return Semantics(
      selected: widget.selected,
      enabled: enabled,
      button: true,
      label: widget.tab.label,
      onTap: enabled ? widget.onTap : null,
      child: MouseRegion(
        cursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? widget.onTap : null,
          child: Focus(
            focusNode: widget.focusNode,
            canRequestFocus: enabled,
            onKeyEvent: widget.onKey,
            onFocusChange: (bool f) => setState(() => _focused = f),
            child: CarbonFocusRing(
              visible: _focused,
              inset: true,
              child: AnimatedContainer(
                duration: CarbonDuration.fast01,
                curve: CarbonEasing.standardProductive,
                height: widget.size.height,
                padding: const EdgeInsets.symmetric(
                  horizontal: CarbonSpacing.spacing05,
                ),
                alignment: Alignment.center,
                decoration: decoration,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
