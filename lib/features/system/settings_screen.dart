import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kite_ui/kite_ui.dart';

import '../../core/auth/session.dart';
import '../../core/l10n/labels.dart';
import '../../core/l10n/locale_controller.dart';
import '../../core/preferences/preferences_store.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final l = L.of(context);
    final controller = ref.read(themeProvider.notifier);
    final user = ref.watch(sessionProvider);
    final t = KiteText.of(context);
    final store = ref.watch(preferencesStoreProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KiteSpace.xl),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListenableBuilder(
                listenable: store,
                builder: (context, _) => !store.saveFailed
                    ? const SizedBox.shrink()
                    : Semantics(
                        liveRegion: true,
                        child: Column(
                          children: [
                            Text(l.preferenceSaveFailed),
                            KiteButton.ghost(
                              onPressed: store.retry,
                              child: Text(l.errorRetry),
                            ),
                          ],
                        ),
                      ),
              ),
              KiteCard(
                title: l.appearance,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.theme,
                      style: t.small.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: KiteSpace.sm),
                    Wrap(
                      spacing: KiteSpace.sm,
                      runSpacing: KiteSpace.sm,
                      children: [
                        for (final mode in ThemeMode.values)
                          ChoiceChip(
                            label: Text(switch (mode) {
                              ThemeMode.light => l.light,
                              ThemeMode.dark => l.dark,
                              ThemeMode.system => l.systemMode,
                            }),
                            selected: theme.mode == mode,
                            onSelected: (_) => controller.setMode(mode),
                          ),
                      ],
                    ),
                    const SizedBox(height: KiteSpace.xl),
                    Text(
                      l.accent,
                      style: t.small.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: KiteSpace.sm),
                    Wrap(
                      spacing: KiteSpace.sm,
                      children: [
                        for (final a in KiteAccent.values)
                          ChoiceChip(
                            label: Text(switch (a) {
                              KiteAccent.slate => l.accentSlate,
                              KiteAccent.blue => l.accentBlue,
                              KiteAccent.violet => l.accentViolet,
                            }),
                            selected: theme.accent == a,
                            onSelected: (_) => controller.setAccent(a),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KiteSpace.xl),
              KiteCard(
                title: l.language,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l.languageHelp, style: t.muted),
                    const SizedBox(height: KiteSpace.lg),
                    Wrap(
                      spacing: KiteSpace.sm,
                      runSpacing: KiteSpace.sm,
                      children: [
                        for (final option in KiteLocale.values)
                          ChoiceChip(
                            label: Text(option.nativeName),
                            selected: locale == option,
                            onSelected: (_) =>
                                ref.read(localeProvider.notifier).set(option),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KiteSpace.xl),
              KiteCard(
                title: l.account,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Row(label: l.fieldName, value: user?.name ?? '—'),
                    _Row(label: l.fieldEmail, value: user?.email ?? '—'),
                    _Row(
                      label: l.role,
                      value: roleLabel(l, user?.role ?? UserRole.none),
                    ),
                    const SizedBox(height: KiteSpace.lg),
                    KiteButton.destructive(
                      onPressed: () =>
                          ref.read(sessionProvider.notifier).signOut(),
                      child: Text(l.actionSignOut),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KiteSpace.xl),
              KiteCard(
                title: l.dataSource,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(l.dataSourceHelp, style: t.muted)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: t.muted)),
          Expanded(child: Text(value, style: t.p.copyWith(fontSize: 14))),
        ],
      ),
    );
  }
}
