import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'kite_ui/_shadcn.dart';

class KiteApp extends ConsumerWidget {
  const KiteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return ShadApp.router(
      title: 'Kite',
      themeMode: theme.mode,
      theme: theme.data(Brightness.light),
      darkTheme: theme.data(Brightness.dark),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
