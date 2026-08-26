import 'package:flutter/widgets.dart';

import '_shadcn.dart';

/// Spacing scale. Every gap in the app comes from here, so density can be
/// retuned in one place rather than hunted through widgets.
abstract final class KiteSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class KiteRadius {
  static const Radius sm = Radius.circular(6);
  static const Radius md = Radius.circular(8);
  static const Radius lg = Radius.circular(12);

  static const BorderRadius allSm = BorderRadius.all(sm);
  static const BorderRadius allMd = BorderRadius.all(md);
  static const BorderRadius allLg = BorderRadius.all(lg);
}

/// Breakpoints. Mobile is a different layout, not a squeezed desktop one —
/// see docs/ARCHITECTURE.md.
abstract final class KiteBreak {
  static const double mobile = 640;
  static const double tablet = 1024;

  static bool isMobile(BuildContext c) => MediaQuery.sizeOf(c).width < mobile;
  static bool isTablet(BuildContext c) {
    final w = MediaQuery.sizeOf(c).width;
    return w >= mobile && w < tablet;
  }

  static bool isDesktop(BuildContext c) => MediaQuery.sizeOf(c).width >= tablet;
}

/// Colour facade.
///
/// Features read colours from here, never from `ShadTheme`. That is what keeps
/// the design library swappable — if the palette type changes, this class
/// absorbs it and no feature code moves.
extension type KiteColors._(ShadColorScheme _cs) {
  factory KiteColors.of(BuildContext context) =>
      KiteColors._(ShadTheme.of(context).colorScheme);

  Color get background => _cs.background;
  Color get foreground => _cs.foreground;
  Color get card => _cs.card;
  Color get cardForeground => _cs.cardForeground;
  Color get border => _cs.border;
  Color get input => _cs.input;
  Color get primary => _cs.primary;
  Color get primaryForeground => _cs.primaryForeground;
  Color get secondary => _cs.secondary;
  Color get muted => _cs.muted;
  Color get mutedForeground => _cs.mutedForeground;
  Color get accent => _cs.accent;
  Color get destructive => _cs.destructive;
  Color get ring => _cs.ring;
}

/// Text facade, same reasoning as [KiteColors].
extension type KiteText._(ShadTextTheme _t) {
  factory KiteText.of(BuildContext context) =>
      KiteText._(ShadTheme.of(context).textTheme);

  TextStyle get h1 => _t.h1;
  TextStyle get h2 => _t.h2;
  TextStyle get h3 => _t.h3;
  TextStyle get h4 => _t.h4;
  TextStyle get p => _t.p;
  TextStyle get lead => _t.lead;
  TextStyle get large => _t.large;
  TextStyle get small => _t.small;
  TextStyle get muted => _t.muted;
}
