import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/session.dart';
import '../../core/theme/app_theme.dart';
import '../../kite_ui/kite_ui.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final controller = ref.read(themeProvider.notifier);
    final user = ref.watch(sessionProvider);
    final t = KiteText.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KiteSpace.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KiteCard(
              title: 'Appearance',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: t.small.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: KiteSpace.sm),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('System'),
                      ),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                    ],
                    selected: {theme.mode},
                    onSelectionChanged: (s) => controller.setMode(s.first),
                  ),
                  const SizedBox(height: KiteSpace.xl),
                  Text(
                    'Accent',
                    style: t.small.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: KiteSpace.sm),
                  Wrap(
                    spacing: KiteSpace.sm,
                    children: [
                      for (final a in KiteAccent.values)
                        ChoiceChip(
                          label: Text(a.label),
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
              title: 'Account',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Row(label: 'Name', value: user?.name ?? '—'),
                  _Row(label: 'Email', value: user?.email ?? '—'),
                  _Row(label: 'Role', value: user?.role ?? '—'),
                  const SizedBox(height: KiteSpace.lg),
                  KiteButton.destructive(
                    onPressed: () =>
                        ref.read(sessionProvider.notifier).signOut(),
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: KiteSpace.xl),
            KiteCard(
              title: 'Data source',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Running on MockDataProvider — search, filter, sort and '
                    'pagination all execute server-side against in-memory '
                    'tables. Swap one line in mock_data_provider.dart for a '
                    'REST or Supabase adapter and every screen keeps working.',
                    style: t.muted,
                  ),
                ],
              ),
            ),
          ],
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
