import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kite/core/auth/auth_repository.dart';
import 'package:kite/core/theme/app_theme.dart';
import 'package:kite/features/auth/auth_screens.dart';
import 'package:kite/l10n/app_localizations.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:kite_ui/shadcn.dart';

class _RecordingAuth extends DemoAuthRepository {
  String? verifiedToken;
  @override
  bool get isDemo => false;
  @override
  Future<void> verifyEmail({
    required String email,
    required String token,
  }) async {
    verifiedToken = token;
  }
}

void main() {
  for (final token in ['123456', '12345678', '1234567890']) {
    testWidgets('verification submits the complete $token code', (
      tester,
    ) async {
      final repo = _RecordingAuth();
      final router = GoRouter(
        initialLocation: '/verify?email=test@example.test',
        routes: [
          GoRoute(path: '/verify', builder: (_, _) => const OtpScreen()),
        ],
      );
      addTearDown(router.dispose);
      addTearDown(repo.dispose);
      await tester.runAsync(() async {
        await GlobalMaterialLocalizations.delegate.load(const Locale('en'));
        await GlobalCupertinoLocalizations.delegate.load(const Locale('en'));
        await GlobalShadLocalizations.delegate.load(const Locale('en'));
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWithValue(repo)],
          child: ShadApp.router(
            routerConfig: router,
            theme: const ThemeState().data(Brightness.light),
            localizationsDelegates: L.localizationsDelegates,
            supportedLocales: L.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).last, token);
      final submit = find.widgetWithText(KiteButton, 'Verify');
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();
      expect(repo.verifiedToken, token);
    });
  }
}
