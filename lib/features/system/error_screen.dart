import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kite_ui/kite_ui.dart';

import '../../core/router/routes.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('404', style: t.h1.copyWith(color: c.mutedForeground)),
              const SizedBox(height: KiteSpace.md),
              Text('That page does not exist', style: t.h3),
              const SizedBox(height: KiteSpace.sm),
              Text(
                'Nothing is served at $location.',
                style: t.muted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KiteSpace.xl),
              KiteButton(
                onPressed: () => context.go(R.dashboard),
                child: const Text('Back to dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The other half of the error story. A 404 means "this does not exist"; a 500
/// means "it exists and we broke it" — different message, different recovery,
/// so it is a different screen rather than a reworded 404.
class ServerErrorScreen extends StatelessWidget {
  const ServerErrorScreen({super.key, this.detail, this.onRetry});

  final String? detail;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('500', style: t.h1.copyWith(color: c.destructive)),
              const SizedBox(height: KiteSpace.md),
              Text('Something broke on our end', style: t.h3),
              const SizedBox(height: KiteSpace.sm),
              Text(
                detail ??
                    'The request reached us but did not come back. Nothing you '
                        'did caused this, and nothing you submitted was lost.',
                style: t.muted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KiteSpace.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onRetry != null) ...[
                    KiteButton(
                      onPressed: onRetry,
                      child: const Text('Try again'),
                    ),
                    const SizedBox(width: KiteSpace.md),
                  ],
                  KiteButton.outline(
                    onPressed: () => context.go(R.dashboard),
                    child: const Text('Back to dashboard'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
