import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kite/core/auth/auth_repository.dart';
import 'package:kite/core/data/authorized_data_provider.dart';
import 'package:kite/core/data/data_provider.dart';
import 'package:kite/core/data/data_source.dart';
import 'package:kite/core/data/mock_data_provider.dart';
import 'package:kite/core/data/rest_data_provider.dart';

void main() {
  ProviderContainer containerFor(String url) {
    final repo = DemoAuthRepository(autoSignIn: true);
    addTearDown(repo.dispose);
    final container = ProviderContainer(
      overrides: [
        apiUrlProvider.overrideWithValue(url),
        authRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('no backend configuration provides seeded data', () async {
    final provider = containerFor('').read(dataProvider);
    expect(
      (provider as AuthorizedDataProvider).delegate,
      isA<MockDataProvider>(),
    );
    final result = await provider.getList('orders', const ListParams());
    expect(result.rows, isNotEmpty);
    expect(result.total, greaterThan(result.rows.length));
  });

  test('a REST URL can include an API path prefix', () {
    final provider = containerFor('https://api.example.com/v1')
        .read(dataProvider);
    expect(
      (provider as AuthorizedDataProvider).delegate,
      isA<RestDataProvider>(),
    );
    expect(
      ((provider).delegate as RestDataProvider).baseUrl,
      'https://api.example.com/v1',
    );
  });

  test('invalid backend URLs fail before making a request', () {
    for (final url in [
      'api.example.com',
      'file:///tmp/data',
      'https://',
      'https://user:secret@example.com',
      'https://example.com?token=secret',
      'https://example.com#data',
    ]) {
      expect(
        () => containerFor(url).read(dataProvider),
        throwsA(
          isA<ProviderException>().having(
            (error) => error.exception,
            'exception',
            isA<DataProviderException>(),
          ),
        ),
        reason: url,
      );
    }
  });
}
