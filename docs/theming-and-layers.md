# Theming & layers

Carbide styling is entirely token-driven. A `CarbonThemeData` resolves Carbon's
semantic tokens (background, text, layer, field, border, support, …) onto the
raw palette for one theme; components read those tokens through `CarbonTheme`.

## The four themes

Carbon defines four themes, two light and two dark. Each is a named constructor
on `CarbonThemeData`:

| Theme      | Brightness | Constructor               |
| ---------- | ---------- | ------------------------- |
| White      | light      | `CarbonThemeData.white`   |
| Gray 10    | light      | `CarbonThemeData.gray10`  |
| Gray 90    | dark       | `CarbonThemeData.gray90`  |
| Gray 100   | dark       | `CarbonThemeData.gray100` |

All four expose the same token names, so a component written against the tokens
looks correct in every theme without change.

```dart
CarbonTheme(
  data: CarbonThemeData.gray100,
  child: const MyApp(),
);
```

### Reading tokens

```dart
final theme = CarbonTheme.of(context);
final bg = theme.background;      // page background
final text = theme.textPrimary;   // primary text color
```

Use `CarbonTheme.maybeOf(context)` when a theme may be absent. The full token
set is documented on `CarbonThemeData` in the API reference.

## Animating theme changes

`AnimatedCarbonTheme` is an implicitly-animated `CarbonTheme`: when its `data`
changes it lerps every token to the new theme over the given `duration`, so a
light↔dark switch crossfades instead of snapping.

```dart
AnimatedCarbonTheme(
  data: isDark ? CarbonThemeData.gray100 : CarbonThemeData.white,
  duration: const Duration(milliseconds: 150),
  curve: Curves.easeInOut,
  child: const MyApp(),
);
```

Drive `isDark` from whatever state you keep (a `ValueNotifier`, a
`ChangeNotifier`, etc.) and rebuild — the animation is automatic.

## Layers

Carbon's contextual layering model keeps stacked surfaces — a card on the page,
a card inside that card, a modal over content — visually distinct. Each layer
re-points the contextual tokens (`layer`, `field`, the subtle borders, and their
hover/active/selected variants) one step further from the page background.

Wrap a subtree in `CarbonLayer` to move it up one layer:

```dart
CarbonLayer(
  child: MyCard(),
);
```

Layers are numbered `CarbonLayer.minLevel` (0, the implicit level of root
content) through `CarbonLayer.maxLevel` (2) — Carbon's layer-01 through
layer-03. Nesting beyond the maximum simply stays at the top layer.

- **Increment (default):** `CarbonLayer(child: …)` steps one level up from the
  ancestor.
- **Explicit level:** `CarbonLayer(level: 2, child: …)` pins a specific level.
- **Paint the background:** `CarbonLayer(withBackground: true, child: …)` fills
  the layer's `layerBackground` token behind the child, matching the upstream
  `withBackground` behavior.

### Reading the active layer

Inside a `CarbonLayer`, resolve the layer-aware tokens with `CarbonLayer.of`:

```dart
final tokens = CarbonLayer.of(context);
return ColoredBox(color: tokens.layer, child: ...);
```

`CarbonLayer.levelOf(context)` returns just the current level (without resolving
tokens), which is `minLevel` when there is no `CarbonLayer` ancestor.

## See also

- [Getting started](getting-started.md)
- [Architecture](ARCHITECTURE.md) — how foundations, theme, and components layer
  up internally.
