import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kite/core/auth/auth_config.dart';

void main() {
  const valid = AuthConfig(
    url: 'https://example.supabase.co',
    publicKey: 'sb_publishable_test',
    redirectUrl: 'https://example.com/admin/auth/callback',
  );
  test('production requires complete configuration and a safe callback', () {
    expect(valid.validate, returnsNormally);
    for (final config in [
      const AuthConfig(url: 'https://example.supabase.co'),
      const AuthConfig(publicKey: 'sb_publishable_test'),
      const AuthConfig(
        url: 'http://example.com',
        publicKey: 'sb_publishable_test',
        redirectUrl: 'https://example.com/auth/callback',
      ),
      const AuthConfig(
        url: 'https://example.supabase.co',
        publicKey: 'sb_secret_test',
        redirectUrl: 'https://example.com/auth/callback',
      ),
      const AuthConfig(
        url: 'https://example.supabase.co',
        publicKey: 'sb_publishable_test',
        redirectUrl: 'javascript:alert(1)',
      ),
      const AuthConfig(
        url: 'https://example.supabase.co',
        publicKey: 'sb_publishable_test',
        redirectUrl: 'https://example.com/auth/callback',
        demo: true,
      ),
      const AuthConfig(apiUrl: 'https://api.example.com'),
      const AuthConfig(
        url: 'https://example.supabase.co',
        publicKey: 'sb_publishable_test',
        redirectUrl: 'https://example.com/auth/callback',
        apiUrl: 'http://api.example.com',
      ),
      const AuthConfig(redirectUrl: 'https://example.com/auth/callback'),
    ]) {
      expect(config.validate, throwsStateError);
    }
  });
  test('legacy JWT service-role keys are rejected before initialization', () {
    String key(String role) =>
        'header.${base64Url.encode(utf8.encode(jsonEncode({'role': role})))}.signature';
    expect(
      AuthConfig(
        url: valid.url,
        publicKey: key('service_role'),
        redirectUrl: valid.redirectUrl,
      ).validate,
      throwsStateError,
    );
    expect(
      AuthConfig(
        url: valid.url,
        publicKey: key('anon'),
        redirectUrl: valid.redirectUrl,
      ).validate,
      returnsNormally,
    );
  });
  test('an explicit remote-data demo remains possible without real auth', () {
    expect(
      const AuthConfig(apiUrl: 'https://api.example.com', demo: true).validate,
      returnsNormally,
    );
    expect(
      const AuthConfig(
        url: 'http://127.0.0.1:54321',
        publicKey: 'sb_publishable_test',
        redirectUrl: 'kite://login/auth/callback',
      ).validate,
      returnsNormally,
    );
  });
}
