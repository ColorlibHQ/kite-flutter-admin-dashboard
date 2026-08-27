import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kite_ui/kite_ui.dart';

import '../../core/data/data_provider.dart';
import '../../shared/widgets/states.dart';
import 'resource_providers.dart';
import 'resource_schema.dart';

class ResourceListScreen extends ConsumerWidget {
  const ResourceListScreen({super.key, required this.resource});

  final String resource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spec = kResources[resource]!;
    final async = ref.watch(listProvider(resource));
    final params = ref.watch(listParamsProvider.notifier).of(resource);

    return Padding(
      padding: const EdgeInsets.all(KiteSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Toolbar(resource: resource, spec: spec),
          const SizedBox(height: KiteSpace.lg),
          Expanded(
            child: async.when(
              loading: () => const LoadingState(),
              error: (e, _) => ErrorState(
                message: e is DataProviderException ? e.message : '$e',
                onRetry: () => ref.invalidate(listProvider(resource)),
              ),
              data: (result) {
                if (result.rows.isEmpty) {
                  return EmptyState(
                    title: 'Nothing matches those filters',
                    message: 'Try clearing the search or choosing a different status.',
                    actionLabel: 'Reset filters',
                    onAction: () =>
                        ref.read(listParamsProvider.notifier).reset(resource),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: KiteDataTable(
                        paginate: false,
                        onRowTap: (i) =>
                            context.go('/$resource/${result.rows[i]['id']}'),
                        columns: [
                          for (final f in spec.listFields)
                            TrinaColumn(
                              title: f.title,
                              field: f.field,
                              readOnly: true,
                              textAlign:
                                  f.kind == ColKind.number ||
                                      f.kind == ColKind.money
                                  ? TrinaColumnTextAlign.end
                                  : TrinaColumnTextAlign.start,
                              type: switch (f.kind) {
                                ColKind.number => TrinaColumnType.number(),
                                ColKind.money => TrinaColumnType.currency(
                                  symbol: r'$',
                                  decimalDigits: 2,
                                ),
                                _ => TrinaColumnType.text(),
                              },
                            ),
                        ],
                        rows: [
                          for (final row in result.rows)
                            TrinaRow(
                              cells: {
                                for (final f in spec.listFields)
                                  f.field: TrinaCell(value: row[f.field] ?? ''),
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: KiteSpace.md),
                    _Pager(
                      resource: resource,
                      params: params,
                      total: result.total,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends ConsumerWidget {
  const _Toolbar({required this.resource, required this.spec});
  final String resource;
  final ResourceSpec spec;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    ref.watch(listParamsProvider);
    final notifier = ref.read(listParamsProvider.notifier);
    final params = notifier.of(resource);
    final active = params.filters['status'] as String?;

    return Wrap(
      spacing: KiteSpace.md,
      runSpacing: KiteSpace.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 240,
          child: KiteInput(
            placeholder: 'Search $resource…',
            leading: Icon(Icons.search, size: 16, color: c.mutedForeground),
            onChanged: (v) =>
                notifier.update(resource, params.copyWith(search: v, page: 1)),
          ),
        ),
        for (final s in spec.statuses)
          _FilterChip(
            label: s,
            selected: active == s,
            onTap: () => notifier.update(
              resource,
              params.copyWith(
                filters: active == s
                    ? const <String, Object?>{}
                    : {'status': s},
                page: 1,
              ),
            ),
          ),
        KiteButton.ghost(
          leading: const Icon(Icons.refresh, size: 16),
          onPressed: () {
            ref.invalidate(listProvider(resource));
            KiteToast.show(context, title: 'Refreshed');
          },
          child: const Text('Refresh'),
        ),
        KiteButton(
          leading: const Icon(Icons.add, size: 16),
          onPressed: () => context.go('/$resource/new'),
          child: Text('New ${spec.singular.toLowerCase()}'),
        ),
        KiteTooltip(
          message: 'Double-tap any row to open it',
          child: Icon(Icons.help_outline, size: 16, color: c.mutedForeground),
        ),
        if (params.search.isNotEmpty || active != null)
          KiteButton.ghost(
            onPressed: () => notifier.reset(resource),
            child: Text('Clear', style: t.small),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Material(
      color: selected ? c.primary : c.card,
      borderRadius: KiteRadius.allSm,
      child: InkWell(
        borderRadius: KiteRadius.allSm,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: KiteSpace.md,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? c.primary : c.border),
            borderRadius: KiteRadius.allSm,
          ),
          child: Text(
            label,
            style: t.small.copyWith(
              color: selected ? c.primaryForeground : c.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}

/// Server-side pagination. The row count comes from [ListResult.total], not
/// from what happens to be loaded — the distinction the whole DataProvider
/// contract exists to make.
class _Pager extends ConsumerWidget {
  const _Pager({
    required this.resource,
    required this.params,
    required this.total,
  });
  final String resource;
  final ListParams params;
  final int total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = KiteText.of(context);
    final notifier = ref.read(listParamsProvider.notifier);
    final first = (params.page - 1) * params.perPage + 1;
    final last = (first + params.perPage - 1).clamp(first, total);
    final pages = (total / params.perPage).ceil();

    return Row(
      children: [
        Text('$first–$last of $total', style: t.muted),
        const Spacer(),
        KiteButton.outline(
          enabled: params.page > 1,
          onPressed: () =>
              notifier.update(resource, params.copyWith(page: params.page - 1)),
          child: const Text('Previous'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KiteSpace.md),
          child: Text('Page ${params.page} of $pages', style: t.small),
        ),
        KiteButton.outline(
          enabled: params.page < pages,
          onPressed: () =>
              notifier.update(resource, params.copyWith(page: params.page + 1)),
          child: const Text('Next'),
        ),
      ],
    );
  }
}
