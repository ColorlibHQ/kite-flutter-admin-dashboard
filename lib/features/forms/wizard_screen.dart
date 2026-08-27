import 'package:flutter/material.dart';

import '../../kite_ui/kite_ui.dart';

/// A multi-step form.
///
/// The interesting part of a wizard is not the steps, it is that you cannot
/// advance past a step that is not valid, and that going back does not lose
/// what you typed. Both are easy to get wrong and both are what makes the
/// pattern worth having in a template.
class WizardScreen extends StatefulWidget {
  const WizardScreen({super.key});
  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  int _step = 0;
  bool _done = false;

  final _company = TextEditingController();
  final _vat = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _postcode = TextEditingController();
  String? _country;
  String? _plan = 'Growth';
  bool _annual = true;
  bool _terms = false;

  final Map<String, String?> _errors = {};

  static const _steps = <(String, String)>[
    ('Company', 'Who is being invoiced.'),
    ('Address', 'Where the invoices go.'),
    ('Plan', 'What you are signing up for.'),
    ('Review', 'Check it over before you commit.'),
  ];

  static const _countries = [
    'United Kingdom',
    'Germany',
    'France',
    'Spain',
    'Latvia',
    'United States',
  ];
  static const _plans = <(String, String, String)>[
    ('Starter', r'$19', 'One seat, 1,000 orders a month.'),
    ('Growth', r'$59', 'Five seats, 25,000 orders, priority support.'),
    ('Scale', r'$149', 'Unlimited seats and orders, dedicated support.'),
  ];

  @override
  void dispose() {
    for (final c in [_company, _vat, _street, _city, _postcode]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Validates only the step being left, so someone is never told about a
  /// field they have not reached yet.
  bool _validateStep(int step) {
    final errors = <String, String?>{};
    switch (step) {
      case 0:
        if (_company.text.trim().length < 2) {
          errors['company'] = 'Enter the registered company name.';
        }
      case 1:
        if (_street.text.trim().isEmpty) {
          errors['street'] = 'Street is required.';
        }
        if (_city.text.trim().isEmpty) errors['city'] = 'City is required.';
        if (_postcode.text.trim().isEmpty) {
          errors['postcode'] = 'Postcode is required.';
        }
        if (_country == null) errors['country'] = 'Choose a country.';
      case 2:
        if (_plan == null) errors['plan'] = 'Choose a plan.';
      case 3:
        if (!_terms) errors['terms'] = 'You have to accept the terms first.';
    }
    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });
    return errors.isEmpty;
  }

  void _next() {
    if (!_validateStep(_step)) {
      KiteToast.show(
        context,
        title: 'Check the highlighted fields',
        tone: KiteTone.danger,
      );
      return;
    }
    if (_step == _steps.length - 1) {
      setState(() => _done = true);
      KiteToast.show(
        context,
        title: 'Account created',
        description: '${_company.text.trim()} is on the $_plan plan.',
        tone: KiteTone.success,
      );
      return;
    }
    setState(() => _step++);
  }

  // Going back never validates and never clears — the controllers hold state
  // for every step, so nothing typed is lost.
  void _back() => setState(() => _step--);

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KiteSpace.xl),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Stepper(current: _step, done: _done),
              const SizedBox(height: KiteSpace.xl),
              KiteCard(
                title: _done ? 'All set' : _steps[_step].$1,
                child: _done
                    ? _Summary(
                        company: _company.text,
                        plan: _plan!,
                        annual: _annual,
                        onRestart: () => setState(() {
                          _done = false;
                          _step = 0;
                        }),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_steps[_step].$2, style: t.muted),
                          const SizedBox(height: KiteSpace.xl),
                          ..._body(),
                          const SizedBox(height: KiteSpace.sm),
                          Row(
                            children: [
                              if (_step > 0)
                                KiteButton.outline(
                                  onPressed: _back,
                                  child: const Text('Back'),
                                ),
                              const Spacer(),
                              KiteButton(
                                onPressed: _next,
                                child: Text(
                                  _step == _steps.length - 1
                                      ? 'Create account'
                                      : 'Continue',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _body() => switch (_step) {
    0 => [
      KiteField(
        label: 'Company name',
        error: _errors['company'],
        child: KiteInput(controller: _company, placeholder: 'Colorlib Ltd'),
      ),
      KiteField(
        label: 'VAT number',
        hint: 'Optional. Leave blank if you are not registered.',
        child: KiteInput(controller: _vat, placeholder: 'GB123456789'),
      ),
    ],
    1 => [
      KiteField(
        label: 'Street',
        error: _errors['street'],
        child: KiteInput(controller: _street, placeholder: '12 Market Street'),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: KiteField(
              label: 'City',
              error: _errors['city'],
              child: KiteInput(controller: _city),
            ),
          ),
          const SizedBox(width: KiteSpace.lg),
          Expanded(
            child: KiteField(
              label: 'Postcode',
              error: _errors['postcode'],
              child: KiteInput(controller: _postcode),
            ),
          ),
        ],
      ),
      KiteField(
        label: 'Country',
        error: _errors['country'],
        child: KiteSelect<String>(
          options: _countries,
          labelOf: (v) => v,
          value: _country,
          placeholder: 'Choose one',
          onChanged: (v) => setState(() => _country = v),
        ),
      ),
    ],
    2 => [
      for (final (name, price, blurb) in _plans)
        Padding(
          padding: const EdgeInsets.only(bottom: KiteSpace.md),
          child: _PlanTile(
            name: name,
            price: price,
            blurb: blurb,
            selected: _plan == name,
            onTap: () => setState(() => _plan = name),
          ),
        ),
      const SizedBox(height: KiteSpace.sm),
      KiteSwitch(
        value: _annual,
        label: 'Bill annually',
        sublabel: 'Two months free compared with paying monthly.',
        onChanged: (v) => setState(() => _annual = v),
      ),
    ],
    _ => [
      _ReviewRow(label: 'Company', value: _company.text.trim()),
      if (_vat.text.trim().isNotEmpty)
        _ReviewRow(label: 'VAT', value: _vat.text.trim()),
      _ReviewRow(
        label: 'Address',
        value: [
          _street.text.trim(),
          _city.text.trim(),
          _postcode.text.trim(),
          _country ?? '',
        ].where((s) => s.isNotEmpty).join(', '),
      ),
      _ReviewRow(
        label: 'Plan',
        value: '$_plan · ${_annual ? 'billed annually' : 'billed monthly'}',
      ),
      const SizedBox(height: KiteSpace.lg),
      KiteCheckbox(
        value: _terms,
        label: 'I accept the terms of service',
        sublabel: 'You can cancel at any time from Settings.',
        onChanged: (v) => setState(() => _terms = v),
      ),
      if (_errors['terms'] != null) ...[
        const SizedBox(height: KiteSpace.sm),
        Text(
          _errors['terms']!,
          style: KiteText.of(context).small.copyWith(
            fontSize: 12,
            color: KiteColors.of(context).destructive,
          ),
        ),
      ],
    ],
  };
}

/// The step rail. Completed steps get a check, the current one gets the
/// accent, and the rest stay muted — the reader should be able to tell where
/// they are without counting.
class _Stepper extends StatelessWidget {
  const _Stepper({required this.current, required this.done});
  final int current;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    const steps = _WizardScreenState._steps;

    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: (done || i < current)
                            ? c.primary
                            : (i == current ? c.primary : c.muted),
                        shape: BoxShape.circle,
                      ),
                      child: (done || i < current)
                          ? Icon(
                              Icons.check,
                              size: 13,
                              color: c.primaryForeground,
                            )
                          : Text(
                              '${i + 1}',
                              style: t.small.copyWith(
                                fontSize: 12,
                                color: i == current
                                    ? c.primaryForeground
                                    : c.mutedForeground,
                              ),
                            ),
                    ),
                    if (i != steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(
                            horizontal: KiteSpace.sm,
                          ),
                          color: (done || i < current) ? c.primary : c.border,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: KiteSpace.sm),
                Text(
                  steps[i].$1,
                  style: t.small.copyWith(
                    fontSize: 12,
                    color: (done || i <= current)
                        ? c.foreground
                        : c.mutedForeground,
                    fontWeight: i == current && !done
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.name,
    required this.price,
    required this.blurb,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String price;
  final String blurb;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Material(
      color: selected ? c.accent : c.background,
      borderRadius: KiteRadius.allMd,
      child: InkWell(
        borderRadius: KiteRadius.allMd,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(KiteSpace.lg),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? c.primary : c.border,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: KiteRadius.allMd,
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 18,
                color: selected ? c.primary : c.mutedForeground,
              ),
              const SizedBox(width: KiteSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: t.small.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(blurb, style: t.muted.copyWith(fontSize: 12)),
                  ],
                ),
              ),
              Text('$price/mo', style: t.small),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KiteSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: t.muted)),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: t.p.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.company,
    required this.plan,
    required this.annual,
    required this.onRestart,
  });

  final String company;
  final String plan;
  final bool annual;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        KiteAlert(
          title: '${company.isEmpty ? 'Your account' : company} is ready',
          description:
              'On the $plan plan, ${annual ? 'billed annually' : 'billed monthly'}. '
              'A receipt is on its way.',
          tone: KiteTone.success,
        ),
        const SizedBox(height: KiteSpace.xl),
        Text(
          'Nothing was actually created — this is the mock provider.',
          style: t.muted,
        ),
        const SizedBox(height: KiteSpace.lg),
        KiteButton.outline(
          onPressed: onRestart,
          child: const Text('Start over'),
        ),
      ],
    );
  }
}
