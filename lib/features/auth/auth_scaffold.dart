import 'package:flutter/material.dart';

import 'package:kite_ui/kite_ui.dart';

/// Shared frame for the five auth screens: centred card, product mark, and a
/// footer link. Keeps them consistent without five copies of the same layout.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fields,
    this.footer,
  });

  final String title;
  final String subtitle;
  final List<Widget> fields;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KiteSpace.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.change_history, size: 22, color: c.primary),
                    const SizedBox(width: KiteSpace.sm),
                    Text('Kite', style: t.h4),
                  ],
                ),
                const SizedBox(height: KiteSpace.xxl),
                KiteCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(title, style: t.h3),
                      const SizedBox(height: KiteSpace.xs),
                      Text(subtitle, style: t.muted),
                      const SizedBox(height: KiteSpace.xl),
                      ...fields,
                    ],
                  ),
                ),
                if (footer != null) ...[
                  const SizedBox(height: KiteSpace.xl),
                  DefaultTextStyle.merge(
                    style: t.small.copyWith(color: c.mutedForeground),
                    textAlign: TextAlign.center,
                    child: footer!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A labelled field.
///
/// Delegates to the Kite wrappers so the auth screens inherit the same
/// controls as the rest of the app. They used to hand-roll a Material
/// TextField, which meant two input styles in one product.
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.onSubmitted,
    this.error,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;
  final String? error;

  @override
  Widget build(BuildContext context) => KiteField(
    label: label,
    error: error,
    child: KiteInput(
      controller: controller,
      placeholder: hint,
      obscure: obscure,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
    ),
  );
}
