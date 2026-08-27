import 'package:flutter/widgets.dart';

import 'badge.dart';
import 'tokens.dart';

class KiteCard extends StatelessWidget {
  const KiteCard({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.padding,
  });

  final Widget child;
  final String? title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Container(
      padding: padding ?? const EdgeInsets.all(KiteSpace.xl),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.border),
        borderRadius: KiteRadius.allLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(child: Text(title!, style: t.large)),
                ?trailing,
              ],
            ),
            const SizedBox(height: KiteSpace.lg),
          ],
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// The dashboard stat tile. State is encoded in form as well as number — the
/// delta carries its own tone so direction reads before the digits do.
class KiteStat extends StatelessWidget {
  const KiteStat({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.deltaTone = KiteTone.neutral,
  });

  final String label;
  final String value;
  final String? delta;
  final KiteTone deltaTone;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final deltaColor = switch (deltaTone) {
      KiteTone.success => const Color(0xFF0C6B62),
      KiteTone.danger => const Color(0xFFB03D0B),
      _ => c.mutedForeground,
    };
    return Container(
      padding: const EdgeInsets.all(KiteSpace.xl),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.border),
        borderRadius: KiteRadius.allLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: t.muted),
          const SizedBox(height: KiteSpace.sm),
          Text(
            value,
            style: t.h3.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (delta != null) ...[
            const SizedBox(height: KiteSpace.xs),
            Text(delta!, style: t.small.copyWith(color: deltaColor)),
          ],
        ],
      ),
    );
  }
}
