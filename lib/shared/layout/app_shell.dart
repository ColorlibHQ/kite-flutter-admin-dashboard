import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/session.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../kite_ui/kite_ui.dart';
import '../../l10n/app_localizations.dart';

/// The persistent shell.
///
/// Desktop gets a sidebar; mobile gets a bottom bar and a drawer. This is the
/// "mobile is not a reflow" rule made concrete — the small-screen layout is a
/// different arrangement, not the desktop one squeezed. See docs/ARCHITECTURE.md.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = KiteColors.of(context);
    final mobile = KiteBreak.isMobile(context);

    return Scaffold(
      backgroundColor: c.background,
      drawer: mobile ? Drawer(child: _SidebarBody(location: location)) : null,
      bottomNavigationBar: mobile ? _BottomBar(location: location) : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!mobile)
              SizedBox(
                width: 248,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.card,
                    // Directional: in RTL the sidebar moves to the right edge, so its
                    // divider has to move with it.
                    border: BorderDirectional(end: BorderSide(color: c.border)),
                  ),
                  child: _SidebarBody(location: location),
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  _TopBar(location: location, mobile: mobile),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarBody extends StatelessWidget {
  const _SidebarBody({required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KiteSpace.xl,
            KiteSpace.xl,
            KiteSpace.xl,
            KiteSpace.lg,
          ),
          child: Row(
            children: [
              Icon(Icons.change_history, size: 20, color: c.primary),
              const SizedBox(width: KiteSpace.sm),
              Text('Kite', style: t.h4),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: KiteSpace.md),
            children: [
              for (final group in kNavGroups) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    KiteSpace.md,
                    KiteSpace.lg,
                    KiteSpace.md,
                    KiteSpace.xs,
                  ),
                  child: Text(
                    group.labelOf(L.of(context)).toUpperCase(),
                    style: t.muted.copyWith(
                      fontSize: 10,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                for (final item in group.items)
                  _NavTile(item: item, active: location == item.path),
              ],
            ],
          ),
        ),
        const Divider(height: 1),
        const _UserTile(),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.item, required this.active});
  final NavItem item;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: active ? c.accent : Colors.transparent,
        borderRadius: KiteRadius.allSm,
        child: InkWell(
          borderRadius: KiteRadius.allSm,
          onTap: () => context.go(item.path),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KiteSpace.md,
              vertical: 10,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: active ? c.foreground : c.mutedForeground,
                ),
                const SizedBox(width: KiteSpace.md),
                Text(
                  item.labelOf(L.of(context)),
                  style: t.small.copyWith(
                    color: active ? c.foreground : c.mutedForeground,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserTile extends ConsumerWidget {
  const _UserTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    if (user == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(KiteSpace.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.muted, shape: BoxShape.circle),
            child: Text(user.initials, style: t.small.copyWith(fontSize: 12)),
          ),
          const SizedBox(width: KiteSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: t.small,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user.role,
                  style: t.muted.copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: L.of(context).actionSignOut,
            iconSize: 18,
            color: c.mutedForeground,
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar({required this.location, required this.mobile});
  final String location;
  final bool mobile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    // Longest-prefix match, not equality: /orders/10004/edit still belongs to
    // Orders. Exact matching left every nested route titled "Kite".
    final matches = [
      for (final n in kNav)
        if (location == n.path ||
            (n.path != '/' && location.startsWith('${n.path}/')))
          n,
    ]..sort((a, b) => b.path.length.compareTo(a.path.length));
    final title = matches.isEmpty
        ? 'Kite'
        : matches.first.labelOf(L.of(context));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: KiteSpace.xl),
      decoration: BoxDecoration(
        color: c.card,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          if (mobile)
            IconButton(
              icon: const Icon(Icons.menu),
              color: c.mutedForeground,
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          Text(title, style: t.large),
          const Spacer(),
          IconButton(
            tooltip: isDark ? L.of(context).lightMode : L.of(context).darkMode,
            iconSize: 18,
            color: c.mutedForeground,
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            onPressed: () =>
                ref.read(themeProvider.notifier).toggleBrightness(context),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    // Four destinations on mobile, not six — the rest live in the drawer.
    final items = kNav.take(4).toList();
    var index = items.indexWhere((n) => n.path == location);
    if (index < 0) index = 0;

    return NavigationBar(
      backgroundColor: c.card,
      selectedIndex: index,
      onDestinationSelected: (i) => context.go(items[i].path),
      destinations: [
        for (final n in items)
          NavigationDestination(icon: Icon(n.icon, size: 20), label: n.label),
      ],
    );
  }
}
