import 'package:flutter/material.dart';

import '../../kite_ui/kite_ui.dart';

/// Honest empty, loading and error states.
///
/// Free templates habitually stop at the happy path — a grid full of lorem and
/// nothing behind it. These three are the difference between a screenshot and
/// something you can ship.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: KiteColors.of(context).mutedForeground,
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 32, color: c.mutedForeground),
            const SizedBox(height: KiteSpace.lg),
            Text(title, style: t.large, textAlign: TextAlign.center),
            const SizedBox(height: KiteSpace.sm),
            Text(message, style: t.muted, textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: KiteSpace.xl),
              KiteButton.outline(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 32, color: c.destructive),
            const SizedBox(height: KiteSpace.lg),
            Text(
              'Something went wrong',
              style: t.large,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KiteSpace.sm),
            // Say what failed and how to recover — no apologies, no vagueness.
            Text(message, style: t.muted, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: KiteSpace.xl),
              KiteButton.outline(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
