import 'package:flutter/foundation.dart';

typedef JsonMap = Map<String, Object?>;

enum SortDir { asc, desc }

@immutable
class SortSpec {
  const SortSpec(this.field, [this.dir = SortDir.asc]);
  final String field;
  final SortDir dir;
}

@immutable
class ListParams {
  const ListParams({
    this.page = 1,
    this.perPage = 25,
    this.sort,
    this.search = '',
    this.filters = const {},
  });

  final int page;
  final int perPage;
  final SortSpec? sort;
  final String search;
  final Map<String, Object?> filters;

  ListParams copyWith({
    int? page,
    int? perPage,
    SortSpec? sort,
    String? search,
    Map<String, Object?>? filters,
  }) => ListParams(
    page: page ?? this.page,
    perPage: perPage ?? this.perPage,
    sort: sort ?? this.sort,
    search: search ?? this.search,
    filters: filters ?? this.filters,
  );
}

@immutable
class ListResult {
  const ListResult({required this.rows, required this.total});

  /// The page of rows.
  final List<JsonMap> rows;

  /// Server-side total across all pages — this is what drives pagination, and
  /// what separates a real data table from one that only sorts what it already
  /// has in memory.
  final int total;

  static const empty = ListResult(rows: [], total: 0);
}

/// Implement this once against your backend and every screen works.
///
/// Deliberately untyped at the boundary. The template cannot know your models,
/// and forcing a codegen step on someone evaluating a template is how you lose
/// them in the first ten minutes. Decode into your own types above this line.
///
/// Ships with [MockDataProvider]; REST and Supabase adapters follow the same
/// five methods.
abstract interface class DataProvider {
  Future<ListResult> getList(String resource, ListParams params);
  Future<JsonMap> getOne(String resource, String id);
  Future<JsonMap> create(String resource, JsonMap data);
  Future<JsonMap> update(String resource, String id, JsonMap data);
  Future<void> delete(String resource, String id);
}

/// Thrown when a resource or record does not exist, so screens can render a
/// real error state instead of a spinner that never resolves.
class DataProviderException implements Exception {
  const DataProviderException(this.message);
  final String message;
  @override
  String toString() => 'DataProviderException: $message';
}
