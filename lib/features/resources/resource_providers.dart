import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/data_provider.dart';
import '../../core/data/mock_data_provider.dart';

/// Query state, keyed by resource.
///
/// One notifier holding a map rather than a provider family — fewer moving
/// parts to explain, and a template is read more than it is extended.
class ListParamsController extends Notifier<Map<String, ListParams>> {
  @override
  Map<String, ListParams> build() => const {};

  static const initial = ListParams(perPage: 25);

  ListParams of(String resource) => state[resource] ?? initial;

  void update(String resource, ListParams params) =>
      state = {...state, resource: params};

  void reset(String resource) => update(resource, initial);
}

final listParamsProvider =
    NotifierProvider<ListParamsController, Map<String, ListParams>>(
      ListParamsController.new,
    );

final listProvider = FutureProvider.family<ListResult, String>((
  Ref ref,
  String resource,
) async {
  final params =
      ref.watch(listParamsProvider)[resource] ?? ListParamsController.initial;
  return ref.watch(dataProvider).getList(resource, params);
});
