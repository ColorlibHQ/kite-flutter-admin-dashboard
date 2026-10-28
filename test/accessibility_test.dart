import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kite/core/auth/auth_repository.dart';
import 'package:kite/core/theme/app_theme.dart';
import 'package:kite/features/auth/auth_screens.dart';
import 'package:kite/features/system/settings_screen.dart';
import 'package:kite/l10n/app_localizations.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:kite_ui/shadcn.dart';

Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  AuthRepository? repository,
  String locale = 'en',
  Brightness brightness = Brightness.light,
  double scale = 1,
  KiteAccent accent = KiteAccent.slate,
}) async {
  await tester.runAsync(() async {
    await GlobalMaterialLocalizations.delegate.load(Locale(locale));
    await GlobalCupertinoLocalizations.delegate.load(Locale(locale));
    await GlobalShadLocalizations.delegate.load(Locale(locale));
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (repository != null)
          authRepositoryProvider.overrideWithValue(repository),
      ],
      child: ShadApp(
        key: UniqueKey(),
        locale: Locale(locale),
        supportedLocales: L.supportedLocales,
        localizationsDelegates: L.localizationsDelegates,
        theme: ThemeState(accent: accent).data(brightness),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(body: screen),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'sign-in has labeled targets, sufficient contrast and touch targets in $brightness',
      (tester) async {
        final semantics = tester.ensureSemantics();

        await pumpScreen(tester, const SignInScreen(), brightness: brightness);
        expect(find.bySemanticsLabel(RegExp('Email')), findsWidgets);
        expect(find.bySemanticsLabel(RegExp('Password')), findsWidgets);
        expect(
          tester
              .getSemantics(find.byType(EditableText).first)
              .getSemanticsData()
              .label,
          contains('Email'),
        );
        expect(
          tester
              .getSemantics(find.byType(EditableText).last)
              .getSemanticsData()
              .label,
          contains('Password'),
        );
        expect(
          tester
              .getSemantics(find.byType(EditableText).first)
              .getSemanticsData()
              .flagsCollection
              .isEnabled,
          Tristate.isTrue,
        );
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        semantics.dispose();
      },
    );
  }
  for (final accent in KiteAccent.values) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'all action variants have readable contrast in $accent $brightness',
        (tester) async {
          final semantics = tester.ensureSemantics();
          await pumpScreen(
            tester,
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final variant in KiteButtonVariant.values)
                  KiteButton(
                    variant: variant,
                    onPressed: () {},
                    child: Text(variant.name),
                  ),
              ],
            ),
            accent: accent,
            brightness: brightness,
          );
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          semantics.dispose();
        },
      );
    }
  }
  for (final locale in ['en', 'es', 'fr', 'ja', 'ar']) {
    testWidgets(
      '$locale auth and settings remain usable at narrow width and 200% text',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await pumpScreen(
          tester,
          const SignInScreen(),
          locale: locale,
          scale: 2,
        );
        expect(tester.takeException(), isNull);
        final context = tester.element(find.byType(SignInScreen));
        expect(
          Directionality.of(context),
          locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        );
        await pumpScreen(
          tester,
          const SettingsScreen(),
          locale: locale,
          scale: 2,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'sign-in supports keyboard submission and announces validation errors',
    (tester) async {
      final semantics = tester.ensureSemantics();

      await pumpScreen(tester, const SignInScreen());
      await tester.enterText(find.byType(EditableText).first, 'invalid');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      // The first field advances focus; the password field submits the form.
      await tester.tap(find.byType(EditableText).last);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(
        tester
            .getSemantics(
              find.byWidgetPredicate(
                (widget) =>
                    widget is Semantics &&
                    widget.properties.label == 'Enter a valid email address.',
              ),
            )
            .getSemanticsData()
            .flagsCollection
            .isLiveRegion,
        isTrue,
      );
      semantics.dispose();
    },
  );
}
