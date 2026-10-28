import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../auth/auth_repository.dart';
import '../auth/session.dart';
import '../auth/supabase_auth_repository.dart';
import 'authorized_data_provider.dart';
import 'data_provider.dart';
import 'mock_data_provider.dart';
import 'rest_data_provider.dart';
import 'supabase_data_provider.dart';

/// Public base URL, overridable with ProviderScope for embedded applications.
final apiUrlProvider = Provider<String>(
  (ref) => const String.fromEnvironment('KITE_API_URL'),
);

/// The backend seam for resource screens, recent records, and command search.
///
/// Defaults to seeded, in-memory data. Set --dart-define=KITE_API_URL=https://…
/// for REST, or replace this factory with your own DataProvider implementation.
/// Compile-time values are public in web builds; never put secrets here.
final dataProvider = Provider<DataProvider>((ref) {
  final apiUrl = ref.watch(apiUrlProvider);
  // Drop cached private data when the identity or server role changes.
  ref.watch(sessionProvider.select((user) => (user?.id, user?.role)));
  final auth = ref.watch(authRepositoryProvider);
  DataProvider protect(DataProvider delegate) => AuthorizedDataProvider(
    delegate,
    currentUser: () => ref.read(sessionProvider),
  );
  if (apiUrl.isEmpty && auth is! SupabaseAuthRepository) {
    return protect(MockDataProvider());
  }
  final client = http.Client();
  ref.onDispose(client.close);
  if (apiUrl.isEmpty && auth is SupabaseAuthRepository) {
    return protect(
      SupabaseDataProvider(
        url: auth.projectUrl,
        anonKey: auth.publicKey,
        accessTokenProvider: () => auth.accessToken,
        client: client,
      ),
    );
  }

  final uri = Uri.tryParse(apiUrl);
  if (uri == null ||
      !const {'http', 'https'}.contains(uri.scheme) ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment ||
      (!auth.isDemo &&
          uri.scheme == 'http' &&
          !const {'localhost', '127.0.0.1', '::1'}.contains(uri.host))) {
    throw const DataProviderException(
      'KITE_API_URL must be an HTTP(S) base URL without credentials, query, or fragment.',
    );
  }
  return protect(
    RestDataProvider(
      baseUrl: apiUrl,
      client: client,
      headersProvider: () => {
        if (auth.accessToken case final String token)
          'Authorization': 'Bearer $token',
      },
    ),
  );
});
