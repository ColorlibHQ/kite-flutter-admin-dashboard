import 'dart:convert';

import 'package:http/http.dart' as http;

import 'data_provider.dart';

/// Talks to Supabase through PostgREST.
///
/// Deliberately does **not** depend on `supabase_flutter`. Supabase's data API
/// is PostgREST over HTTPS, so a few hundred lines of `http` reach it without
/// pulling a large SDK — and its auth, realtime and storage — into a template
/// most people will re-point at their own backend anyway. If you want the SDK,
/// this class is the seam to replace.
///
/// Server-side count comes from the `Content-Range` header, requested with
/// `Prefer: count=exact`. That header is the entire reason pagination can be
/// honest about totals.
class SupabaseDataProvider implements DataProvider {
  SupabaseDataProvider({
    required this.url,
    required this.anonKey,
    this.accessToken,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Project URL, e.g. https://xyzcompany.supabase.co
  final String url;
  final String anonKey;

  /// A signed-in user's JWT, when you have one. Falls back to the anon key,
  /// which means row-level security decides what comes back.
  final String? accessToken;

  final http.Client _client;

  /// Columns searched by [ListParams.search], per table. PostgREST needs the
  /// columns named explicitly — there is no "search everything".
  static const searchColumns = <String, List<String>>{
    'orders': ['reference', 'customer', 'status'],
    'customers': ['name', 'email'],
    'products': ['name', 'sku'],
  };

  Uri _table(String resource, [Map<String, String>? query]) =>
      Uri.parse('${url.replaceAll(RegExp(r'/$'), '')}/rest/v1/$resource')
          .replace(queryParameters: query?.isEmpty ?? true ? null : query);

  Map<String, String> _headers({String? prefer}) => {
    'apikey': anonKey,
    'Authorization': 'Bearer ${accessToken ?? anonKey}',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Prefer': ?prefer,
  };

  Never _fail(http.Response r, String what) => throw DataProviderException(
    '$what failed: HTTP ${r.statusCode}${r.body.isEmpty ? '' : ' — ${r.body}'}',
  );

  @override
  Future<ListResult> getList(String resource, ListParams params) async {
    final query = <String, String>{'select': '*'};

    for (final e in params.filters.entries) {
      if (e.value != null) query[e.key] = 'eq.${e.value}';
    }

    if (params.search.isNotEmpty) {
      final cols = searchColumns[resource] ?? const [];
      if (cols.isNotEmpty) {
        // or=(name.ilike.*ada*,email.ilike.*ada*)
        final terms = cols.map((c) => '$c.ilike.*${params.search}*').join(',');
        query['or'] = '($terms)';
      }
    }

    if (params.sort != null) {
      query['order'] =
          '${params.sort!.field}.${params.sort!.dir == SortDir.asc ? 'asc' : 'desc'}';
    }

    final from = (params.page - 1) * params.perPage;
    final to = from + params.perPage - 1;

    final r = await _client.get(
      _table(resource, query),
      headers: {
        ..._headers(prefer: 'count=exact'),
        'Range': '$from-$to',
      },
    );
    if (r.statusCode >= 400) _fail(r, 'Listing $resource');

    final rows = (jsonDecode(r.body) as List).cast<JsonMap>();

    // Content-Range: 0-24/1284
    final range = r.headers['content-range'];
    final total = int.tryParse(range?.split('/').last ?? '') ?? rows.length;

    return ListResult(rows: rows, total: total);
  }

  @override
  Future<JsonMap> getOne(String resource, String id) async {
    final r = await _client.get(
      _table(resource, {'select': '*', 'id': 'eq.$id'}),
      headers: _headers(),
    );
    if (r.statusCode >= 400) _fail(r, 'Loading $resource/$id');
    final rows = (jsonDecode(r.body) as List).cast<JsonMap>();
    if (rows.isEmpty) throw DataProviderException('No $resource with id "$id"');
    return rows.first;
  }

  @override
  Future<JsonMap> create(String resource, JsonMap data) async {
    final r = await _client.post(
      _table(resource),
      headers: _headers(prefer: 'return=representation'),
      body: jsonEncode(data),
    );
    if (r.statusCode >= 400) _fail(r, 'Creating $resource');
    return (jsonDecode(r.body) as List).cast<JsonMap>().first;
  }

  @override
  Future<JsonMap> update(String resource, String id, JsonMap data) async {
    final r = await _client.patch(
      _table(resource, {'id': 'eq.$id'}),
      headers: _headers(prefer: 'return=representation'),
      body: jsonEncode(data),
    );
    if (r.statusCode >= 400) _fail(r, 'Updating $resource/$id');
    final rows = (jsonDecode(r.body) as List).cast<JsonMap>();
    if (rows.isEmpty) throw DataProviderException('No $resource with id "$id"');
    return rows.first;
  }

  @override
  Future<void> delete(String resource, String id) async {
    final r = await _client.delete(
      _table(resource, {'id': 'eq.$id'}),
      headers: _headers(),
    );
    if (r.statusCode >= 400) _fail(r, 'Deleting $resource/$id');
  }
}
