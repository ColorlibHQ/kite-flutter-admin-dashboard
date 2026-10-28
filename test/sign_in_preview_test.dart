import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kite/core/auth/auth_repository.dart';
import 'package:kite/features/auth/auth_screens.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:url_launcher/link.dart';

import 'accessibility_test.dart' show pumpScreen;

class _ProductionAuth extends DemoAuthRepository {
  @override
  bool get isDemo => false;
}

void main() {
  testWidgets('public sample credentials let visitors enter the demo', (
    tester,
  ) async {
    final repo = DemoAuthRepository();
    addTearDown(repo.dispose);
    await pumpScreen(tester, const SignInScreen(), repository: repo);
    expect(find.text('Demo account'), findsOneWidget);
    expect(find.textContaining('Email: admin@kite.dev'), findsOneWidget);
    final fields = tester.widgetList<EditableText>(find.byType(EditableText));
    expect(fields.first.controller.text, 'admin@kite.dev');
    expect(fields.last.controller.text, 'password');
    final submit = find.widgetWithText(KiteButton, 'Sign in');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(repo.currentUser?.email, 'admin@kite.dev');
  });

  testWidgets('production login stays blank and offers a separate preview', (
    tester,
  ) async {
    final repo = _ProductionAuth();
    addTearDown(repo.dispose);
    await pumpScreen(tester, const SignInScreen(), repository: repo);
    for (final field in tester.widgetList<EditableText>(
      find.byType(EditableText),
    )) {
      expect(field.controller.text, isEmpty);
    }
    expect(find.text('you@example.com'), findsOneWidget);
    expect(find.text('Demo account'), findsNothing);
    expect(find.text('Try the public demo'), findsOneWidget);
    expect(
      tester.widget<Link>(find.byType(Link)).uri.toString(),
      'https://demo.dashboardpack.com/kite/',
    );
    expect(repo.currentUser, isNull);
  });
}
