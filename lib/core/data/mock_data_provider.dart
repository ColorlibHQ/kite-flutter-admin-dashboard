import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data_provider.dart';

/// The most important adapter in the project.
///
/// It is what someone sees in the first sixty seconds: clone, `flutter run`, a
/// working admin with plausible data — no backend, no config, no API key. Every
/// competitor either hardcodes arrays into widgets or wants Firebase set up
/// before anything renders.
///
/// It does real server-side work — search, filter, sort and paginate all happen
/// here and return a page plus a total — so the screens above are exercising
/// the same code paths a real backend will.
class MockDataProvider implements DataProvider {
  MockDataProvider({this.latency = const Duration(milliseconds: 180)}) {
    _seed();
  }

  final Duration latency;
  final Map<String, List<JsonMap>> _db = {};

  static const _statuses = [
    'Paid',
    'Pending',
    'Refunded',
    'Shipped',
    'Cancelled',
  ];
  static const _first = [
    'Ada',
    'Grace',
    'Alan',
    'Katherine',
    'Linus',
    'Barbara',
    'Dennis',
    'Radia',
    'Ken',
    'Margaret',
    'Guido',
    'Anita',
    'Bjarne',
    'Shafi',
    'Tim',
    'Frances',
  ];
  static const _last = [
    'Lovelace',
    'Hopper',
    'Turing',
    'Johnson',
    'Torvalds',
    'Liskov',
    'Ritchie',
    'Perlman',
    'Thompson',
    'Hamilton',
    'Rossum',
    'Borg',
    'Stroustrup',
    'Goldwasser',
  ];
  static const _products = [
    'Standing desk',
    'Mechanical keyboard',
    'Monitor arm',
    'Noise-cancelling headphones',
    'Laptop stand',
    'Ergonomic chair',
    'USB-C dock',
    'Desk lamp',
    'Webcam',
    'Mouse pad',
  ];

  void _seed() {
    final rnd = Random(42);
    String name(int i) =>
        '${_first[(i * 7) % _first.length]} ${_last[(i * 11) % _last.length]}';

    _db['orders'] = List.generate(1284, (i) {
      final total = (rnd.nextDouble() * 1400 + 20);
      return {
        'id': '${10000 + i}',
        'reference': '#${10000 + i}',
        'customer': name(i),
        'status': _statuses[rnd.nextInt(_statuses.length)],
        'items': rnd.nextInt(9) + 1,
        'total': double.parse(total.toStringAsFixed(2)),
        'date': _date(rnd),
      };
    });

    _db['customers'] = List.generate(642, (i) {
      final n = name(i);
      return {
        'id': 'c$i',
        'name': n,
        'email': '${n.toLowerCase().replaceAll(' ', '.')}@example.com',
        'orders': rnd.nextInt(40),
        'spend': double.parse((rnd.nextDouble() * 9000).toStringAsFixed(2)),
        'status': rnd.nextInt(10) > 1 ? 'Active' : 'Churned',
      };
    });

    _db['products'] = List.generate(312, (i) {
      final stock = rnd.nextInt(400);
      return {
        'id': 'p$i',
        'name':
            '${_products[i % _products.length]} ${String.fromCharCode(65 + i % 26)}$i',
        'sku': 'SKU-${2000 + i}',
        'price': double.parse((rnd.nextDouble() * 500 + 9).toStringAsFixed(2)),
        'stock': stock,
        'status': stock == 0
            ? 'Out of stock'
            : (stock < 25 ? 'Low' : 'In stock'),
      };
    });
  }

  static String _date(Random rnd) {
    final m = rnd.nextInt(8) + 1;
    final d = rnd.nextInt(28) + 1;
    return '2026-${m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';
  }

  List<JsonMap> _table(String resource) {
    final t = _db[resource];
    if (t == null) throw DataProviderException('Unknown resource "$resource"');
    return t;
  }

  @override
  Future<ListResult> getList(String resource, ListParams params) async {
    await Future<void>.delayed(latency);
    var rows = List<JsonMap>.from(_table(resource));

    if (params.search.isNotEmpty) {
      final q = params.search.toLowerCase();
      rows = rows
          .where((r) => r.values.any((v) => '$v'.toLowerCase().contains(q)))
          .toList();
    }

    for (final entry in params.filters.entries) {
      if (entry.value == null) continue;
      rows = rows.where((r) => r[entry.key] == entry.value).toList();
    }

    final sort = params.sort;
    if (sort != null) {
      rows.sort((a, b) {
        final av = a[sort.field], bv = b[sort.field];
        final cmp = switch ((av, bv)) {
          (final num x, final num y) => x.compareTo(y),
          _ => '$av'.compareTo('$bv'),
        };
        return sort.dir == SortDir.asc ? cmp : -cmp;
      });
    }

    final total = rows.length;
    final start = (params.page - 1) * params.perPage;
    if (start >= total) return ListResult(rows: const [], total: total);
    final end = min(start + params.perPage, total);
    return ListResult(rows: rows.sublist(start, end), total: total);
  }

  @override
  Future<JsonMap> getOne(String resource, String id) async {
    await Future<void>.delayed(latency);
    final row = _table(resource).where((r) => r['id'] == id).firstOrNull;
    if (row == null) throw DataProviderException('No $resource with id "$id"');
    return Map.of(row);
  }

  @override
  Future<JsonMap> create(String resource, JsonMap data) async {
    await Future<void>.delayed(latency);
    final row = {
      ...data,
      'id': data['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
    };
    _table(resource).insert(0, row);
    return row;
  }

  @override
  Future<JsonMap> update(String resource, String id, JsonMap data) async {
    await Future<void>.delayed(latency);
    final table = _table(resource);
    final i = table.indexWhere((r) => r['id'] == id);
    if (i < 0) throw DataProviderException('No $resource with id "$id"');
    return table[i] = {...table[i], ...data, 'id': id};
  }

  @override
  Future<void> delete(String resource, String id) async {
    await Future<void>.delayed(latency);
    _table(resource).removeWhere((r) => r['id'] == id);
  }
}

/// Swap this one line for `RestDataProvider(...)` and every screen keeps working.
final dataProvider = Provider<DataProvider>((ref) => MockDataProvider());
