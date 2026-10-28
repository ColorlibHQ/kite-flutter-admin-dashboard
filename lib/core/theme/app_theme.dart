import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kite_ui/shadcn.dart';

import '../preferences/preferences_store.dart';

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

  ShadThemeData data(Brightness b) {
    final dark = b == Brightness.dark;
    final base = accent.scheme(b);
    // Colored text on dark surfaces and text on filled buttons both need
    // readable contrast. Use a lighter dark-mode accent with dark button text.
    final primary = dark
        ? switch (accent) {
            KiteAccent.blue => const Color(0xff60a5fa),
            KiteAccent.violet => const Color(0xffa78bfa),
            KiteAccent.slate => base.primary,
          }
        : base.primary;
    return ShadThemeData(
      brightness: b,
      colorScheme: base.copyWith(
        primary: primary,
        primaryForeground: dark && accent != KiteAccent.slate
            ? const Color(0xff030712)
            : base.primaryForeground,
        destructive: dark ? const Color(0xfff87171) : const Color(0xffdc2626),
        destructiveForeground: dark
            ? const Color(0xff030712)
            : const Color(0xffffffff),
      ),
    );
  }
}

class ThemeController extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    final store = ref.read(preferencesStoreProvider);
    return ThemeState(
      mode: ThemeMode.values.firstWhere(
        (m) => m.name == store.read('theme.mode'),
        orElse: () => ThemeMode.system,
      ),
      accent: KiteAccent.values.firstWhere(
        (a) => a.name == store.read('theme.accent'),
        orElse: () => KiteAccent.slate,
      ),
    );
  }

  void setMode(ThemeMode m) {
    state = state.copyWith(mode: m);
    ref.read(preferencesStoreProvider).set('theme.mode', m.name);
  }

  void setAccent(KiteAccent a) {
    state = state.copyWith(accent: a);
    ref.read(preferencesStoreProvider).set('theme.accent', a.name);
  }

  void toggleBrightness(BuildContext context) {
    final resolved = state.mode == ThemeMode.system
        ? MediaQuery.platformBrightnessOf(context)
        : (state.mode == ThemeMode.dark ? Brightness.dark : Brightness.light);
    setMode(resolved == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
  }
}

final themeProvider = NotifierProvider<ThemeController, ThemeState>(
  ThemeController.new,
);
