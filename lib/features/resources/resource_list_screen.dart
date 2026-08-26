import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/data_provider.dart';
import '../../core/data/mock_data_provider.dart';
import '../../kite_ui/kite_ui.dart';
import '../../shared/widgets/states.dart';

/// How a column renders. `money` matters: currency has to keep its numeric
/// value so sorting stays correct while the cell still shows `$1,294.00`.
enum ColKind { text, number, money }

/// Column definitions per resource. A real app would derive these from its own
/// models; keeping them declarative here is what lets one screen serve orders,
/// customers and products without three copies of it.
const _schemas = <String, List<(String field, String title, ColKind kind)>>{
  'orders': [
    ('reference', 'Order', ColKind.text),
    ('customer', 'Customer', ColKind.text),
    ('status', 'Status', ColKind.text),
    ('items', 'Items', ColKind.number),
    ('total', 'Total', ColKind.money),
    ('date', 'Date', ColKind.text),
  ],
  'customers': [
    ('name', 'Name', ColKind.text),
    ('email', 'Email', ColKind.text),
    ('orders', 'Orders', ColKind.number),
    ('spend', 'Lifetime spend', ColKind.money),
    ('status', 'Status', ColKind.text),
  ],
  'products': [
    ('name', 'Product', ColKind.text),
    ('sku', 'SKU', ColKind.text),
    ('price', 'Price', ColKind.money),
    ('stock', 'Stock', ColKind.number),
    ('status', 'Status', ColKind.text),
  ],
};

const _statusFilters = <String, List<String>>{
  'orders': ['Paid', 'Pending', 'Refunded', 'Shipped', 'Cancelled'],
  'customers': ['Active', 'Churned'],
  'products': ['In stock', 'Low', 'Out of stock'],
};

/// Query state, keyed by resource.
///
/// One notifier holding a map rather than a provider family — fewer moving
/// parts to explain, and a template is read more than it is extended.
class ListParamsController extends Notifier<Map<String, ListParams>> {
  @override
  Map<String, ListParams> build() => const {};

  static const _initial = ListParams(perPage: 25);

  ListParams of(String resource) => state[resource] ?? _initial;

  void update(String resource, ListParams params) =>
      state = {...state, resource: params};

  void reset(String resource) => update(resource, _initial);
}

final listParamsProvider =
    NotifierProvider<ListParamsController, Map<String, ListParams>>(
      ListParamsController.new,
    );

final _listProvider = FutureProvider.family<ListResult, String>((
  Ref ref,
  String resource,
) async {
  final params =
      ref.watch(listParamsProvider)[resource] ?? ListParamsController._initial;
  return ref.watch(dataProvider).getList(resource, params);
});

class ResourceListScreen extends ConsumerWidget {
  const ResourceListScreen({super.key, required this.resource});

  final String resource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_listProvider(resource));
    final params = ref.watch(listParamsProvider.notifier).of(resource);
    final schema = _schemas[resource]!;

    return Padding(
      padding: const EdgeInsets.all(KiteSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Toolbar(resource: resource),
          const SizedBox(height: KiteSpace.lg),
          Expanded(
            child: async.when(
              loading: () => const LoadingState(),
              error: (e, _) => ErrorState(
                message: e is DataProviderException ? e.message : '$e',
                onRetry: () => ref.invalidate(_listProvider(resource)),
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
                        columns: [
                          for (final (field, title, kind) in schema)
                            TrinaColumn(
                              title: title,
                              field: field,
                              readOnly: true,
                              textAlign: kind == ColKind.text
                                  ? TrinaColumnTextAlign.start
                                  : TrinaColumnTextAlign.end,
                              type: switch (kind) {
                                ColKind.text => TrinaColumnType.text(),
                                ColKind.number => TrinaColumnType.number(),
                                ColKind.money => TrinaColumnType.currency(
                                  symbol: r'$',
                                  decimalDigits: 2,
                                ),
                              },
                            ),
                        ],
                        rows: [
                          for (final row in result.rows)
                            TrinaRow(
                              cells: {
                                for (final (field, _, _) in schema)
                                  field: TrinaCell(value: row[field] ?? ''),
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
  const _Toolbar({required this.resource});
  final String resource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    ref.watch(listParamsProvider);
    final notifier = ref.read(listParamsProvider.notifier);
    final params = notifier.of(resource);
    final statuses = _statusFilters[resource]!;
    final active = params.filters['status'] as String?;

    return Wrap(
      spacing: KiteSpace.md,
      runSpacing: KiteSpace.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 260,
          child: TextField(
            style: t.p.copyWith(fontSize: 14),
            onChanged: (v) =>
                notifier.update(resource, params.copyWith(search: v, page: 1)),
            decoration: InputDecoration(
              hintText: 'Search $resource…',
              hintStyle: t.muted.copyWith(fontSize: 14),
              prefixIcon: Icon(
                Icons.search,
                size: 18,
                color: c.mutedForeground,
              ),
              isDense: true,
              filled: true,
              fillColor: c.card,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
        ),
        for (final s in statuses)
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
          onPressed: () => ref.invalidate(_listProvider(resource)),
          child: const Text('Refresh'),
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
        const SizedBox(width: KiteSpace.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KiteSpace.md),
          child: Text('Page ${params.page} of $pages', style: t.small),
        ),
        const SizedBox(width: KiteSpace.sm),
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
