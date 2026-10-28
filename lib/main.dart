import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/auth/auth_config.dart';
import 'core/auth/auth_repository.dart';
import 'core/auth/secure_session_storage.dart';
import 'core/auth/supabase_auth_repository.dart';
import 'core/preferences/preferences_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await _start();
}

Future<void> _start() async {
  PreferencesStore? preferences;
  SupabaseAuthRepository? repository;
  try {
    const config = AuthConfig.environment;
    config.validate();
    preferences = await PreferencesStore.load();
    if (config.isProduction) {
      final initialUri = kIsWeb ? Uri.base : await AppLinks().getInitialLink();
      final storageKey = 'kite.auth.${Uri.parse(config.url).host}';
      final supabase = await Supabase.initialize(
        url: config.url,
        publishableKey: config.publicKey,
        authOptions: FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
          pkceAsyncStorage: kIsWeb ? null : SecurePKCEStorage(storageKey),
          localStorage: kIsWeb
              ? SharedPreferencesLocalStorage(persistSessionKey: storageKey)
              : SecureSessionStorage(storageKey),
          detectSessionInUriPredicate: (uri) =>
              uri.path.endsWith('/auth/callback'),
        ),
      );
      repository = SupabaseAuthRepository(
        supabase.client,
        redirectUrl: config.redirectUrl,
        projectUrl: config.url,
        publicKey: config.publicKey,
        initialRecovery: initialUri?.queryParameters['flow'] == 'recovery',
      );
      await repository.restore();
    }
    runApp(
      ProviderScope(
        overrides: [
          preferencesStoreProvider.overrideWithValue(preferences),
          if (repository != null)
            authRepositoryProvider.overrideWithValue(repository),
        ],
        child: const KiteApp(),
      ),
    );
  } on Object {
    preferences?.dispose();
    await repository?.dispose();
    // Do not render exception details: auth callback URLs can contain tokens.
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Kite could not start. Check your connection and app configuration.',
                  ),
                  SizedBox(height: 16),
                  FilledButton(onPressed: _start, child: Text('Try again')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
