import 'package:flutter/material.dart';

import '_shadcn.dart';
import 'tokens.dart';

@immutable
class KiteMenuItem {
  const KiteMenuItem({
    required this.label,
    this.icon,
    this.trailing,
    this.onPressed,
    this.destructive = false,
  });

  /// A divider between groups.
  const KiteMenuItem.separator()
    : label = '',
      icon = null,
      trailing = null,
      onPressed = null,
      destructive = false;

  final String label;
  final IconData? icon;
  final String? trailing;
  final VoidCallback? onPressed;
  final bool destructive;

  bool get isSeparator => label.isEmpty && icon == null;
}

/// A dropdown anchored to whatever triggers it.
///
/// Closes itself before running the callback, so a menu item that navigates
/// does not leave a popover floating over the next screen.
class KiteMenu extends StatefulWidget {
  const KiteMenu({
    super.key,
    required this.trigger,
    required this.items,
    this.header,
    this.width = 232,
  });

  /// Receives a callback that opens the menu.
  final Widget Function(BuildContext context, VoidCallback open) trigger;
  final List<KiteMenuItem> items;
  final Widget? header;
  final double width;

  @override
  State<KiteMenu> createState() => _KiteMenuState();
}

class _KiteMenuState extends State<KiteMenu> {
  final _controller = ShadPopoverController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadPopover(
      controller: _controller,
      popover: (context) => SizedBox(
        width: widget.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.header != null) ...[
              widget.header!,
              const SizedBox(height: KiteSpace.sm),
              const ShadSeparator.horizontal(
                thickness: 1,
                margin: EdgeInsets.zero,
              ),
              const SizedBox(height: KiteSpace.sm),
            ],
            for (final item in widget.items)
              if (item.isSeparator)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: KiteSpace.sm),
                  child: ShadSeparator.horizontal(
                    thickness: 1,
                    margin: EdgeInsets.zero,
                  ),
                )
              else
                _Row(
                  item: item,
                  onTap: () {
                    _controller.hide();
                    item.onPressed?.call();
                  },
                ),
          ],
        ),
      ),
      child: widget.trigger(context, _controller.toggle),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.onTap});
  final KiteMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final fg = item.destructive ? c.destructive : c.foreground;
    return Material(
      color: Colors.transparent,
      borderRadius: KiteRadius.allSm,
      child: InkWell(
        borderRadius: KiteRadius.allSm,
        onTap: item.onPressed == null ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KiteSpace.sm,
            vertical: 8,
          ),
          child: Row(
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: 15, color: fg),
                const SizedBox(width: KiteSpace.md),
              ],
              Expanded(
                child: Text(
                  item.label,
                  style: t.small.copyWith(fontSize: 13, color: fg),
                ),
              ),
              if (item.trailing != null)
                Text(item.trailing!, style: t.muted.copyWith(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
