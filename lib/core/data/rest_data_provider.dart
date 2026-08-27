import 'dart:convert';

import 'package:http/http.dart' as http;

import 'data_provider.dart';

/// Talks to a conventional REST backend.
///
/// Assumes the shape most JSON APIs already use:
///
///   GET    /orders?_page=1&_limit=25&_sort=total&_order=desc&q=ada&status=Paid
///   GET    /orders/10004
///   POST   /orders
///   PATCH  /orders/10004
///   DELETE /orders/10004
///
/// The total row count comes from an `X-Total-Count` header, falling back to a
/// `total` field on an envelope. Getting that right is the difference between
/// real pagination and a table that only knows about the page it is holding —
/// if your API spells these differently, this is the one file to change.
class RestDataProvider implements DataProvider {
  RestDataProvider({
    required this.baseUrl,
    this.headers = const {},
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final Map<String, String> headers;
  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('${baseUrl.replaceAll(RegExp(r'/$'), '')}/$path')
          .replace(queryParameters: query?.isEmpty ?? true ? null : query);

  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    ...headers,
  };

  Never _fail(http.Response r, String what) =>
      throw DataProviderException('$what failed: HTTP ${r.statusCode}');

  @override
  Future<ListResult> getList(String resource, ListParams params) async {
    final query = <String, String>{
      '_page': '${params.page}',
      '_limit': '${params.perPage}',
      if (params.search.isNotEmpty) 'q': params.search,
      if (params.sort != null) ...{
        '_sort': params.sort!.field,
        '_order': params.sort!.dir == SortDir.asc ? 'asc' : 'desc',
      },
      for (final e in params.filters.entries)
        if (e.value != null) e.key: '${e.value}',
    };

    final r = await _client.get(_uri(resource, query), headers: _jsonHeaders);
    if (r.statusCode >= 400) _fail(r, 'Listing $resource');

    final decoded = jsonDecode(r.body);
    final rows = switch (decoded) {
      final List<dynamic> l => l.cast<JsonMap>(),
      final Map<String, dynamic> m when m['data'] is List =>
        (m['data'] as List).cast<JsonMap>(),
      _ => const <JsonMap>[],
    };

    final header = r.headers['x-total-count'];
    final total =
        int.tryParse(header ?? '') ??
        (decoded is Map<String, dynamic> ? decoded['total'] as int? : null) ??
        rows.length;

    return ListResult(rows: rows, total: total);
  }

  @override
  Future<JsonMap> getOne(String resource, String id) async {
    final r = await _client.get(_uri('$resource/$id'), headers: _jsonHeaders);
    if (r.statusCode == 404) {
      throw DataProviderException('No $resource with id "$id"');
    }
    if (r.statusCode >= 400) _fail(r, 'Loading $resource/$id');
    return jsonDecode(r.body) as JsonMap;
  }

  @override
  Future<JsonMap> create(String resource, JsonMap data) async {
    final r = await _client.post(
      _uri(resource),
      headers: _jsonHeaders,
      body: jsonEncode(data),
    );
    if (r.statusCode >= 400) _fail(r, 'Creating $resource');
    return jsonDecode(r.body) as JsonMap;
  }

  @override
  Future<JsonMap> update(String resource, String id, JsonMap data) async {
    final r = await _client.patch(
      _uri('$resource/$id'),
      headers: _jsonHeaders,
      body: jsonEncode(data),
    );
    if (r.statusCode >= 400) _fail(r, 'Updating $resource/$id');
    return jsonDecode(r.body) as JsonMap;
  }

  @override
  Future<void> delete(String resource, String id) async {
    final r = await _client.delete(
      _uri('$resource/$id'),
      headers: _jsonHeaders,
    );
    if (r.statusCode >= 400) _fail(r, 'Deleting $resource/$id');
  }
}
