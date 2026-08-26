import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kite/core/auth/session.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('starts signed out, which is what makes the router guard fire', () {
    expect(container.read(sessionProvider), isNull);
  });

  test('signIn derives a display name from the email handle', () async {
    await container
        .read(sessionProvider.notifier)
        .signIn(email: 'ada.lovelace@kite.dev');
    final user = container.read(sessionProvider);
    expect(user, isNotNull);
    expect(user!.name, 'Ada Lovelace');
    expect(user.email, 'ada.lovelace@kite.dev');
  });

  test('initials take the first letter of the first two words', () async {
    await container
        .read(sessionProvider.notifier)
        .signIn(email: 'grace.hopper@kite.dev');
    expect(container.read(sessionProvider)!.initials, 'GH');
  });

  test('signOut clears the session', () async {
    final notifier = container.read(sessionProvider.notifier);
    await notifier.signIn(email: 'admin@kite.dev');
    notifier.signOut();
    expect(container.read(sessionProvider), isNull);
  });
}
