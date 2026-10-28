import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_models.dart';

abstract interface class AuthRepository {
  bool get isDemo;
  SessionUser? get currentUser;
  String? get accessToken;
  Stream<SessionUser?> get changes;
  Future<void> signIn({required String email, required String password});

  /// Returns true when email confirmation is required.
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<void> verifyEmail({required String email, required String token});
  Future<void> resendVerification(String email);
  Future<void> requestPasswordReset(String email);
  Future<void> updatePassword(String password);
  Future<void> signOut();
  Future<void> dispose();
}

const kDemoAutoSignIn = bool.fromEnvironment('KITE_DEMO');

/// Isolated sample identity: never persists a session or grants backend roles.
class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository({bool autoSignIn = false}) {
    if (autoSignIn) _user = _demoUser('ada@kite.dev');
  }
  SessionUser? _user;
  final _changes = StreamController<SessionUser?>.broadcast(sync: true);
  @override
  bool get isDemo => true;
  @override
  SessionUser? get currentUser => _user;
  @override
  String? get accessToken => null;
  @override
  Stream<SessionUser?> get changes => _changes.stream;

  SessionUser _demoUser(String email) {
    final handle = email.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ');
    return SessionUser(
      id: email,
      name: handle.isEmpty
          ? 'Admin User'
          : handle
                .split(' ')
                .where((w) => w.isNotEmpty)
                .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
                .join(' '),
      email: email,
      role: UserRole.admin,
    );
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    _user = _demoUser(email);
    _changes.add(_user);
  }

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async => true;
  @override
  Future<void> verifyEmail({
    required String email,
    required String token,
  }) async {
    if (token != '123456') {
      throw const AuthFailure(AuthFailureCode.invalidCredentials);
    }
    await signIn(email: email, password: '');
  }

  @override
  Future<void> resendVerification(String email) async {}
  @override
  Future<void> requestPasswordReset(String email) async {}
  @override
  Future<void> updatePassword(String password) async {}
  @override
  Future<void> signOut() async {
    _user = null;
    _changes.add(null);
  }

  @override
  Future<void> dispose() => _changes.close();
}

/// Bootstrap overrides this for a configured identity provider.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repo = DemoAuthRepository(autoSignIn: kDemoAutoSignIn);
  ref.onDispose(() => unawaited(repo.dispose()));
  return repo;
});
