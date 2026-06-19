// Copyright 2026 Bizjak Tech OÜ
//
// This file is part of the Carbide gallery and is licensed under the GNU
// Affero General Public License v3.0 or later.

import 'package:carbide/carbide.dart';
import 'package:flutter/widgets.dart';

import '../demo_scaffold.dart';
import '../knobs.dart';
import '../registry.dart';

/// Tier A — the foundational components.
final GalleryCategory tierACategory = GalleryCategory(
  title: 'Foundational',
  icon: CarbonIcons.grid,
  entries: <GalleryEntry>[
    GalleryEntry(
      slug: 'button',
      title: 'Button',
      builder: () => const _ButtonPage(),
    ),
    GalleryEntry(
      slug: 'copy-button',
      title: 'Copy button',
      builder: () => const _CopyButtonPage(),
    ),
    GalleryEntry(slug: 'tag', title: 'Tag', builder: () => const _TagPage()),
    GalleryEntry(slug: 'link', title: 'Link', builder: () => const _LinkPage()),
    GalleryEntry(slug: 'tile', title: 'Tile', builder: () => const _TilePage()),
    GalleryEntry(
      slug: 'loading',
      title: 'Loading',
      builder: () => const _LoadingPage(),
    ),
    GalleryEntry(
      slug: 'progress-bar',
      title: 'Progress bar',
      builder: () => const _ProgressBarPage(),
    ),
    GalleryEntry(slug: 'list', title: 'List', builder: () => const _ListPage()),
    GalleryEntry(
      slug: 'stack',
      title: 'Stack',
      builder: () => const _StackPage(),
    ),
    GalleryEntry(
      slug: 'heading',
      title: 'Heading',
      builder: () => const _HeadingPage(),
    ),
  ],
);

class _ButtonPage extends StatefulWidget {
  const _ButtonPage();
  @override
  State<_ButtonPage> createState() => _ButtonPageState();
}

class _ButtonPageState extends State<_ButtonPage> {
  CarbonButtonKind _kind = CarbonButtonKind.primary;
  CarbonButtonSize _size = CarbonButtonSize.lg;
  bool _withIcon = false;
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Button',
      description: 'Eight kinds across six sizes, with an optional icon.',
      preview: CarbonButton(
        label: 'Button',
        kind: _kind,
        size: _size,
        icon: _withIcon ? CarbonIcons.add : null,
        onPressed: _enabled ? () {} : null,
      ),
      controls: <Widget>[
        choiceKnob<CarbonButtonKind>(
          label: 'Kind',
          value: _kind,
          options: CarbonButtonKind.values,
          labelOf: (CarbonButtonKind k) => k.name,
          onChanged: (CarbonButtonKind k) => setState(() => _kind = k),
        ),
        choiceKnob<CarbonButtonSize>(
          label: 'Size',
          value: _size,
          options: CarbonButtonSize.values,
          labelOf: (CarbonButtonSize s) => s.name,
          onChanged: (CarbonButtonSize s) => setState(() => _size = s),
        ),
        boolKnob(
          label: 'With icon',
          value: _withIcon,
          onChanged: (bool v) => setState(() => _withIcon = v),
        ),
        boolKnob(
          label: 'Enabled',
          value: _enabled,
          onChanged: (bool v) => setState(() => _enabled = v),
        ),
      ],
      code:
          "CarbonButton(\n"
          "  label: 'Button',\n"
          '  kind: CarbonButtonKind.${_kind.name},\n'
          '  size: CarbonButtonSize.${_size.name},\n'
          '${_withIcon ? '  icon: CarbonIcons.add,\n' : ''}'
          '  onPressed: ${_enabled ? '() {}' : 'null'},\n'
          ');',
    );
  }
}

class _TagPage extends StatefulWidget {
  const _TagPage();
  @override
  State<_TagPage> createState() => _TagPageState();
}

class _TagPageState extends State<_TagPage> {
  CarbonTagType _type = CarbonTagType.blue;
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Tag',
      description: 'Read-only, dismissible, selectable and operational tags.',
      preview: Wrap(
        spacing: CarbonSpacing.spacing03,
        runSpacing: CarbonSpacing.spacing03,
        children: <Widget>[
          CarbonTag(label: 'Read-only', type: _type, icon: CarbonIcons.user),
          CarbonDismissibleTag(
            label: 'Dismissible',
            type: _type,
            onClose: () {},
          ),
          CarbonSelectableTag(
            label: 'Selectable',
            selected: _selected,
            onChanged: (bool v) => setState(() => _selected = v),
          ),
          CarbonOperationalTag(
            label: 'Operational',
            type: _type,
            onPressed: () {},
          ),
        ],
      ),
      controls: <Widget>[
        choiceKnob<CarbonTagType>(
          label: 'Type',
          value: _type,
          options: CarbonTagType.values,
          labelOf: (CarbonTagType t) => t.name,
          onChanged: (CarbonTagType t) => setState(() => _type = t),
        ),
      ],
      code: "CarbonTag(label: 'Read-only', type: CarbonTagType.${_type.name});",
    );
  }
}

class _LinkPage extends StatefulWidget {
  const _LinkPage();
  @override
  State<_LinkPage> createState() => _LinkPageState();
}

class _LinkPageState extends State<_LinkPage> {
  CarbonLinkSize _size = CarbonLinkSize.md;
  bool _inline = false;
  bool _withIcon = false;
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Link',
      description: 'Inline or standalone navigation, three sizes.',
      preview: CarbonLink(
        label: 'Learn more',
        size: _size,
        inline: _inline,
        icon: _withIcon ? CarbonIcons.launch : null,
        onPressed: _enabled ? () {} : null,
      ),
      controls: <Widget>[
        choiceKnob<CarbonLinkSize>(
          label: 'Size',
          value: _size,
          options: CarbonLinkSize.values,
          labelOf: (CarbonLinkSize s) => s.name,
          onChanged: (CarbonLinkSize s) => setState(() => _size = s),
        ),
        boolKnob(
          label: 'Inline',
          value: _inline,
          onChanged: (bool v) => setState(() => _inline = v),
        ),
        boolKnob(
          label: 'With icon',
          value: _withIcon,
          onChanged: (bool v) => setState(() => _withIcon = v),
        ),
        boolKnob(
          label: 'Enabled',
          value: _enabled,
          onChanged: (bool v) => setState(() => _enabled = v),
        ),
      ],
      code:
          "CarbonLink(label: 'Learn more', size: CarbonLinkSize.${_size.name});",
    );
  }
}

class _TilePage extends StatefulWidget {
  const _TilePage();
  @override
  State<_TilePage> createState() => _TilePageState();
}

class _TilePageState extends State<_TilePage> {
  bool _selected = false;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final CarbonThemeData t = CarbonTheme.of(context);
    Widget body(String s) => Text(
      s,
      style: CarbonTypeStyles.bodyCompact01.copyWith(color: t.textPrimary),
    );
    return DemoScaffold(
      title: 'Tile',
      description: 'Base, clickable, selectable and expandable tiles.',
      previewAlignment: Alignment.topLeft,
      preview: Wrap(
        spacing: CarbonSpacing.spacing05,
        runSpacing: CarbonSpacing.spacing05,
        children: <Widget>[
          SizedBox(width: 220, child: CarbonTile(child: body('Base tile'))),
          SizedBox(
            width: 220,
            child: CarbonClickableTile(
              icon: CarbonIcons.launch,
              onPressed: () {},
              child: body('Clickable tile'),
            ),
          ),
          SizedBox(
            width: 220,
            child: CarbonSelectableTile(
              selected: _selected,
              onChanged: (bool v) => setState(() => _selected = v),
              child: body('Selectable tile'),
            ),
          ),
          SizedBox(
            width: 220,
            child: CarbonExpandableTile(
              expanded: _expanded,
              onExpandedChanged: (bool v) => setState(() => _expanded = v),
              aboveTheFold: body('Expandable tile'),
              belowTheFold: body('Hidden detail revealed on expand.'),
            ),
          ),
        ],
      ),
      code: 'CarbonClickableTile(onPressed: () {}, child: Text(...));',
    );
  }
}

class _LoadingPage extends StatelessWidget {
  const _LoadingPage();
  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Loading',
      description: 'The spinner and inline loading states.',
      preview: Wrap(
        spacing: CarbonSpacing.spacing09,
        runSpacing: CarbonSpacing.spacing07,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: const <Widget>[
          CarbonLoading(),
          CarbonLoading(small: true),
          CarbonInlineLoading(description: 'Loading…'),
          CarbonInlineLoading(
            status: CarbonInlineLoadingStatus.finished,
            description: 'Done',
          ),
        ],
      ),
      code: 'const CarbonLoading();',
    );
  }
}

class _ProgressBarPage extends StatefulWidget {
  const _ProgressBarPage();
  @override
  State<_ProgressBarPage> createState() => _ProgressBarPageState();
}

class _ProgressBarPageState extends State<_ProgressBarPage> {
  double _value = 40;
  bool _indeterminate = false;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Progress bar',
      description: 'Determinate and indeterminate progress.',
      preview: SizedBox(
        width: 320,
        child: CarbonProgressBar(
          label: 'Uploading',
          helperText: _indeterminate ? null : '${_value.round()}%',
          value: _indeterminate ? null : _value,
        ),
      ),
      controls: <Widget>[
        boolKnob(
          label: 'Indeterminate',
          value: _indeterminate,
          onChanged: (bool v) => setState(() => _indeterminate = v),
        ),
        if (!_indeterminate)
          sliderKnob(
            label: 'Value',
            value: _value,
            min: 0,
            max: 100,
            onChanged: (double v) => setState(() => _value = v),
          ),
      ],
      code:
          'CarbonProgressBar(label: \'Uploading\', value: '
          '${_indeterminate ? 'null' : _value.round()});',
    );
  }
}

class _ListPage extends StatelessWidget {
  const _ListPage();
  @override
  Widget build(BuildContext context) {
    final CarbonThemeData t = CarbonTheme.of(context);
    CarbonListItem item(String s) => CarbonListItem(
      child: Text(
        s,
        style: CarbonTypeStyles.body01.copyWith(color: t.textPrimary),
      ),
    );
    return DemoScaffold(
      title: 'List',
      description: 'Ordered and unordered lists, with nesting.',
      previewAlignment: Alignment.topLeft,
      preview: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: CarbonUnorderedList(
              children: <CarbonListItem>[
                item('Apples'),
                item('Oranges'),
                item('Pears'),
              ],
            ),
          ),
          Expanded(
            child: CarbonOrderedList(
              children: <CarbonListItem>[
                item('First'),
                item('Second'),
                item('Third'),
              ],
            ),
          ),
        ],
      ),
      code: 'CarbonUnorderedList(children: <Widget>[CarbonListItem(...)]);',
    );
  }
}

class _StackPage extends StatefulWidget {
  const _StackPage();
  @override
  State<_StackPage> createState() => _StackPageState();
}

class _StackPageState extends State<_StackPage> {
  double _gap = 4;

  @override
  Widget build(BuildContext context) {
    final CarbonThemeData t = CarbonTheme.of(context);
    Widget box(String s) => DecoratedBox(
      decoration: BoxDecoration(color: t.layerAccent01),
      child: Padding(
        padding: const EdgeInsets.all(CarbonSpacing.spacing03),
        child: Text(
          s,
          style: CarbonTypeStyles.bodyCompact01.copyWith(color: t.textPrimary),
        ),
      ),
    );
    return DemoScaffold(
      title: 'Stack',
      description: 'Lays children out with a token-based gap.',
      previewAlignment: Alignment.topLeft,
      preview: CarbonStack(
        gapStep: _gap.round(),
        children: <Widget>[box('One'), box('Two'), box('Three')],
      ),
      controls: <Widget>[
        sliderKnob(
          label: 'Gap step',
          value: _gap,
          min: 1,
          max: 9,
          onChanged: (double v) => setState(() => _gap = v),
        ),
      ],
      code: 'CarbonStack(gapStep: ${_gap.round()}, children: <Widget>[...]);',
    );
  }
}

class _HeadingPage extends StatelessWidget {
  const _HeadingPage();
  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Heading',
      description:
          'Semantic headings whose level comes from the ambient CarbonSection.',
      previewAlignment: Alignment.topLeft,
      preview: const CarbonSection(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CarbonHeading('Level 1 heading'),
            SizedBox(height: CarbonSpacing.spacing05),
            CarbonSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[CarbonHeading('Nested level 2 heading')],
              ),
            ),
          ],
        ),
      ),
      code: 'CarbonSection(child: CarbonHeading(\'Title\'));',
    );
  }
}

class _CopyButtonPage extends StatefulWidget {
  const _CopyButtonPage();
  @override
  State<_CopyButtonPage> createState() => _CopyButtonPageState();
}

class _CopyButtonPageState extends State<_CopyButtonPage> {
  CarbonCopySize _size = CarbonCopySize.md;
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Copy button',
      description:
          'An icon button that copies to the clipboard and shows a brief '
          '"Copied!" confirmation.',
      preview: CarbonCopyButton(
        value: 'npm i @carbon/react',
        size: _size,
        enabled: _enabled,
      ),
      controls: <Widget>[
        choiceKnob<CarbonCopySize>(
          label: 'Size',
          value: _size,
          options: CarbonCopySize.values,
          labelOf: (CarbonCopySize size) => size.name,
          onChanged: (CarbonCopySize size) => setState(() => _size = size),
        ),
        boolKnob(
          label: 'Enabled',
          value: _enabled,
          onChanged: (bool value) => setState(() => _enabled = value),
        ),
      ],
      code: "CarbonCopyButton(value: 'npm i @carbon/react');",
    );
  }
}
