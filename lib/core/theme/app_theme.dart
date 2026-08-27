import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kite_ui/shadcn.dart';

/// Accents. Three is deliberate: enough to prove the theming is real, few
/// enough that every one is checked in both brightnesses before release.
enum KiteAccent {
  slate('Slate'),
  blue('Blue'),
  violet('Violet');

  const KiteAccent(this.label);
  final String label;

  ShadColorScheme scheme(Brightness b) => switch ((this, b)) {
    (KiteAccent.slate, Brightness.light) => const ShadSlateColorScheme.light(),
    (KiteAccent.slate, Brightness.dark) => const ShadSlateColorScheme.dark(),
    (KiteAccent.blue, Brightness.light) => const ShadBlueColorScheme.light(),
    (KiteAccent.blue, Brightness.dark) => const ShadBlueColorScheme.dark(),
    (KiteAccent.violet, Brightness.light) =>
      const ShadVioletColorScheme.light(),
    (KiteAccent.violet, Brightness.dark) => const ShadVioletColorScheme.dark(),
  };
}

@immutable
class ThemeState {
  const ThemeState({
    this.mode = ThemeMode.system,
    this.accent = KiteAccent.slate,
  });

  final ThemeMode mode;
  final KiteAccent accent;

  ThemeState copyWith({ThemeMode? mode, KiteAccent? accent}) =>
      ThemeState(mode: mode ?? this.mode, accent: accent ?? this.accent);

  ShadThemeData data(Brightness b) =>
      ShadThemeData(brightness: b, colorScheme: accent.scheme(b));
}

class ThemeController extends Notifier<ThemeState> {
  @override
  ThemeState build() => const ThemeState();

  void setMode(ThemeMode m) => state = state.copyWith(mode: m);
  void setAccent(KiteAccent a) => state = state.copyWith(accent: a);

  void toggleBrightness(BuildContext context) {
    final resolved = state.mode == ThemeMode.system
        ? MediaQuery.platformBrightnessOf(context)
        : (state.mode == ThemeMode.dark ? Brightness.dark : Brightness.light);
    state = state.copyWith(
      mode: resolved == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }
}

final themeProvider = NotifierProvider<ThemeController, ThemeState>(
  ThemeController.new,
);
