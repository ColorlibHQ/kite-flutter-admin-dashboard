import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kite/core/data/data_provider.dart';
import 'package:kite/core/data/rest_data_provider.dart';
import 'package:kite/core/data/supabase_data_provider.dart';

void main() {
  group('RestDataProvider', () {
    test('sends paging, sort, search and filters as query parameters', () async {
      late Uri seen;
      final provider = RestDataProvider(
        baseUrl: 'https://api.example.com',
        client: MockClient((req) async {
          seen = req.url;
          return http.Response('[]', 200, headers: {'x-total-count': '0'});
        }),
      );

      await provider.getList(
        'orders',
        const ListParams(
          page: 3,
          perPage: 25,
          search: 'ada',
          sort: SortSpec('total', SortDir.desc),
          filters: {'status': 'Paid'},
        ),
      );

      expect(seen.path, '/orders');
      expect(seen.queryParameters['_page'], '3');
      expect(seen.queryParameters['_limit'], '25');
      expect(seen.queryParameters['q'], 'ada');
      expect(seen.queryParameters['_sort'], 'total');
      expect(seen.queryParameters['_order'], 'desc');
      expect(seen.queryParameters['status'], 'Paid');
    });

    test('reads the total from X-Total-Count, not the page length', () async {
      final provider = RestDataProvider(
        baseUrl: 'https://api.example.com',
        client: MockClient(
          (_) async => http.Response(
            jsonEncode([
              {'id': '1'},
              {'id': '2'},
            ]),
            200,
            headers: {'x-total-count': '1284'},
          ),
        ),
      );
      final result = await provider.getList('orders', const ListParams());
      expect(result.rows, hasLength(2));
      expect(result.total, 1284);
    });

    test('unwraps an envelope when the body is not a bare list', () async {
      final provider = RestDataProvider(
        baseUrl: 'https://api.example.com',
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'data': [
                {'id': '1'},
              ],
              'total': 42,
            }),
            200,
          ),
        ),
      );
      final result = await provider.getList('orders', const ListParams());
      expect(result.rows.single['id'], '1');
      expect(result.total, 42);
    });

    test('turns a 404 into a DataProviderException, not a crash', () async {
      final provider = RestDataProvider(
        baseUrl: 'https://api.example.com',
        client: MockClient((_) async => http.Response('', 404)),
      );
      expect(
        () => provider.getOne('orders', 'nope'),
        throwsA(isA<DataProviderException>()),
      );
    });
  });

  group('SupabaseDataProvider', () {
    test('asks PostgREST for an exact count and a row range', () async {
      late http.BaseRequest seen;
      final provider = SupabaseDataProvider(
        url: 'https://xyz.supabase.co',
        anonKey: 'anon',
        client: MockClient((req) async {
          seen = req;
          return http.Response(
            '[]',
            200,
            headers: {'content-range': '25-49/1284'},
          );
        }),
      );

      final result = await provider.getList(
        'orders',
        const ListParams(page: 2, perPage: 25, filters: {'status': 'Paid'}),
      );

      expect(seen.headers['Prefer'], 'count=exact');
      expect(seen.headers['Range'], '25-49');
      expect(seen.url.queryParameters['status'], 'eq.Paid');
      expect(result.total, 1284, reason: 'total comes from Content-Range');
    });

    test('builds an or=(...ilike...) clause for search', () async {
      late Uri seen;
      final provider = SupabaseDataProvider(
        url: 'https://xyz.supabase.co',
        anonKey: 'anon',
        client: MockClient((req) async {
          seen = req.url;
          return http.Response('[]', 200);
        }),
      );
      await provider.getList('customers', const ListParams(search: 'ada'));
      expect(seen.queryParameters['or'], '(name.ilike.*ada*,email.ilike.*ada*)');
    });

    test('getOne throws when the row set comes back empty', () async {
      final provider = SupabaseDataProvider(
        url: 'https://xyz.supabase.co',
        anonKey: 'anon',
        client: MockClient((_) async => http.Response('[]', 200)),
      );
      expect(
        () => provider.getOne('orders', '404'),
        throwsA(isA<DataProviderException>()),
      );
    });
  });
}
