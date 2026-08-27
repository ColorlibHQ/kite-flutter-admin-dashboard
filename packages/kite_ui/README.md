# kite_ui

Dashboard widgets for Flutter admin panels — the UI layer extracted from the
[Kite admin dashboard template](https://github.com/ColorlibHQ/kite-flutter-admin-dashboard),
where it is in use across 22 screens.

Built on [shadcn_ui](https://pub.dev/packages/shadcn_ui). The point of the
layer is that your screens never name it: swapping the design library is a
change inside this package, not a rewrite of your app.

[**Live demo**](https://demo.dashboardpack.com/kite/) ·
[**Documentation**](https://docs.dashboardpack.com/kite-docs/)

## Install

```yaml
dependencies:
  kite_ui: ^0.1.0
```

Wrap your app in a `ShadApp` (re-exported, so you do not need shadcn_ui in your
own pubspec):

```dart
import 'package:kite_ui/kite_ui.dart';
import 'package:kite_ui/shadcn.dart';

void main() => runApp(
      ShadApp(
        theme: ShadThemeData(
          colorScheme: const ShadSlateColorScheme.light(),
          brightness: Brightness.light,
        ),
        home: const Dashboard(),
      ),
    );
```

## The grid that started this package

The obvious way to lay out stat cards is `GridView.count` with a
`childAspectRatio`, and it is the wrong one: aspect ratio ties height to width,
so on a wide monitor the cards grow tall and the dashboard stops looking like a
dashboard. `KiteStatGrid` takes an explicit `height` and wraps on a minimum tile
width instead.

```dart
KiteStatGrid(
  height: 200,
  minTileWidth: 220,
  children: [
    KiteCard(child: Text('Revenue')),
    KiteCard(child: Text('Orders')),
  ],
)
```

## What is in it

| | |
|---|---|
| Layout | `KiteStatGrid`, `KiteCard`, `KiteSpace`, `KiteRadius`, `KiteBreak` |
| Charts | `KiteChart`, `KiteSparkline`, `KiteDonut` |
| Data | `KiteDataTable` (trina_grid, server-side pagination hooks) |
| Controls | `KiteButton`, `KiteMenu`, inputs, `KiteBadge` |
| Feedback | toasts, empty states, skeletons |
| Theme | `KiteColors` and `KiteText` — zero-cost facades over `ShadTheme` |
| Format | `KiteFormat` number, currency, compact and date helpers |

## Theme access

`KiteColors` and `KiteText` are `extension type` wrappers, so reading a colour
costs nothing at runtime and your widgets never touch `ShadTheme` directly:

```dart
final c = KiteColors.of(context);
final t = KiteText.of(context);

Container(color: c.background, child: Text('Revenue', style: t.h4));
```

## Licence

MIT. See [LICENSE](LICENSE).
