import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kite/core/auth/auth_models.dart';
import 'package:kite/core/auth/supabase_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  const userId = '00000000-0000-0000-0000-000000000001';
  final userJson = <String, dynamic>{
    'id': userId, 'aud': 'authenticated', 'role': 'authenticated',
    'email': 'ada@example.com', 'created_at': '2026-01-01T00:00:00Z',
    // Neither metadata object may grant an administrator role.
    'app_metadata': {'role': 'admin'},
    'user_metadata': {'full_name': 'Ada', 'role': 'admin'},
  };
  var tokenSerial = 0;
  Map<String, dynamic> sessionJson() {
    final exp = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600;
    final header = base64Url
        .encode(utf8.encode('{"alg":"HS256"}'))
        .replaceAll('=', '');
    final payload = base64Url
        .encode(
          utf8.encode(
            jsonEncode({
              'sub': userId,
              'exp': exp,
              'role': 'authenticated',
              'jti': '${++tokenSerial}',
            }),
          ),
        )
        .replaceAll('=', '');
    return {
      'access_token': '$header.$payload.signature',
      'refresh_token': 'refresh',
      'expires_in': 3600,
      'token_type': 'bearer',
      'user': userJson,
    };
  }

  http.Response jsonResponse(
    Object body, [
    int status = 200,
    http.Request? request,
  ]) => http.Response(
    jsonEncode(body),
    status,
    headers: {
      'content-type': 'application/json',
      'x-supabase-api-version': '2024-01-01',
    },
    request: request,
  );

  late SupabaseClient client;
  late SupabaseAuthRepository repo;
  final requests = <http.Request>[];
  String? role;
  var rejectCredentials = false;
  var roleFailure = false;
  var invalidSession = false;
  Completer<void>? holdRole;

  setUp(() {
    role = 'viewer';
    rejectCredentials = false;
    roleFailure = false;
    invalidSession = false;
    holdRole = null;
    requests.clear();
    client = SupabaseClient(
      'https://example.supabase.co',
      'sb_publishable_test',
      authOptions: AuthClientOptions(
        autoRefreshToken: false,
        pkceAsyncStorage: _MemoryPKCE(),
      ),
      httpClient: MockClient((request) async {
        requests.add(request);
        if (request.url.path == '/rest/v1/kite_user_roles') {
          await holdRole?.future;
          if (roleFailure) {
            return jsonResponse({'message': 'unavailable'}, 400, request);
          }
          return jsonResponse(
            [
              if (role != null) {'role': role},
            ],
            200,
            request,
          );
        }
        if (request.url.path.endsWith('/token')) {
          if (rejectCredentials) {
            return jsonResponse(
              {'code': 'invalid_credentials', 'msg': 'Invalid credentials'},
              400,
              request,
            );
          }
          return jsonResponse(sessionJson(), 200, request);
        }
        if (request.url.path.endsWith('/signup')) {
          return jsonResponse(
            {'user': userJson, 'session': null},
            200,
            request,
          );
        }
        if (request.url.path.endsWith('/verify')) {
          return jsonResponse(sessionJson(), 200, request);
        }
        if (request.url.path.endsWith('/user') && invalidSession) {
          return jsonResponse(
            {'code': 'bad_jwt', 'msg': 'Expired'},
            401,
            request,
          );
        }
        if (request.url.path.endsWith('/user')) {
          return jsonResponse(userJson, 200, request);
        }
        return jsonResponse({}, 200, request);
      }),
    );
    repo = SupabaseAuthRepository(
      client,
      redirectUrl: 'https://app.example.com/auth/callback',
      projectUrl: 'https://example.supabase.co',
      publicKey: 'sb_publishable_test',
    );
  });
  tearDown(() async {
    await repo.dispose();
    await client.dispose();
  });

  test('password sign-in trusts the database role and forwards credentials to Auth', () async {
    await repo.signIn(email: 'ada@example.com', password: 'correct-password');
    expect(repo.currentUser?.name, 'Ada');
    expect(repo.currentUser?.role, UserRole.viewer);
    final signIn = requests.firstWhere((r) => r.url.path.endsWith('/token'));
    expect(jsonDecode(signIn.body)['password'], 'correct-password');
    expect(
      requests
          .firstWhere((r) => r.url.path.endsWith('/kite_user_roles'))
          .url
          .queryParameters['user_id'],
      'eq.$userId',
    );
    expect(repo.accessToken, isNotNull);
  });
  test('missing or unrecognized server roles fail closed', () async {
    role = null;
    await repo.signIn(email: 'ada@example.com', password: 'password');
    expect(repo.currentUser?.role, UserRole.none);
    role = 'superadmin';
    await repo.signIn(email: 'ada@example.com', password: 'password');
    expect(repo.currentUser?.role, UserRole.none);
  });
  test(
    'credential failures are mapped without exposing server messages',
    () async {
      rejectCredentials = true;
      await expectLater(
        repo.signIn(email: 'ada@example.com', password: 'wrong'),
        throwsA(
          isA<AuthFailure>().having(
            (e) => e.code,
            'code',
            AuthFailureCode.invalidCredentials,
          ),
        ),
      );
      expect(repo.currentUser, isNull);
    },
  );
  test(
    'signup, code verification, reset and password update call real endpoints',
    () async {
      expect(
        await repo.signUp(
          email: 'ada@example.com',
          password: 'long-password',
          name: 'Ada',
        ),
        isTrue,
      );
      expect(repo.currentUser, isNull);
      await repo.verifyEmail(email: 'ada@example.com', token: '123456');
      expect(repo.currentUser?.role, UserRole.viewer);
      await repo.requestPasswordReset('ada@example.com');
      await repo.updatePassword('changed-password');
      expect(requests.any((r) => r.url.path.endsWith('/recover')), isTrue);
      final update = requests.lastWhere((r) => r.url.path.endsWith('/user'));
      expect(jsonDecode(update.body)['password'], 'changed-password');
    },
  );
  test('late role lookups cannot restore a signed-out user', () async {
    holdRole = Completer<void>();
    final signIn = repo.signIn(email: 'ada@example.com', password: 'password');
    while (!requests.any((r) => r.url.path.endsWith('/kite_user_roles'))) {
      await Future<void>.delayed(Duration.zero);
    }
    await repo.signOut();
    holdRole!.complete();
    await signIn;
    expect(repo.currentUser, isNull);
    expect(repo.accessToken, isNull);
  });
  test('cold-start recovery remains on the password-update flow', () async {
    await repo.dispose();
    await client.auth.signInWithPassword(
      email: 'ada@example.com',
      password: 'password',
    );
    repo = SupabaseAuthRepository(
      client,
      redirectUrl: 'https://app.example.com/auth/callback',
      projectUrl: 'https://example.supabase.co',
      publicKey: 'sb_publishable_test',
      initialRecovery: true,
    );
    await repo.restore();
    expect(repo.currentUser?.needsPasswordReset, isTrue);
    await repo.updatePassword('new-strong-password');
    expect(repo.currentUser?.needsPasswordReset, isFalse);
  });
  test(
    'expired restored access tokens refresh before user validation',
    () async {
      await repo.signIn(email: 'ada@example.com', password: 'password');
      requests.clear();
      client.auth.currentSession!.expiresAt =
          DateTime.now().millisecondsSinceEpoch ~/ 1000 - 60;
      await repo.restore();
      expect(requests.first.url.path, '/auth/v1/token');
      expect(requests.first.url.queryParameters['grant_type'], 'refresh_token');
      expect(repo.currentUser?.id, userId);
      expect(client.auth.currentSession!.isExpired, isFalse);
    },
  );
  test('restoring an invalid session clears the saved identity', () async {
    await repo.signIn(email: 'ada@example.com', password: 'password');
    invalidSession = true;
    await repo.restore();
    expect(repo.currentUser, isNull);
    expect(repo.accessToken, isNull);
  });
  test(
    'restoration fetches current roles rather than cached metadata',
    () async {
      await repo.signIn(email: 'ada@example.com', password: 'password');
      role = 'editor';
      await repo.restore();
      expect(repo.currentUser?.role, UserRole.editor);
    },
  );
  test('token refresh updates identity roles and the bearer token', () async {
    await repo.signIn(email: 'ada@example.com', password: 'password');
    final oldToken = repo.accessToken;
    role = 'editor';
    final refreshed = repo.changes
        .firstWhere((user) => user?.role == UserRole.editor)
        .timeout(const Duration(seconds: 2));
    await client.auth.refreshSession();
    await refreshed;
    expect(repo.accessToken, isNot(oldToken));
    expect(repo.currentUser?.role, UserRole.editor);
  });
  test('role lookup errors do not grant metadata roles', () async {
    roleFailure = true;
    final subscription = repo.changes.listen(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    await expectLater(
      repo.signIn(email: 'ada@example.com', password: 'password'),
      throwsA(isA<AuthFailure>()),
    );
    expect(repo.currentUser, isNull);
    await subscription.cancel();
  });
}

class _MemoryPKCE extends GotrueAsyncStorage {
  final _values = <String, String>{};
  @override
  Future<String?> getItem({required String key}) async => _values[key];
  @override
  Future<void> setItem({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _values.remove(key);
  }
}
