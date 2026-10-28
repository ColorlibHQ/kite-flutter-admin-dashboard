import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kite_ui/kite_ui.dart';

import '../../core/auth/session.dart';
import '../../core/data/data_provider.dart';
import '../../core/l10n/labels.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/states.dart';
import 'resource_providers.dart';
import 'resource_schema.dart';

class ResourceListScreen extends ConsumerWidget {
  const ResourceListScreen({super.key, required this.resource});

  final String resource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
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
                    title: l.emptyTitle,
                    message: l.emptyMessage,
                    actionLabel: l.actionClear,
                    onAction: () =>
                        ref.read(listParamsProvider.notifier).reset(resource),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: KiteDataTable(
                        paginate: false,
                        rowActionTooltip: l.openRecord,
                        onRowTap: (i) =>
                            context.go('/$resource/${result.rows[i]['id']}'),
                        columns: [
                          for (final f in spec.listFields)
                            TrinaColumn(
                              title: fieldLabel(l, f.title),
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
                                  locale: Localizations.localeOf(context)
                                      .toLanguageTag(),
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
                                  f.field: TrinaCell(
                                    value: f.kind == ColKind.select
                                        ? statusLabel(
                                            l,
                                            '${row[f.field] ?? ''}',
                                          )
                                        : row[f.field] ?? '',
                                  ),
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
    final l = L.of(context);
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
            placeholder: l.searchResource(resourceLabel(l, resource)),
            leading: Icon(Icons.search, size: 16, color: c.mutedForeground),
            onChanged: (v) =>
                notifier.update(resource, params.copyWith(search: v, page: 1)),
          ),
        ),
        for (final s in spec.statuses)
          _FilterChip(
            label: statusLabel(l, s),
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
            KiteToast.show(context, title: l.refreshed);
          },
          child: Text(l.actionRefresh),
        ),
        if (ref.watch(sessionProvider)?.role.canWrite ?? false)
          KiteButton(
            leading: const Icon(Icons.add, size: 16),
            onPressed: () => context.go('/$resource/new'),
            child: Text(l.newResource(fieldLabel(l, spec.singular))),
          ),
        KiteTooltip(
          message: l.openRecord,
          child: Icon(Icons.help_outline, size: 16, color: c.mutedForeground),
        ),
        if (params.search.isNotEmpty || active != null)
          KiteButton.ghost(
            onPressed: () => notifier.reset(resource),
            child: Text(l.actionClear, style: t.small),
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
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      backgroundColor: c.card,
      selectedColor: c.primary,
      labelStyle: KiteText.of(context).small
          .copyWith(color: selected ? c.primaryForeground : c.mutedForeground),
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
    final l = L.of(context);
    final notifier = ref.read(listParamsProvider.notifier);
    final first = (params.page - 1) * params.perPage + 1;
    final last = (first + params.perPage - 1).clamp(first, total);
    final pages = (total / params.perPage).ceil();

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: KiteSpace.sm,
      runSpacing: KiteSpace.sm,
      children: [
        Text(l.rangeOfTotal(first, last, total), style: t.muted),
        KiteButton.outline(
          enabled: params.page > 1,
          onPressed: () =>
              notifier.update(resource, params.copyWith(page: params.page - 1)),
          child: Text(l.actionPrevious),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KiteSpace.md),
          child: Text('Page ${params.page} of $pages', style: t.small),
        ),
        KiteButton.outline(
          enabled: params.page < pages,
          onPressed: () =>
              notifier.update(resource, params.copyWith(page: params.page + 1)),
          child: Text(l.actionNext),
        ),
      ],
    );
  }
}
