import 'package:flutter/material.dart';

import '../../kite_ui/kite_ui.dart';

/// Form elements with real validation — the point at which most free templates
/// stop, having shipped inputs that look right and accept anything.
class FormsScreen extends StatefulWidget {
  const FormsScreen({super.key});
  @override
  State<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _qty = TextEditingController(text: '1');
  String? _category;
  bool _notify = true;
  bool _submitted = false;

  static const _categories = [
    'Hardware',
    'Software',
    'Services',
    'Subscriptions',
  ];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);

    InputDecoration deco(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: t.muted.copyWith(fontSize: 14),
      isDense: true,
      filled: true,
      fillColor: c.background,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: KiteSpace.md,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: KiteRadius.allSm,
        borderSide: BorderSide(color: c.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: KiteRadius.allSm,
        borderSide: BorderSide(color: c.ring, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: KiteRadius.allSm,
        borderSide: BorderSide(color: c.destructive),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: KiteRadius.allSm,
        borderSide: BorderSide(color: c.destructive, width: 1.5),
      ),
    );

    Widget field(String label, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: KiteSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: t.small.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: KiteSpace.sm),
          child,
        ],
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KiteSpace.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: KiteCard(
          title: 'New product',
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                field(
                  'Product name',
                  TextFormField(
                    controller: _name,
                    style: t.p.copyWith(fontSize: 14),
                    decoration: deco('Standing desk'),
                    validator: (v) => (v == null || v.trim().length < 3)
                        ? 'Use at least three characters.'
                        : null,
                  ),
                ),
                field(
                  'Contact email',
                  TextFormField(
                    controller: _email,
                    style: t.p.copyWith(fontSize: 14),
                    keyboardType: TextInputType.emailAddress,
                    decoration: deco('you@company.com'),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Enter an address with an @ in it.'
                        : null,
                  ),
                ),
                field(
                  'Category',
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: deco('Choose one'),
                    style: t.p.copyWith(fontSize: 14, color: c.foreground),
                    items: [
                      for (final cat in _categories)
                        DropdownMenuItem(value: cat, child: Text(cat)),
                    ],
                    onChanged: (v) => setState(() => _category = v),
                    validator: (v) => v == null ? 'Pick a category.' : null,
                  ),
                ),
                field(
                  'Quantity',
                  TextFormField(
                    controller: _qty,
                    style: t.p.copyWith(fontSize: 14),
                    keyboardType: TextInputType.number,
                    decoration: deco('1'),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null) return 'Numbers only.';
                      if (n < 1) return 'At least one.';
                      return null;
                    },
                  ),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _notify,
                  onChanged: (v) => setState(() => _notify = v),
                  title: Text('Email me when stock runs low', style: t.small),
                ),
                const SizedBox(height: KiteSpace.lg),
                Row(
                  children: [
                    KiteButton(
                      onPressed: () {
                        final ok = _formKey.currentState?.validate() ?? false;
                        setState(() => _submitted = ok);
                      },
                      child: const Text('Create product'),
                    ),
                    const SizedBox(width: KiteSpace.md),
                    KiteButton.ghost(
                      onPressed: () {
                        _formKey.currentState?.reset();
                        setState(() {
                          _submitted = false;
                          _category = null;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                    const Spacer(),
                    if (_submitted)
                      const KiteBadge('Saved', tone: KiteTone.success),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
