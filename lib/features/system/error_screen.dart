import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../kite_ui/kite_ui.dart';

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
