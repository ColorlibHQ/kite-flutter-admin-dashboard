import 'package:flutter/widgets.dart';

import '_shadcn.dart';

/// Semantic tone, separate from the brand accent. A status has to read at a
/// glance without relying on the reader parsing the label.
enum KiteTone { neutral, success, warning, danger, info }

class KiteBadge extends StatelessWidget {
  const KiteBadge(this.label, {super.key, this.tone = KiteTone.neutral});

  final String label;
  final KiteTone tone;

  @override
  Widget build(BuildContext context) {
    final cs = ShadTheme.of(context).colorScheme;
    final (bg, fg) = switch (tone) {
      KiteTone.neutral => (cs.muted, cs.mutedForeground),
      KiteTone.success => (const Color(0xFFD8EFEC), const Color(0xFF0C6B62)),
      KiteTone.warning => (const Color(0xFFFBEFD6), const Color(0xFF8A5A0B)),
      KiteTone.danger => (const Color(0xFFFBE7DA), const Color(0xFFB03D0B)),
      KiteTone.info => (const Color(0xFFDCE9FA), const Color(0xFF0663CE)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: ShadTheme.of(context).textTheme.small
            .copyWith(color: fg, fontSize: 12, height: 1.2),
      ),
    );
  }
}
