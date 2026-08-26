import 'package:flutter/material.dart';

import '../../kite_ui/kite_ui.dart';

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

/// A labelled field. Material's TextField carries a lot of chrome the shadcn
/// look does not want, so this keeps the label outside and the input plain.
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.autofillHints,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final List<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: KiteSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: t.small.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: KiteSpace.sm),
          TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            autofillHints: autofillHints,
            onSubmitted: onSubmitted,
            style: t.p.copyWith(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: t.muted.copyWith(fontSize: 14),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: KiteSpace.md,
                vertical: 12,
              ),
              filled: true,
              fillColor: c.background,
              enabledBorder: OutlineInputBorder(
                borderRadius: KiteRadius.allSm,
                borderSide: BorderSide(color: c.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: KiteRadius.allSm,
                borderSide: BorderSide(color: c.ring, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
