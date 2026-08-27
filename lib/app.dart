import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kite_ui/shadcn.dart';

import 'core/l10n/locale_controller.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class KiteApp extends ConsumerWidget {
  const KiteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    return ShadApp.router(
      title: 'Kite',
      themeMode: theme.mode,
      theme: theme.data(Brightness.light),
      darkTheme: theme.data(Brightness.dark),
      locale: locale.locale,
      supportedLocales: L.supportedLocales,
      localizationsDelegates: L.localizationsDelegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
