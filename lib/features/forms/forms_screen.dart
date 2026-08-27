import 'package:flutter/material.dart';

import 'package:kite_ui/kite_ui.dart';

/// Form elements with real validation — the point at which most free templates
/// stop, having shipped inputs that look right and accept anything.
///
/// Every control here is a Kite wrapper, so the page inherits the theme rather
/// than mixing shadcn chrome with stock Material controls.
class FormsScreen extends StatefulWidget {
  const FormsScreen({super.key});
  @override
  State<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _notes = TextEditingController();

  String? _category;
  DateTime? _shipDate;
  double _discount = 10;
  bool _notify = true;
  bool _backorder = false;

  final _errors = <String, String?>{};
  bool _saved = false;

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
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    final errors = <String, String?>{};
    if (_name.text.trim().length < 3) {
      errors['name'] = 'Use at least three characters.';
    }
    if (!_email.text.contains('@')) {
      errors['email'] = 'Enter an address with an @ in it.';
    }
    if (_category == null) {
      errors['category'] = 'Pick a category.';
    }
    if (_shipDate == null) {
      errors['ship'] = 'Choose a ship date.';
    }

    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
      _saved = errors.isEmpty;
    });

    if (errors.isEmpty) {
      KiteToast.show(
        context,
        title: 'Product created',
        description: '${_name.text} is now live in the catalogue.',
        tone: KiteTone.success,
      );
    } else {
      KiteToast.show(
        context,
        title:
            '${errors.length} field${errors.length == 1 ? '' : 's'} need attention',
        tone: KiteTone.danger,
      );
    }
  }

  void _reset() {
    setState(() {
      _name.clear();
      _email.clear();
      _notes.clear();
      _category = null;
      _shipDate = null;
      _discount = 10;
      _notify = true;
      _backorder = false;
      _errors.clear();
      _saved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KiteSpace.xl),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: KiteCard(
            title: 'New product',
            trailing: _saved
                ? const KiteBadge('Saved', tone: KiteTone.success)
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                KiteField(
                  label: 'Product name',
                  error: _errors['name'],
                  child: KiteInput(
                    controller: _name,
                    placeholder: 'Standing desk',
                  ),
                ),
                KiteField(
                  label: 'Contact email',
                  hint: 'Used for stock alerts only.',
                  error: _errors['email'],
                  child: KiteInput(
                    controller: _email,
                    placeholder: 'you@company.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: KiteField(
                        label: 'Category',
                        error: _errors['category'],
                        child: KiteSelect<String>(
                          options: _categories,
                          labelOf: (v) => v,
                          value: _category,
                          placeholder: 'Choose one',
                          onChanged: (v) => setState(() => _category = v),
                        ),
                      ),
                    ),
                    const SizedBox(width: KiteSpace.lg),
                    Expanded(
                      child: KiteField(
                        label: 'Ship date',
                        error: _errors['ship'],
                        child: KiteDatePicker(
                          selected: _shipDate,
                          onChanged: (v) => setState(() => _shipDate = v),
                        ),
                      ),
                    ),
                  ],
                ),
                KiteField(
                  label: 'Notes',
                  hint: 'Anything the warehouse should know.',
                  child: KiteTextarea(
                    controller: _notes,
                    placeholder: 'Fragile — do not stack pallets.',
                  ),
                ),
                Text(
                  'Launch discount — ${_discount.round()}%',
                  style: t.small.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: KiteSpace.sm),
                KiteSlider(
                  value: _discount,
                  onChanged: (v) => setState(() => _discount = v),
                ),
                const SizedBox(height: KiteSpace.xl),
                const KiteSeparator(),
                const SizedBox(height: KiteSpace.xl),
                KiteSwitch(
                  value: _notify,
                  label: 'Email me when stock runs low',
                  sublabel: 'At most one message a day.',
                  onChanged: (v) => setState(() => _notify = v),
                ),
                const SizedBox(height: KiteSpace.lg),
                KiteCheckbox(
                  value: _backorder,
                  label: 'Allow backorders',
                  sublabel: 'Customers can order past zero stock.',
                  onChanged: (v) => setState(() => _backorder = v),
                ),
                const SizedBox(height: KiteSpace.xl),
                Row(
                  children: [
                    KiteButton(
                      onPressed: _submit,
                      child: const Text('Create product'),
                    ),
                    const SizedBox(width: KiteSpace.md),
                    KiteButton.ghost(
                      onPressed: _reset,
                      child: const Text('Reset'),
                    ),
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
