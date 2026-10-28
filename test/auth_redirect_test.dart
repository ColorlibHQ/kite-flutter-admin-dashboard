import 'package:flutter_test/flutter_test.dart';
import 'package:kite/core/router/auth_redirect.dart';
import 'package:kite/core/router/routes.dart';

void main() {
  test('sign-in preserves the full bookmarked destination', () {
    final destination = Uri.parse('/orders/10004?tab=history#payment');
    final redirect = Uri.parse(
      authRedirect(signedIn: false, location: destination)!,
    );
    expect(redirect.path, R.signIn);
    expect(redirect.queryParameters['from'], destination.toString());
    expect(authRedirect(signedIn: true, location: redirect), '$destination');
  });

  test('signed-out visitors can reach every authentication screen', () {
    for (final path in [R.signIn, R.signUp, R.forgot, R.otp]) {
      expect(authRedirect(signedIn: false, location: Uri.parse(path)), isNull);
    }
  });

  test('signed-in visitors stay on resource pages', () {
    expect(
      authRedirect(signedIn: true, location: Uri.parse('/customers/42/edit')),
      isNull,
    );
  });

  test('auth-like prefixes do not bypass the guard', () {
    expect(
      authRedirect(signedIn: false, location: Uri.parse('/sign-in-extra')),
      startsWith('/sign-in?'),
    );
  });

  test('unsafe, malformed and looping return locations use the dashboard', () {
    for (final from in [
      '',
      'https://example.com/orders',
      '//example.com/orders',
      'orders/42',
      '/\\example.com',
      'http://[',
      '/sign-in',
      '/sign-up?from=/orders',
    ]) {
      expect(
        authRedirect(
          signedIn: true,
          location: Uri(path: R.signIn, queryParameters: {'from': from}),
        ),
        R.dashboard,
        reason: 'Return location: $from',
      );
    }
  });
}
