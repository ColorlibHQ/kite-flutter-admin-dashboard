import 'package:flutter_test/flutter_test.dart';
import 'package:kite/core/data/data_provider.dart';
import 'package:kite/core/data/mock_data_provider.dart';

void main() {
  // Zero latency: these assert behaviour, not timing.
  final provider = MockDataProvider(latency: Duration.zero);

  group('getList', () {
    test('paginates and reports the full total, not the page length', () async {
      final page = await provider.getList(
        'orders',
        const ListParams(perPage: 25),
      );
      expect(page.rows, hasLength(25));
      expect(
        page.total,
        greaterThan(25),
        reason: 'total must span every row, or pagination lies',
      );
    });

    test('a later page returns different rows', () async {
      final first = await provider.getList(
        'orders',
        const ListParams(perPage: 10),
      );
      final second = await provider.getList(
        'orders',
        const ListParams(page: 2, perPage: 10),
      );
      expect(first.rows.first['id'], isNot(second.rows.first['id']));
    });

    test('a page past the end is empty but still reports the total', () async {
      final r = await provider.getList(
        'orders',
        const ListParams(page: 99999, perPage: 25),
      );
      expect(r.rows, isEmpty);
      expect(r.total, greaterThan(0));
    });

    test('search narrows results and shrinks the total', () async {
      final all = await provider.getList('customers', const ListParams());
      final hits = await provider.getList(
        'customers',
        const ListParams(search: 'Lovelace'),
      );
      expect(hits.total, lessThan(all.total));
      expect(hits.total, greaterThan(0));
      for (final row in hits.rows) {
        expect(
          row.values.any((v) => '$v'.toLowerCase().contains('lovelace')),
          isTrue,
        );
      }
    });

    test('filters are applied exactly', () async {
      final r = await provider.getList(
        'orders',
        const ListParams(filters: {'status': 'Refunded'}),
      );
      expect(r.rows, isNotEmpty);
      expect(r.rows.every((row) => row['status'] == 'Refunded'), isTrue);
    });

    test('sorting is numeric for numbers, not lexicographic', () async {
      final r = await provider.getList(
        'orders',
        const ListParams(perPage: 50, sort: SortSpec('total', SortDir.desc)),
      );
      final totals = r.rows.map((e) => e['total']! as num).toList();
      final sorted = List<num>.of(totals)..sort((a, b) => b.compareTo(a));
      expect(totals, orderedEquals(sorted));
    });

    test('an unknown resource throws rather than returning empty', () async {
      expect(
        () => provider.getList('nope', const ListParams()),
        throwsA(isA<DataProviderException>()),
      );
    });
  });

  group('mutations', () {
    test('create then getOne round-trips', () async {
      final made = await provider.create('products', {'name': 'Test widget'});
      final got = await provider.getOne('products', '${made['id']}');
      expect(got['name'], 'Test widget');
    });

    test('update merges and preserves the id', () async {
      final made = await provider.create('products', {
        'name': 'Before',
        'sku': 'X',
      });
      final id = '${made['id']}';
      final updated = await provider.update('products', id, {'name': 'After'});
      expect(updated['name'], 'After');
      expect(updated['sku'], 'X', reason: 'update should merge, not replace');
      expect(updated['id'], id);
    });

    test('delete removes the row', () async {
      final made = await provider.create('products', {'name': 'Doomed'});
      final id = '${made['id']}';
      await provider.delete('products', id);
      expect(
        () => provider.getOne('products', id),
        throwsA(isA<DataProviderException>()),
      );
    });
  });
}
