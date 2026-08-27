import 'package:flutter/material.dart';

import '../shadcn.dart';
import 'tokens.dart';

export 'package:shadcn_ui/shadcn_ui.dart' show ShadTab;

/// Initials avatar. Admin tables show people far more often than photographs,
/// so the fallback is the common case, not the exception.
class KiteAvatar extends StatelessWidget {
  const KiteAvatar({super.key, required this.name, this.src, this.size = 32});

  final String name;
  final String? src;
  final double size;

  String get _initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    // ShadAvatar renders `placeholder` only when src is *null*. An empty string
    // is non-null, so it reaches UniversalImage's file loader and throws
    // "Unsupported operation: Not available for web".
    return ShadAvatar(
      (src != null && src!.isNotEmpty) ? src : null,
      size: Size.square(size),
      backgroundColor: c.muted,
      placeholder: Text(
        _initials,
        style: t.small.copyWith(
          fontSize: size * 0.36,
          color: c.mutedForeground,
        ),
      ),
    );
  }
}

/// A labelled progress bar with the value in tabular figures, so a column of
/// them lines up.
class KiteMeter extends StatelessWidget {
  const KiteMeter({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
    this.tone,
  });

  final String label;
  final double value;
  final String? trailing;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: KiteSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: t.small)),
              Text(
                trailing ?? '${(value * 100).round()}%',
                style: t.small.copyWith(
                  color: c.mutedForeground,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: KiteSpace.sm),
          ShadProgress(
            value: value,
            minHeight: 6,
            backgroundColor: c.muted,
            color: tone ?? c.primary,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }
}

class KiteSeparator extends StatelessWidget {
  const KiteSeparator({super.key, this.vertical = false});
  final bool vertical;

  @override
  Widget build(BuildContext context) => vertical
      ? const ShadSeparator.vertical(thickness: 1)
      : const ShadSeparator.horizontal(thickness: 1);
}

/// Tabs. Used for dashboard ranges and settings sections — anywhere the page
/// would otherwise grow a second scroll.
class KiteTabs extends StatelessWidget {
  const KiteTabs({super.key, required this.initial, required this.tabs});

  final String initial;
  final List<ShadTab<String>> tabs;

  @override
  Widget build(BuildContext context) =>
      ShadTabs<String>(value: initial, tabs: tabs);
}

class KiteTooltip extends StatelessWidget {
  const KiteTooltip({super.key, required this.message, required this.child});

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ShadTooltip(builder: (_) => Text(message), child: child);
}
