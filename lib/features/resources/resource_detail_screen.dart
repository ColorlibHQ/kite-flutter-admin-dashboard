import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/data_provider.dart';
import '../../core/data/mock_data_provider.dart';
import '../../kite_ui/kite_ui.dart';
import '../../shared/widgets/states.dart';
import 'resource_providers.dart';
import 'resource_schema.dart';

final recordProvider = FutureProvider.family<JsonMap, (String, String)>((
  Ref ref,
  key,
) async {
  return ref.watch(dataProvider).getOne(key.$1, key.$2);
});

/// The full detail page.
///
/// The list already opens a drawer for a quick look; this is the addressable
/// version — a real URL you can link a colleague to, which the drawer can
/// never be.
class ResourceDetailScreen extends ConsumerWidget {
  const ResourceDetailScreen({
    super.key,
    required this.resource,
    required this.id,
  });

  final String resource;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spec = kResources[resource]!;
    final async = ref.watch(recordProvider((resource, id)));
    final t = KiteText.of(context);

    return async.when(
      loading: () => const LoadingState(),
      error: (e, _) => ErrorState(
        message: e is DataProviderException ? e.message : '$e',
        onRetry: () => ref.invalidate(recordProvider((resource, id))),
      ),
      data: (row) {
        final title = '${row[spec.titleField]}';
        return SingleChildScrollView(
          padding: const EdgeInsets.all(KiteSpace.xl),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Breadcrumb(resource: resource, spec: spec, current: title),
                  const SizedBox(height: KiteSpace.lg),
                  Row(
                    children: [
                      Expanded(child: Text(title, style: t.h2)),
                      KiteButton.outline(
                        leading: const Icon(Icons.edit_outlined, size: 15),
                        onPressed: () => context.go('/$resource/$id/edit'),
                        child: const Text('Edit'),
                      ),
                      const SizedBox(width: KiteSpace.sm),
                      KiteButton.destructive(
                        onPressed: () async {
                          final ok = await kiteConfirm(
                            context,
                            title: 'Delete $title?',
                            message: 'This removes the record permanently and cannot be undone.',
                          );
                          if (!ok || !context.mounted) return;
                          await ref.read(dataProvider).delete(resource, id);
                          if (!context.mounted) return;
                          ref.invalidate(listProvider(resource));
                          context.go('/$resource');
                          KiteToast.show(
                            context,
                            title: '$title deleted',
                            tone: KiteTone.danger,
                          );
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                  const SizedBox(height: KiteSpace.xl),
                  KiteCard(
                    title: 'Details',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final f in spec.fields)
                          _Row(spec: f, value: row[f.field]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({
    required this.resource,
    required this.spec,
    required this.current,
  });

  final String resource;
  final ResourceSpec spec;
  final String current;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Row(
      children: [
        InkWell(
          onTap: () => context.go('/$resource'),
          child: Text(
            spec.name[0].toUpperCase() + spec.name.substring(1),
            style: t.muted.copyWith(color: c.mutedForeground),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KiteSpace.sm),
          child: Icon(Icons.chevron_right, size: 14, color: c.mutedForeground),
        ),
        Text(current, style: t.small),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.spec, required this.value});
  final FieldSpec spec;
  final Object? value;

  static KiteTone _tone(String v) => switch (v) {
    'Paid' || 'Shipped' || 'Active' || 'In stock' => KiteTone.success,
    'Pending' || 'Low' => KiteTone.warning,
    'Cancelled' || 'Churned' || 'Out of stock' => KiteTone.danger,
    'Refunded' => KiteTone.info,
    _ => KiteTone.neutral,
  };

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    final display = switch (spec.kind) {
      ColKind.money => KiteFormat.money(value),
      ColKind.number => KiteFormat.count(value),
      _ => value == null || '$value'.isEmpty ? '—' : '$value',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KiteSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 160, child: Text(spec.title, style: t.muted)),
          Expanded(
            child: spec.kind == ColKind.select
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: KiteBadge(display, tone: _tone(display)),
                  )
                : Text(display, style: t.p.copyWith(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
