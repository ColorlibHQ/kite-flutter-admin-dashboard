import 'package:flutter_test/flutter_test.dart';
import 'package:kite/core/auth/auth_models.dart';
import 'package:kite/core/data/authorized_data_provider.dart';
import 'package:kite/core/data/data_provider.dart';
import 'package:kite/core/data/mock_data_provider.dart';
import 'package:kite/core/router/auth_redirect.dart';
import 'package:kite/core/router/routes.dart';

void main() {
  SessionUser user(UserRole role) =>
      SessionUser(id: '1', name: 'Test', email: 'test@example.com', role: role);
  for (final role in UserRole.values) {
    test('$role has matching route and mutation permissions', () async {
      final provider = AuthorizedDataProvider(
        MockDataProvider(latency: Duration.zero),
        currentUser: () => user(role),
      );
      if (!role.canRead) {
        expect(
          () => provider.getList('products', const ListParams()),
          throwsA(isA<PermissionDeniedException>()),
        );
        expect(
          authRedirect(
            signedIn: true,
            role: role,
            location: Uri.parse('/orders'),
          ),
          R.forbidden,
        );
      } else {
        expect(
          (await provider.getList('products', const ListParams())).rows,
          isNotEmpty,
        );
      }
      if (role.canWrite) {
        final saved = await provider.create('products', {'name': 'New'});
        await provider.update('products', '${saved['id']}', {
          'name': 'Changed',
        });
      } else {
        expect(
          () => provider.create('products', {}),
          throwsA(isA<PermissionDeniedException>()),
        );
        expect(
          () => provider.update('products', '1', {}),
          throwsA(isA<PermissionDeniedException>()),
        );
      }
      if (!role.canDelete) {
        expect(
          () => provider.delete('products', '1'),
          throwsA(isA<PermissionDeniedException>()),
        );
      }
      expect(
        authRedirect(
          signedIn: true,
          role: role,
          location: Uri.parse('/products/new'),
        ),
        role.canWrite ? isNull : R.forbidden,
      );
      expect(
        authRedirect(
          signedIn: true,
          role: role,
          location: Uri.parse('/products/1/edit'),
        ),
        role.canWrite ? isNull : R.forbidden,
      );
    });
  }
  test(
    'a previously obtained provider rechecks permissions after sign-out',
    () async {
      SessionUser? current = user(UserRole.admin);
      final provider = AuthorizedDataProvider(
        MockDataProvider(latency: Duration.zero),
        currentUser: () => current,
      );
      final row = await provider.create('products', {'name': 'First'});
      await provider.delete('products', '${row['id']}');
      current = null;
      expect(
        () => provider.create('products', {}),
        throwsA(isA<PermissionDeniedException>()),
      );
      expect(
        () => provider.getOne('products', '1'),
        throwsA(isA<PermissionDeniedException>()),
      );
    },
  );
  test('unknown roles deny access and recovery takes precedence over private routes', () {
    expect(UserRole.parse('superadmin'), UserRole.none);
    expect(UserRole.parse(null), UserRole.none);
    expect(
      authRedirect(
        signedIn: true,
        role: UserRole.admin,
        needsPasswordReset: true,
        location: Uri.parse('/orders'),
      ),
      R.resetPassword,
    );
    expect(
      authRedirect(signedIn: false, location: Uri.parse(R.resetPassword)),
      R.signIn,
    );
  });
}
