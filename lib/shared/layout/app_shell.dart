import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/session.dart';
import '../../core/l10n/locale_controller.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../features/search/command_palette.dart';
import '../../kite_ui/kite_ui.dart';
import '../../l10n/app_localizations.dart';
import 'promo_card.dart';

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

    // ⌘K on macOS, Ctrl+K elsewhere. Bound on the shell rather than per
    // screen, so it works from anywhere behind the auth guard.
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () =>
            showCommandPalette(context),
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () =>
            showCommandPalette(context),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: c.background,
          drawer: mobile
              ? Drawer(child: _SidebarBody(location: location))
              : null,
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
                        border: BorderDirectional(
                          end: BorderSide(color: c.border),
                        ),
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
        // Pinned above the user tile rather than at the end of the scrolling
        // nav list, where it sat below the fold on a laptop and was the first
        // thing clipped. Nav scrolls independently above it.
        if (kShowPromo) const PromoCard(),
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
    final l = L.of(context);
    // Longest-prefix match, not equality: /orders/10004/edit still belongs to
    // Orders. Exact matching left every nested route titled "Kite".
    final matches = [
      for (final n in kNav)
        if (location == n.path ||
            (n.path != '/' && location.startsWith('${n.path}/')))
          n,
    ]..sort((a, b) => b.path.length.compareTo(a.path.length));
    final title = matches.isEmpty ? 'Kite' : matches.first.labelOf(l);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wide = KiteBreak.isDesktop(context);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: KiteSpace.xl),
      decoration: BoxDecoration(
        color: c.card,
        border: BorderDirectional(bottom: BorderSide(color: c.border)),
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
          if (wide) ...[
            const _SearchTrigger(),
            const SizedBox(width: KiteSpace.md),
          ],
          const _NotificationsButton(),
          const SizedBox(width: KiteSpace.xs),
          KiteTooltip(
            message: isDark ? l.lightMode : l.darkMode,
            child: IconButton(
              iconSize: 18,
              color: c.mutedForeground,
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
              onPressed: () =>
                  ref.read(themeProvider.notifier).toggleBrightness(context),
            ),
          ),
          const SizedBox(width: KiteSpace.sm),
          const _AccountMenu(),
        ],
      ),
    );
  }
}

/// A search affordance rather than a search field.
///
/// The bar is 60px tall and shared by every screen; a live input here would
/// compete with the one each list already has. This opens the same command
/// palette the keyboard shortcut does.
class _SearchTrigger extends StatelessWidget {
  const _SearchTrigger();

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Material(
      color: c.background,
      borderRadius: KiteRadius.allSm,
      child: InkWell(
        borderRadius: KiteRadius.allSm,
        onTap: () => showCommandPalette(context),
        child: Container(
          width: 240,
          padding: const EdgeInsets.symmetric(
            horizontal: KiteSpace.md,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: c.border),
            borderRadius: KiteRadius.allSm,
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 15, color: c.mutedForeground),
              const SizedBox(width: KiteSpace.sm),
              Expanded(
                child: Text('Search…', style: t.muted.copyWith(fontSize: 13)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: c.muted,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('⌘K', style: t.muted.copyWith(fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton();

  static const _items = <(String, String, KiteTone)>[
    ('Payment gateway unreachable', '2m', KiteTone.danger),
    ('3 products below reorder point', '18m', KiteTone.warning),
    ('Ada Lovelace refunded #10265', '1h', KiteTone.info),
    ('Sprint 14 burndown on track', '4h', KiteTone.success),
  ];

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    return KiteMenu(
      width: 320,
      header: Padding(
        padding: const EdgeInsets.fromLTRB(
          KiteSpace.sm,
          KiteSpace.xs,
          KiteSpace.sm,
          0,
        ),
        child: Row(
          children: [
            Text(
              'Notifications',
              style: t.small.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            KiteBadge('${_items.length} new', tone: KiteTone.info),
          ],
        ),
      ),
      items: [
        for (final (text, ago, tone) in _items)
          KiteMenuItem(
            label: text,
            trailing: ago,
            icon: switch (tone) {
              KiteTone.danger => Icons.error_outline,
              KiteTone.warning => Icons.warning_amber_outlined,
              KiteTone.success => Icons.check_circle_outline,
              _ => Icons.info_outline,
            },
            onPressed: () {},
          ),
        const KiteMenuItem.separator(),
        KiteMenuItem(
          label: 'Mark all as read',
          icon: Icons.done_all,
          onPressed: () => KiteToast.show(context, title: 'All caught up'),
        ),
      ],
      trigger: (context, open) => KiteTooltip(
        message: 'Notifications',
        child: Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              iconSize: 18,
              color: c.mutedForeground,
              icon: const Icon(Icons.notifications_none),
              onPressed: open,
            ),
            // Count in a badge, not just a dot — "how many" is the question.
            PositionedDirectional(
              top: 6,
              end: 6,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(minWidth: 15),
                  decoration: BoxDecoration(
                    color: c.destructive,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: c.card, width: 1.5),
                  ),
                  child: Text(
                    '${_items.length}',
                    textAlign: TextAlign.center,
                    style: t.small.copyWith(
                      fontSize: 9,
                      height: 1.5,
                      color: c.background,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountMenu extends ConsumerWidget {
  const _AccountMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final locale = ref.watch(localeProvider);
    final theme = ref.watch(themeProvider);
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final l = L.of(context);

    return KiteMenu(
      width: 248,
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: KiteSpace.sm),
        child: Row(
          children: [
            KiteAvatar(name: user?.name ?? 'Admin', size: 34),
            const SizedBox(width: KiteSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Admin',
                    overflow: TextOverflow.ellipsis,
                    style: t.small.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    user?.email ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: t.muted.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      items: [
        KiteMenuItem(
          label: l.navProfile,
          icon: Icons.person_outline,
          onPressed: () => context.go(R.profile),
        ),
        KiteMenuItem(
          label: l.navSettings,
          icon: Icons.settings_outlined,
          onPressed: () => context.go(R.settings),
        ),
        KiteMenuItem(
          label: l.theme,
          icon: Icons.palette_outlined,
          trailing: theme.accent.label,
          onPressed: () => context.go(R.settings),
        ),
        KiteMenuItem(
          label: l.language,
          icon: Icons.translate,
          trailing: locale.nativeName,
          onPressed: () => context.go(R.settings),
        ),
        const KiteMenuItem.separator(),
        KiteMenuItem(
          label: 'Keyboard shortcuts',
          icon: Icons.keyboard_outlined,
          trailing: '⌘/',
          onPressed: () => KiteToast.show(
            context,
            title: 'Shortcuts',
            description: 'Add your own bindings in app_shell.dart.',
          ),
        ),
        const KiteMenuItem.separator(),
        KiteMenuItem(
          label: l.actionSignOut,
          icon: Icons.logout,
          destructive: true,
          onPressed: () => ref.read(sessionProvider.notifier).signOut(),
        ),
      ],
      trigger: (context, open) => InkWell(
        borderRadius: KiteRadius.allSm,
        onTap: open,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              KiteAvatar(name: user?.name ?? 'Admin', size: 28),
              const SizedBox(width: KiteSpace.xs),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: c.mutedForeground,
              ),
            ],
          ),
        ),
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
