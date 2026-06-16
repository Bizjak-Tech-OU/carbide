// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of Carbide and is licensed under the GNU Affero General
// Public License v3.0 or later. See the LICENSE file in the project root.
//
// Spec sources (Apache-2.0 Carbon Design System; see NOTICE):
//   styles/scss/components/date-picker/{_date-picker,_flatpickr}.scss
//   react/src/components/DatePicker/{DatePicker,DatePickerInput}.tsx
//
// Carbon's DatePicker wraps the flatpickr JS calendar, which is not portable.
// Carbide builds a self-contained CarbonCalendar (no Material) opened from a
// DatePickerInput via the Popover (#90). (Range selection is a follow-up.)

import 'package:flutter/widgets.dart';

import '../../foundations/layout.dart';
import '../../foundations/typography.dart';
import '../../icons/carbon_icon.dart';
import '../../icons/carbon_icon_data.dart';
import '../../icons/carbon_icons.dart';
import '../../theme/carbon_layer.dart';
import '../../theme/carbon_theme.dart';
import '../../theme/carbon_theme_data.dart';
import '../form/carbon_form.dart';
import '../popover/carbon_popover.dart';

const List<String> _months = <String>[
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December', //
];
const List<String> _weekdays = <String>[
  'Su',
  'Mo',
  'Tu',
  'We',
  'Th',
  'Fr',
  'Sa',
];

/// A self-contained month calendar for picking a single date.
class CarbonCalendar extends StatefulWidget {
  /// Creates a calendar.
  const CarbonCalendar({
    required this.onChanged,
    super.key,
    this.value,
    this.firstDate,
    this.lastDate,
  });

  /// The selected date.
  final DateTime? value;

  /// Called with the picked date.
  final ValueChanged<DateTime> onChanged;

  /// The earliest selectable date (inclusive).
  final DateTime? firstDate;

  /// The latest selectable date (inclusive).
  final DateTime? lastDate;

  @override
  State<CarbonCalendar> createState() => _CarbonCalendarState();
}

class _CarbonCalendarState extends State<CarbonCalendar> {
  late DateTime _month = DateTime(
    (widget.value ?? DateTime.now()).year,
    (widget.value ?? DateTime.now()).month,
  );

  static DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _disabled(DateTime day) =>
      (widget.firstDate != null && day.isBefore(_dayOnly(widget.firstDate!))) ||
      (widget.lastDate != null && day.isAfter(_dayOnly(widget.lastDate!)));

  void _step(int months) =>
      setState(() => _month = DateTime(_month.year, _month.month + months));

  @override
  Widget build(BuildContext context) {
    final CarbonThemeData theme = CarbonTheme.of(context);
    final CarbonLayerTokens layer = CarbonLayer.of(context);
    final DateTime today = _dayOnly(DateTime.now());
    final int firstWeekday = DateTime(_month.year, _month.month).weekday % 7;
    final int daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;

    return ColoredBox(
      color: layer.layer,
      child: Padding(
        padding: const EdgeInsets.all(CarbonSpacing.spacing05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Month / year header with prev/next.
            Row(
              children: <Widget>[
                _NavArrow(
                  icon: CarbonIcons.chevronLeft,
                  label: 'Previous month',
                  onTap: () => _step(-1),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '${_months[_month.month - 1]} ${_month.year}',
                      style: CarbonTypeStyles.headingCompact01.copyWith(
                        color: theme.textPrimary,
                      ),
                    ),
                  ),
                ),
                _NavArrow(
                  icon: CarbonIcons.chevronRight,
                  label: 'Next month',
                  onTap: () => _step(1),
                ),
              ],
            ),
            const SizedBox(height: CarbonSpacing.spacing03),
            Row(
              children: <Widget>[
                for (final String w in _weekdays)
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: Text(
                        w,
                        style: CarbonTypeStyles.label01.copyWith(
                          color: theme.textHelper,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            for (int week = 0; week < 6; week++)
              Row(
                children: <Widget>[
                  for (int wd = 0; wd < 7; wd++)
                    _dayCell(
                      context,
                      theme,
                      layer,
                      today,
                      firstWeekday,
                      daysInMonth,
                      week * 7 + wd,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _dayCell(
    BuildContext context,
    CarbonThemeData theme,
    CarbonLayerTokens layer,
    DateTime today,
    int firstWeekday,
    int daysInMonth,
    int slot,
  ) {
    final int dayNum = slot - firstWeekday + 1;
    if (dayNum < 1 || dayNum > daysInMonth) {
      return const SizedBox(width: 40, height: 40);
    }
    final DateTime day = DateTime(_month.year, _month.month, dayNum);
    final bool selected =
        widget.value != null && _dayOnly(widget.value!) == day;
    final bool isToday = day == today;
    final bool disabled = _disabled(day);

    return _DayCell(
      day: dayNum,
      selected: selected,
      isToday: isToday,
      disabled: disabled,
      onTap: disabled ? null : () => widget.onChanged(day),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final CarbonIconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CarbonThemeData theme = CarbonTheme.of(context);
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox.square(
            dimension: 40,
            child: Center(child: CarbonIcon(icon, color: theme.iconPrimary)),
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatefulWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.isToday,
    required this.disabled,
    required this.onTap,
  });

  final int day;
  final bool selected;
  final bool isToday;
  final bool disabled;
  final VoidCallback? onTap;

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final CarbonThemeData theme = CarbonTheme.of(context);
    final CarbonLayerTokens layer = CarbonLayer.of(context);
    final Color background = widget.selected
        ? theme.buttonPrimary
        : _hovered && !widget.disabled
        ? layer.layerHover
        : const Color(0x00000000);
    final Color text = widget.disabled
        ? theme.textDisabled
        : widget.selected
        ? theme.textOnColor
        : theme.textPrimary;

    return Semantics(
      button: !widget.disabled,
      selected: widget.selected,
      label: '${widget.day}',
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: MouseRegion(
          cursor: widget.disabled
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: SizedBox.square(
              dimension: 40,
              child: ColoredBox(
                color: background,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Text(
                      '${widget.day}',
                      style: CarbonTypeStyles.bodyCompact01.copyWith(
                        color: text,
                      ),
                    ),
                    // The today marker — a small dot beneath the number.
                    if (widget.isToday && !widget.selected)
                      Positioned(
                        bottom: 6,
                        child: SizedBox.square(
                          dimension: 4,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.linkPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
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

/// A Carbon date picker: a field that opens a [CarbonCalendar].
///
/// ```dart
/// CarbonDatePicker(
///   labelText: 'Date',
///   value: _date,
///   onChanged: (DateTime d) => setState(() => _date = d),
/// )
/// ```
class CarbonDatePicker extends StatefulWidget {
  /// Creates a date picker.
  const CarbonDatePicker({
    required this.labelText,
    required this.onChanged,
    super.key,
    this.value,
    this.firstDate,
    this.lastDate,
    this.placeholder = 'mm/dd/yyyy',
    this.size = CarbonFieldSize.md,
    this.disabled = false,
    this.invalid = false,
    this.invalidText,
    this.helperText,
  });

  /// The field label.
  final String labelText;

  /// The selected date.
  final DateTime? value;

  /// Called with the picked date.
  final ValueChanged<DateTime> onChanged;

  /// The earliest selectable date.
  final DateTime? firstDate;

  /// The latest selectable date.
  final DateTime? lastDate;

  /// The placeholder shown when empty.
  final String placeholder;

  /// The field size.
  final CarbonFieldSize size;

  /// Whether disabled.
  final bool disabled;

  /// Whether invalid.
  final bool invalid;

  /// The error message.
  final String? invalidText;

  /// Helper text.
  final String? helperText;

  @override
  State<CarbonDatePicker> createState() => _CarbonDatePickerState();
}

class _CarbonDatePickerState extends State<CarbonDatePicker> {
  bool _open = false;
  final Object _group = UniqueKey();

  String _format(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.day.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final CarbonThemeData theme = CarbonTheme.of(context);
    final bool empty = widget.value == null;
    final Color textColor = widget.disabled
        ? theme.textDisabled
        : empty
        ? theme.textPlaceholder
        : theme.textPrimary;

    final Widget field = CarbonField(
      size: widget.size,
      disabled: widget.disabled,
      status: widget.invalid
          ? CarbonFieldStatus.invalid
          : CarbonFieldStatus.none,
      trailing: Padding(
        padding: const EdgeInsetsDirectional.only(end: CarbonSpacing.spacing05),
        child: CarbonIcon(
          CarbonIcons.calendar,
          color: widget.disabled ? theme.iconDisabled : theme.iconPrimary,
        ),
      ),
      child: ExcludeSemantics(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            empty ? widget.placeholder : _format(widget.value!),
            style: CarbonTypeStyles.bodyCompact01.copyWith(color: textColor),
          ),
        ),
      ),
    );

    final Widget trigger = Semantics(
      button: true,
      label: widget.labelText,
      value: widget.value != null ? _format(widget.value!) : null,
      child: CarbonPopover(
        open: _open,
        align: CarbonPopoverAlignment.bottomStart,
        caret: false,
        tapRegionGroupId: _group,
        onRequestClose: () => setState(() => _open = false),
        content: CarbonCalendar(
          value: widget.value,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          onChanged: (DateTime d) {
            widget.onChanged(d);
            setState(() => _open = false);
          },
        ),
        child: TapRegion(
          groupId: _group,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.disabled
                ? null
                : () => setState(() => _open = !_open),
            child: field,
          ),
        ),
      ),
    );

    final Widget? message = widget.invalid && widget.invalidText != null
        ? CarbonFieldRequirement(widget.invalidText!)
        : widget.helperText != null
        ? CarbonHelperText(widget.helperText!, disabled: widget.disabled)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ExcludeSemantics(
          child: CarbonFormLabel(widget.labelText, disabled: widget.disabled),
        ),
        trigger,
        ?message,
      ],
    );
  }
}
