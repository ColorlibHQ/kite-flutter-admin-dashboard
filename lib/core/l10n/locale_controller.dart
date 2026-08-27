import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The locales this template ships translations for.
///
/// Arabic is here on purpose: it is the cheapest way to keep the layout honest.
/// A UI that has never rendered right-to-left is full of hard-coded `left:`
/// padding nobody noticed.
enum KiteLocale {
  en('English', 'English'),
  es('Spanish', 'Español'),
  fr('French', 'Français'),
  ja('Japanese', '日本語'),
  ar('Arabic', 'العربية');

  const KiteLocale(this.englishName, this.nativeName);

  final String englishName;
  final String nativeName;

  Locale get locale => Locale(name);

  bool get isRtl => this == KiteLocale.ar;
}

class LocaleController extends Notifier<KiteLocale> {
  @override
  KiteLocale build() => KiteLocale.en;

  void set(KiteLocale value) => state = value;
}

final localeProvider = NotifierProvider<LocaleController, KiteLocale>(
  LocaleController.new,
);
