// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.
//
// Spec sources (Apache-2.0 Carbon Design System; see NOTICE):
//   styles/scss/components/data-table/{_data-table,_vars,_mixins}.scss
//   react/src/components/DataTable/{DataTable,Table,TableContainer,TableHead,
//     TableHeader,TableBody,TableRow,TableCell}.tsx
//
// The core DataTable: a semantic, token-driven table that the sort / selection
// / expansion / toolbar features build on. No Material DataTable — equal-flex
// columns shared between the header and body rows.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundations/layout.dart';
import '../../foundations/motion.dart';
import '../../foundations/typography.dart';
import '../../icons/carbon_icon.dart';
import '../../icons/carbon_icons.dart';
import '../../theme/carbon_layer.dart';
import '../../theme/carbon_theme.dart';
import '../../theme/carbon_theme_data.dart';
import '../../utils/focus_ring.dart';

/// The row height of a [CarbonDataTable] (`_data-table.scss` size variants).
enum CarbonTableSize {
  /// Extra small — 24px rows.
  xs(24),

  /// Small — 32px rows.
  sm(32),

  /// Medium — 40px rows.
  md(40),

  /// Large — 48px rows (the default).
  lg(48),

  /// Extra large — 64px rows.
  xl(64);

  const CarbonTableSize(this.height);

  /// The row height in logical pixels.
  final double height;
}

/// The sort state of a [CarbonDataTable] column.
enum CarbonSortDirection {
  /// Not sorted.
  none,

  /// Ascending.
  ascending,

  /// Descending.
  descending,
}

/// A column definition for a [CarbonDataTable].
class CarbonTableColumn {
  /// Creates a table column.
  const CarbonTableColumn({
    required this.title,
    this.flex = 1,
    this.sortable = false,
  });

  /// The header label.
  final String title;

  /// The column's share of the available width.
  final int flex;

  /// Whether the column header sorts the table when activated.
  final bool sortable;
}

/// A row of cells for a [CarbonDataTable].
class CarbonTableRow {
  /// Creates a table row.
  const CarbonTableRow({required this.cells});

  /// The cell contents, one per column.
  final List<Widget> cells;
}

/// A Carbon data table.
///
/// ```dart
/// CarbonDataTable(
///   title: 'Routines',
///   columns: const <CarbonTableColumn>[
///     CarbonTableColumn(title: 'Name'),
///     CarbonTableColumn(title: 'Status'),
///   ],
///   rows: const <CarbonTableRow>[
///     CarbonTableRow(cells: <Widget>[Text('Load'), Text('Running')]),
///   ],
/// )
/// ```
class CarbonDataTable extends StatelessWidget {
  /// Creates a data table.
  const CarbonDataTable({
    required this.columns,
    required this.rows,
    super.key,
    this.size = CarbonTableSize.lg,
    this.zebra = false,
    this.stickyHeader = false,
    this.stickyHeaderHeight = 320,
    this.title,
    this.description,
    this.sortColumnIndex,
    this.sortDirection = CarbonSortDirection.none,
    this.onSort,
  });

  /// The columns.
  final List<CarbonTableColumn> columns;

  /// The body rows.
  final List<CarbonTableRow> rows;

  /// The row height.
  final CarbonTableSize size;

  /// Whether even rows are tinted (`useZebraStyles`).
  final bool zebra;

  /// Whether the header stays fixed while the body scrolls.
  final bool stickyHeader;

  /// The body's max height when [stickyHeader].
  final double stickyHeaderHeight;

  /// An optional table title.
  final String? title;

  /// An optional table description.
  final String? description;

  /// The index of the currently sorted column, or null.
  final int? sortColumnIndex;

  /// The sort direction of [sortColumnIndex].
  final CarbonSortDirection sortDirection;

  /// Called with a sortable column's index when its header is activated; the
  /// consumer cycles none → ascending → descending → none.
  final ValueChanged<int>? onSort;

  @override
  Widget build(BuildContext context) {
    final CarbonThemeData theme = CarbonTheme.of(context);
    final CarbonLayerTokens layer = CarbonLayer.of(context);

    final Widget header = _HeaderRow(
      columns: columns,
      size: size,
      sortColumnIndex: sortColumnIndex,
      sortDirection: sortDirection,
      onSort: onSort,
    );

    final List<Widget> bodyRows = <Widget>[
      for (int i = 0; i < rows.length; i++)
        _BodyRow(
          row: rows[i],
          columns: columns,
          size: size,
          // Zebra tints even rows (`tr:nth-child(even)`); rows are 1-based in
          // CSS, so the 0-based odd index is the even child.
          tinted: zebra && i.isOdd,
          isLast: i == rows.length - 1,
        ),
    ];

    final Widget body = stickyHeader
        ? ConstrainedBox(
            constraints: BoxConstraints(maxHeight: stickyHeaderHeight),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: bodyRows,
              ),
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: bodyRows,
          );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: ColoredBox(
        color: layer.layer,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (title != null || description != null)
              Padding(
                // TableContainer header: spacing-05 top, spacing-06 bottom.
                padding: const EdgeInsets.fromLTRB(
                  CarbonSpacing.spacing05,
                  CarbonSpacing.spacing05,
                  CarbonSpacing.spacing05,
                  CarbonSpacing.spacing06,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (title != null)
                      Text(
                        title!,
                        style: CarbonTypeStyles.heading03.copyWith(
                          color: theme.textPrimary,
                        ),
                      ),
                    if (description != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: CarbonSpacing.spacing02,
                        ),
                        child: Text(
                          description!,
                          style: CarbonTypeStyles.bodyCompact01.copyWith(
                            color: theme.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            header,
            body,
          ],
        ),
      ),
    );
  }
}

/// The header row: `layer-accent` background, `heading-compact-01` cells.
/// Sortable columns render as a sort button cycling through the directions.
class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.columns,
    required this.size,
    required this.sortColumnIndex,
    required this.sortDirection,
    required this.onSort,
  });

  final List<CarbonTableColumn> columns;
  final CarbonTableSize size;
  final int? sortColumnIndex;
  final CarbonSortDirection sortDirection;
  final ValueChanged<int>? onSort;

  @override
  Widget build(BuildContext context) {
    final CarbonLayerTokens layer = CarbonLayer.of(context);
    return ColoredBox(
      color: layer.layerAccent,
      child: SizedBox(
        height: size.height,
        child: Row(
          children: <Widget>[
            for (int i = 0; i < columns.length; i++)
              Expanded(
                flex: columns[i].flex,
                child: _HeaderCell(
                  column: columns[i],
                  direction: sortColumnIndex == i
                      ? sortDirection
                      : CarbonSortDirection.none,
                  onSort: columns[i].sortable && onSort != null
                      ? () => onSort!(i)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A single header cell — plain text, or a sort button with a sort glyph.
class _HeaderCell extends StatefulWidget {
  const _HeaderCell({
    required this.column,
    required this.direction,
    required this.onSort,
  });

  final CarbonTableColumn column;
  final CarbonSortDirection direction;
  final VoidCallback? onSort;

  @override
  State<_HeaderCell> createState() => _HeaderCellState();
}

class _HeaderCellState extends State<_HeaderCell> {
  bool _hovered = false;
  bool _focused = false;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (widget.onSort != null &&
        event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space)) {
      widget.onSort!();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final CarbonThemeData theme = CarbonTheme.of(context);
    final CarbonLayerTokens layer = CarbonLayer.of(context);
    final bool active = widget.direction != CarbonSortDirection.none;

    final Widget label = Text(
      widget.column.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: CarbonTypeStyles.headingCompact01.copyWith(
        color: theme.textPrimary,
      ),
    );

    if (widget.onSort == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CarbonSpacing.spacing05,
        ),
        child: Align(alignment: AlignmentDirectional.centerStart, child: label),
      );
    }

    // The sort glyph: ArrowsVertical when inactive (shown only on hover/focus),
    // ArrowUp / ArrowDown when ascending / descending.
    final Widget glyph = active
        ? CarbonIcon(
            widget.direction == CarbonSortDirection.ascending
                ? CarbonIcons.arrowUp
                : CarbonIcons.arrowDown,
            size: 16,
            color: theme.iconPrimary,
          )
        : Opacity(
            opacity: _hovered || _focused ? 1 : 0,
            child: CarbonIcon(
              CarbonIcons.arrowsVertical,
              size: 16,
              color: theme.iconPrimary,
            ),
          );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onSort,
        child: Focus(
          onKeyEvent: _onKey,
          onFocusChange: (bool f) => setState(() => _focused = f),
          child: CarbonFocusRing(
            visible: _focused,
            inset: true,
            child: ColoredBox(
              // Active / hovered sortable headers tint slightly.
              color: active || _hovered
                  ? layer.layerHover
                  : const Color(0x00000000),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: CarbonSpacing.spacing05,
                ),
                child: Row(
                  children: <Widget>[
                    Flexible(child: label),
                    const SizedBox(width: CarbonSpacing.spacing03),
                    glyph,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A body row with hover, optional zebra tint and a bottom divider.
class _BodyRow extends StatefulWidget {
  const _BodyRow({
    required this.row,
    required this.columns,
    required this.size,
    required this.tinted,
    required this.isLast,
  });

  final CarbonTableRow row;
  final List<CarbonTableColumn> columns;
  final CarbonTableSize size;
  final bool tinted;
  final bool isLast;

  @override
  State<_BodyRow> createState() => _BodyRowState();
}

class _BodyRowState extends State<_BodyRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final CarbonThemeData theme = CarbonTheme.of(context);
    final CarbonLayerTokens layer = CarbonLayer.of(context);

    final Color background = _hovered
        ? layer.layerHover
        : widget.tinted
        ? layer.layerAccent
        : layer.layer;
    final Color textColor = _hovered ? theme.textPrimary : theme.textSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: CarbonDuration.fast01,
        curve: CarbonEasing.standardProductive,
        decoration: BoxDecoration(
          color: background,
          // 1px border-subtle row divider (suppressed on the last row when the
          // table footer/border takes over).
          border: Border(
            bottom: BorderSide(
              color: widget.isLast
                  ? const Color(0x00000000)
                  : layer.borderSubtle,
            ),
          ),
        ),
        child: SizedBox(
          height: widget.size.height,
          child: DefaultTextStyle.merge(
            style: CarbonTypeStyles.bodyCompact01.copyWith(color: textColor),
            child: Row(
              children: <Widget>[
                for (int i = 0; i < widget.columns.length; i++)
                  Expanded(
                    flex: widget.columns[i].flex,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CarbonSpacing.spacing05,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: i < widget.row.cells.length
                            ? widget.row.cells[i]
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
