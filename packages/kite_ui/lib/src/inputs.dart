import 'package:flutter/material.dart';

import '../shadcn.dart';
import 'tokens.dart';

export 'package:shadcn_ui/shadcn_ui.dart' show ShadOption;

/// A labelled wrapper. Labels sit outside the control rather than floating
/// inside it — dense admin forms are easier to scan when the label never moves.
class KiteField extends StatelessWidget {
  const KiteField({
    super.key,
    required this.label,
    required this.child,
    this.hint,
    this.error,
  });

  final String label;
  final Widget child;
  final String? hint;
  final String? error;

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
          child,
          if (hint != null && error == null) ...[
            const SizedBox(height: KiteSpace.xs),
            Text(hint!, style: t.muted.copyWith(fontSize: 12)),
          ],
          if (error != null) ...[
            const SizedBox(height: KiteSpace.xs),
            // Say what went wrong and how to fix it.
            Text(
              error!,
              style: t.small.copyWith(fontSize: 12, color: c.destructive),
            ),
          ],
        ],
      ),
    );
  }
}

class KiteInput extends StatelessWidget {
  const KiteInput({
    super.key,
    this.controller,
    this.placeholder,
    this.leading,
    this.trailing,
    this.obscure = false,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final Widget? leading;
  final Widget? trailing;
  final bool obscure;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => ShadInput(
    controller: controller,
    placeholder: placeholder == null ? null : Text(placeholder!),
    leading: leading,
    trailing: trailing,
    obscureText: obscure,
    keyboardType: keyboardType,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
  );
}

class KiteTextarea extends StatelessWidget {
  const KiteTextarea({
    super.key,
    this.controller,
    this.placeholder,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => ShadTextarea(
    controller: controller,
    placeholder: placeholder == null ? null : Text(placeholder!),
    onChanged: onChanged,
  );
}

class KiteSelect<T extends Object> extends StatelessWidget {
  const KiteSelect({
    super.key,
    required this.options,
    required this.labelOf,
    this.value,
    this.placeholder,
    this.onChanged,
  });

  final List<T> options;
  final String Function(T) labelOf;
  final T? value;
  final String? placeholder;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) => ShadSelect<T>(
    initialValue: value,
    placeholder: Text(placeholder ?? 'Select…'),
    options: [
      for (final o in options) ShadOption(value: o, child: Text(labelOf(o))),
    ],
    selectedOptionBuilder: (context, v) => Text(labelOf(v)),
    onChanged: onChanged,
  );
}

class KiteCheckbox extends StatelessWidget {
  const KiteCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.sublabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? sublabel;

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    return ShadCheckbox(
      value: value,
      onChanged: onChanged,
      label: label == null ? null : Text(label!, style: t.small),
      sublabel: sublabel == null ? null : Text(sublabel!, style: t.muted),
    );
  }
}

class KiteSwitch extends StatelessWidget {
  const KiteSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.sublabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? sublabel;

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    return ShadSwitch(
      value: value,
      onChanged: onChanged,
      label: label == null ? null : Text(label!, style: t.small),
      sublabel: sublabel == null ? null : Text(sublabel!, style: t.muted),
    );
  }
}

class KiteSlider extends StatelessWidget {
  const KiteSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) =>
      ShadSlider(initialValue: value, min: min, max: max, onChanged: onChanged);
}

class KiteDatePicker extends StatelessWidget {
  const KiteDatePicker({
    super.key,
    this.selected,
    this.onChanged,
    this.placeholder,
  });

  final DateTime? selected;
  final ValueChanged<DateTime?>? onChanged;
  final String? placeholder;

  @override
  Widget build(BuildContext context) => ShadDatePicker(
    selected: selected,
    placeholder: Text(placeholder ?? 'Pick a date'),
    onChanged: onChanged,
  );
}
