import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/session.dart';
import '../../core/data/data_provider.dart';
import '../../core/data/mock_data_provider.dart';
import '../../core/router/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../kite_ui/kite_ui.dart';
import '../../l10n/app_localizations.dart';

@immutable
class CommandResult {
  const CommandResult({
    required this.label,
    required this.group,
    required this.icon,
    required this.onSelect,
    this.detail,
  });

  final String label;
  final String group;
  final IconData icon;
  final String? detail;
  final VoidCallback onSelect;
}

/// Opens the palette. Returns when it closes.
Future<void> showCommandPalette(BuildContext context) => showDialog<void>(
  context: context,
  barrierColor: const Color(0x66000000),
  builder: (_) => const _CommandPalette(),
);

/// A command palette that searches the real data.
///
/// Pages come from the same `kNav` the sidebar uses, so the two can never
/// disagree. Records come through the `DataProvider` — the palette is a
/// consumer of the data layer like any screen, which means pointing the app at
/// a REST backend makes search hit that backend with no work here.
class _CommandPalette extends ConsumerStatefulWidget {
  const _CommandPalette();

  @override
  ConsumerState<_CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends ConsumerState<_CommandPalette> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  /// Keys are handled on the *field's* node, not an ancestor.
  ///
  /// An ancestor `Focus(autofocus: true)` wins the focus outright and the
  /// TextField never receives characters — the palette opens and cannot be
  /// typed into. Handling here also runs before the text editing actions, so
  /// Up/Down move the selection instead of the caret.
  late final FocusNode _focus = FocusNode(onKeyEvent: _handleKey);

  /// The list as of the last build, for the key handler to act on.
  List<CommandResult> _results = const [];

  Timer? _debounce;
  List<CommandResult> _records = const [];
  bool _searching = false;
  int _active = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller
      ..removeListener(_onQueryChanged)
      ..dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    setState(() => _active = 0);
    _debounce?.cancel();
    final q = _controller.text.trim();
    if (q.length < 2) {
      setState(() {
        _records = const [];
        _searching = false;
      });
      return;
    }
    // Debounced: typing "customer" should not fire eight queries.
    setState(() => _searching = true);
    _debounce = Timer(const Duration(milliseconds: 220), () => _search(q));
  }

  Future<void> _search(String query) async {
    final provider = ref.read(dataProvider);
    final found = <CommandResult>[];

    for (final resource in const ['orders', 'customers', 'products']) {
      try {
        final result = await provider.getList(
          resource,
          ListParams(search: query, perPage: 4),
        );
        final spec = _labels[resource]!;
        for (final row in result.rows) {
          found.add(
            CommandResult(
              label: '${row[spec.$2]}',
              group: spec.$1,
              icon: spec.$3,
              detail: spec.$4 == null ? null : '${row[spec.$4]}',
              onSelect: () => context.go('/$resource/${row['id']}'),
            ),
          );
        }
      } on DataProviderException {
        // A resource that is unavailable should not blank the whole palette.
        continue;
      }
    }

    if (!mounted) return;
    setState(() {
      _records = found;
      _searching = false;
    });
  }

  static const _labels =
      <String, (String group, String title, IconData icon, String? detail)>{
        'orders': (
          'Orders',
          'reference',
          Icons.receipt_long_outlined,
          'customer',
        ),
        'customers': ('Customers', 'name', Icons.people_outline, 'email'),
        'products': ('Products', 'name', Icons.inventory_2_outlined, 'sku'),
      };

  List<CommandResult> _pages(L l) {
    final q = _controller.text.trim().toLowerCase();
    return [
      for (final item in kNav)
        if (q.isEmpty || item.labelOf(l).toLowerCase().contains(q))
          CommandResult(
            label: item.labelOf(l),
            group: 'Pages',
            icon: item.icon,
            onSelect: () => context.go(item.path),
          ),
    ];
  }

  List<CommandResult> _actions(L l) {
    final q = _controller.text.trim().toLowerCase();
    final all = [
      CommandResult(
        label: l.darkMode,
        group: 'Actions',
        icon: Icons.dark_mode_outlined,
        onSelect: () =>
            ref.read(themeProvider.notifier).toggleBrightness(context),
      ),
      CommandResult(
        label: 'New order',
        group: 'Actions',
        icon: Icons.add,
        onSelect: () => context.go('/orders/new'),
      ),
      CommandResult(
        label: 'New product',
        group: 'Actions',
        icon: Icons.add,
        onSelect: () => context.go('/products/new'),
      ),
      CommandResult(
        label: l.actionSignOut,
        group: 'Actions',
        icon: Icons.logout,
        onSelect: () => ref.read(sessionProvider.notifier).signOut(),
      ),
    ];
    return [
      for (final a in all)
        if (q.isEmpty || a.label.toLowerCase().contains(q)) a,
    ];
  }

  void _move(int delta, int total) {
    if (total == 0) return;
    setState(() => _active = (_active + delta) % total);
    // Keep the highlighted row on screen when arrowing past the fold.
    if (_scroll.hasClients) {
      final target = (_active * 44.0) - 88;
      _scroll.animateTo(
        target.clamp(0, _scroll.position.maxScrollExtent),
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
      );
    }
  }

  void _run(CommandResult r) {
    Navigator.of(context).pop();
    r.onSelect();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        _move(1, _results.length);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        _move(-1, _results.length);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
        if (_results.isNotEmpty) _run(_results[_active]);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        Navigator.of(context).pop();
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final l = L.of(context);

    final results = [..._pages(l), ..._records, ..._actions(l)];
    _results = results;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: KiteSpace.xl,
        vertical: 96,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Container(
            decoration: BoxDecoration(
              color: c.card,
              border: Border.all(color: c.border),
              borderRadius: KiteRadius.allLg,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 32,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Field(
                  controller: _controller,
                  focusNode: _focus,
                  searching: _searching,
                ),
                const KiteSeparator(),
                if (results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(KiteSpace.xxl),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 26,
                          color: c.mutedForeground,
                        ),
                        const SizedBox(height: KiteSpace.md),
                        Text(
                          'Nothing matches "${_controller.text.trim()}"',
                          style: t.muted,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      controller: _scroll,
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                        vertical: KiteSpace.sm,
                      ),
                      itemCount: results.length,
                      itemBuilder: (context, i) {
                        final r = results[i];
                        final newGroup =
                            i == 0 || results[i - 1].group != r.group;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (newGroup)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  KiteSpace.lg,
                                  KiteSpace.md,
                                  KiteSpace.lg,
                                  KiteSpace.xs,
                                ),
                                child: Text(
                                  r.group.toUpperCase(),
                                  style: t.muted.copyWith(
                                    fontSize: 10,
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            _Row(
                              result: r,
                              active: i == _active,
                              onHover: () => setState(() => _active = i),
                              onTap: () => _run(r),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                const KiteSeparator(),
                _Footer(count: results.length),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.focusNode,
    required this.searching,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool searching;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KiteSpace.lg,
        vertical: KiteSpace.md,
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: c.mutedForeground),
          const SizedBox(width: KiteSpace.md),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              style: t.p.copyWith(fontSize: 15),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search pages, orders, customers…',
                hintStyle: t.muted.copyWith(fontSize: 15),
              ),
            ),
          ),
          if (searching)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                color: c.mutedForeground,
              ),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.result,
    required this.active,
    required this.onHover,
    required this.onTap,
  });

  final CommandResult result;
  final bool active;
  final VoidCallback onHover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return MouseRegion(
      onEnter: (_) => onHover(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: KiteSpace.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: KiteSpace.md,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: active ? c.accent : Colors.transparent,
            borderRadius: KiteRadius.allSm,
          ),
          child: Row(
            children: [
              Icon(result.icon, size: 15, color: c.mutedForeground),
              const SizedBox(width: KiteSpace.md),
              Expanded(
                child: Text(
                  result.label,
                  overflow: TextOverflow.ellipsis,
                  style: t.small.copyWith(fontSize: 13.5),
                ),
              ),
              if (result.detail != null)
                Text(result.detail!, style: t.muted.copyWith(fontSize: 11.5)),
              if (active) ...[
                const SizedBox(width: KiteSpace.sm),
                Icon(
                  Icons.subdirectory_arrow_left,
                  size: 13,
                  color: c.mutedForeground,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    Widget key(String label) => Container(
      margin: const EdgeInsetsDirectional.only(end: 6),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: c.muted,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: t.muted.copyWith(fontSize: 10.5)),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KiteSpace.lg,
        vertical: KiteSpace.sm,
      ),
      child: Row(
        children: [
          key('↑'),
          key('↓'),
          Text('navigate', style: t.muted.copyWith(fontSize: 11)),
          const SizedBox(width: KiteSpace.md),
          key('↵'),
          Text('open', style: t.muted.copyWith(fontSize: 11)),
          const SizedBox(width: KiteSpace.md),
          key('esc'),
          Text('close', style: t.muted.copyWith(fontSize: 11)),
          const Spacer(),
          Text('$count results', style: t.muted.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
