import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../kite_ui/kite_ui.dart';

/// Whether the sidebar promo is shown.
///
/// Kite is free; this card is how it points readers at the paid templates.
/// It is one `--dart-define` to remove, and deleting `promo_card.dart` plus
/// its single use in `app_shell.dart` removes it completely:
///
/// ```
/// flutter build web --dart-define=KITE_PROMO=false
/// ```
const kShowPromo = bool.fromEnvironment('KITE_PROMO', defaultValue: true);

const _promoUrl =
    'https://dashboardpack.com/'
    '?utm_source=kite-app&utm_medium=sidebar&utm_campaign=kite-free';

/// The sidebar promo.
///
/// Deliberately not "buy the Pro version of this" — there is no paid Flutter
/// template, and claiming one would be a lie the reader finds out about in two
/// clicks. What is true is that a team using Kite for Flutter often needs the
/// same admin in React or Next.js for something else, so that is the offer.
class PromoCard extends StatelessWidget {
  const PromoCard({super.key});

  /// Below this the sidebar cannot afford the card without squeezing the nav,
  /// so it stands down. A promo that pushes navigation off screen costs more
  /// than it earns.
  static const _minViewportHeight = 720.0;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    if (MediaQuery.sizeOf(context).height < _minViewportHeight) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KiteSpace.md,
        KiteSpace.lg,
        KiteSpace.md,
        KiteSpace.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(KiteSpace.md),
        decoration: BoxDecoration(
          color: c.background,
          border: Border.all(color: c.border),
          borderRadius: KiteRadius.allMd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'FROM THE SAME TEAM',
              style: t.muted.copyWith(
                fontSize: 9.5,
                letterSpacing: 0.7,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: KiteSpace.sm),
            Text(
              'Need this in React\nor Next.js?',
              style: t.small.copyWith(
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Admin templates for 7 more stacks.',
              style: t.muted.copyWith(fontSize: 11.5, height: 1.35),
            ),
            const SizedBox(height: KiteSpace.md),
            KiteButton(
              expands: true,
              onPressed: () => _open(context),
              child: const Text('Browse templates'),
            ),
            const SizedBox(height: KiteSpace.sm),
            Text(
              r'From $69 · commercial use',
              textAlign: TextAlign.center,
              style: t.muted.copyWith(fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse(_promoUrl);
    // launchUrl returns false rather than throwing when no handler exists —
    // on a locked-down desktop or a headless test that is not an error, but it
    // should not look like a dead button either.
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      KiteToast.show(
        context,
        title: 'Could not open the browser',
        description: _promoUrl,
      );
    }
  }
}
