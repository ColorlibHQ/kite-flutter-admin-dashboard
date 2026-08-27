import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/data_provider.dart';
import '../../core/data/mock_data_provider.dart';
import '../../kite_ui/kite_ui.dart';
import '../../shared/widgets/states.dart';
import 'resource_detail_screen.dart';
import 'resource_providers.dart';
import 'resource_schema.dart';

/// Create and edit, from the same screen.
///
/// The only difference between the two is whether an id was supplied, so
/// splitting them would mean maintaining one form twice.
class ResourceFormScreen extends ConsumerWidget {
  const ResourceFormScreen({super.key, required this.resource, this.id});

  final String resource;
  final String? id;

  bool get _isEdit => id != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!_isEdit) {
      return _Form(resource: resource, id: null, initial: const {});
    }
    final async = ref.watch(recordProvider((resource, id!)));
    return async.when(
      loading: () => const LoadingState(),
      error: (e, _) => ErrorState(
        message: e is DataProviderException ? e.message : '$e',
        onRetry: () => ref.invalidate(recordProvider((resource, id!))),
      ),
      data: (row) => _Form(resource: resource, id: id, initial: row),
    );
  }
}

class _Form extends ConsumerStatefulWidget {
  const _Form({
    required this.resource,
    required this.id,
    required this.initial,
  });

  final String resource;
  final String? id;
  final JsonMap initial;

  @override
  ConsumerState<_Form> createState() => _FormState();
}

class _FormState extends ConsumerState<_Form> {
  late final ResourceSpec _spec = kResources[widget.resource]!;
  late final Map<String, TextEditingController> _controllers = {
    for (final f in _spec.editableFields)
      if (f.kind != ColKind.select)
        f.field: TextEditingController(
          text: widget.initial[f.field] == null
              ? ''
              : '${widget.initial[f.field]}',
        ),
  };
  late final Map<String, String?> _selects = {
    for (final f in _spec.editableFields)
      if (f.kind == ColKind.select) f.field: widget.initial[f.field] as String?,
  };

  final Map<String, String?> _errors = {};
  bool _saving = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validate(FieldSpec f) {
    final raw = _controllers[f.field]?.text.trim() ?? '';
    switch (f.kind) {
      case ColKind.select:
        if (_selects[f.field] == null) {
          return 'Choose a ${f.title.toLowerCase()}.';
        }
      case ColKind.email:
        if (!raw.contains('@')) return 'Enter an address with an @ in it.';
      case ColKind.number:
      case ColKind.money:
        if (num.tryParse(raw) == null) return 'Numbers only.';
      case ColKind.text:
        if (raw.isEmpty) return '${f.title} cannot be empty.';
      case ColKind.longText:
        break;
    }
    return null;
  }

  Future<void> _save() async {
    final errors = <String, String?>{};
    for (final f in _spec.editableFields) {
      final err = _validate(f);
      if (err != null) errors[f.field] = err;
    }
    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
    });
    if (errors.isNotEmpty) {
      KiteToast.show(
        context,
        title:
            '${errors.length} field${errors.length == 1 ? '' : 's'} need attention',
        tone: KiteTone.danger,
      );
      return;
    }

    setState(() => _saving = true);
    final payload = <String, Object?>{
      for (final f in _spec.editableFields)
        f.field: switch (f.kind) {
          ColKind.select => _selects[f.field],
          ColKind.number => int.tryParse(_controllers[f.field]!.text.trim()),
          ColKind.money => double.tryParse(_controllers[f.field]!.text.trim()),
          _ => _controllers[f.field]!.text.trim(),
        },
    };

    final provider = ref.read(dataProvider);
    try {
      final saved = widget.id == null
          ? await provider.create(widget.resource, payload)
          : await provider.update(widget.resource, widget.id!, payload);
      if (!mounted) return;
      ref.invalidate(listProvider(widget.resource));
      if (widget.id != null) {
        ref.invalidate(recordProvider((widget.resource, widget.id!)));
      }
      final newId = '${saved['id']}';
      context.go('/${widget.resource}/$newId');
      KiteToast.show(
        context,
        title: widget.id == null
            ? '${_spec.singular} created'
            : '${_spec.singular} saved',
        tone: KiteTone.success,
      );
    } on DataProviderException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      KiteToast.show(
        context,
        title: 'Could not save',
        description: e.message,
        tone: KiteTone.danger,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    final title = widget.id == null
        ? 'New ${_spec.singular.toLowerCase()}'
        : 'Edit ${widget.initial[_spec.titleField]}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KiteSpace.xl),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: t.h2),
              const SizedBox(height: KiteSpace.xl),
              KiteCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final f in _spec.editableFields)
                      KiteField(
                        label: f.title,
                        error: _errors[f.field],
                        child: switch (f.kind) {
                          ColKind.select => KiteSelect<String>(
                            options: f.options,
                            labelOf: (v) => v,
                            value: _selects[f.field],
                            placeholder: 'Choose one',
                            onChanged: (v) =>
                                setState(() => _selects[f.field] = v),
                          ),
                          ColKind.longText => KiteTextarea(
                            controller: _controllers[f.field],
                            placeholder: 'Optional',
                          ),
                          ColKind.number || ColKind.money => KiteInput(
                            controller: _controllers[f.field],
                            keyboardType: TextInputType.number,
                          ),
                          ColKind.email => KiteInput(
                            controller: _controllers[f.field],
                            placeholder: 'you@company.com',
                            keyboardType: TextInputType.emailAddress,
                          ),
                          ColKind.text => KiteInput(
                            controller: _controllers[f.field],
                          ),
                        },
                      ),
                    const SizedBox(height: KiteSpace.sm),
                    Row(
                      children: [
                        KiteButton(
                          enabled: !_saving,
                          onPressed: _save,
                          child: Text(_saving ? 'Saving…' : 'Save'),
                        ),
                        const SizedBox(width: KiteSpace.md),
                        KiteButton.ghost(
                          onPressed: () => context.go(
                            widget.id == null
                                ? '/${widget.resource}'
                                : '/${widget.resource}/${widget.id}',
                          ),
                          child: const Text('Cancel'),
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
}
