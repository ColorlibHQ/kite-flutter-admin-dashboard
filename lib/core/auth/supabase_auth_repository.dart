import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_models.dart';
import 'auth_repository.dart';

/// Roles come from a protected database table, never editable user metadata.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(
    this.client, {
    required this.redirectUrl,
    required this.projectUrl,
    required this.publicKey,
    bool initialRecovery = false,
  }) {
    _recovery = initialRecovery;
    _subscription = client.auth.onAuthStateChange.listen(
      (event) {
        unawaited(_onAuthChange(event));
      },
      onError: (Object error, StackTrace stack) {
        _changes.addError(const AuthFailure(AuthFailureCode.connection), stack);
      },
    );
  }

  final SupabaseClient client;
  final String redirectUrl;
  final String projectUrl;
  final String publicKey;
  final _changes = StreamController<SessionUser?>.broadcast(sync: true);
  late final StreamSubscription<AuthState> _subscription;
  SessionUser? _user;
  int _generation = 0;
  (String, String?, bool)? _loadingKey;
  Future<void>? _loading;
  bool _recovery = false;
  bool _disposed = false;

  @override
  bool get isDemo => false;
  @override
  SessionUser? get currentUser => _user;
  @override
  String? get accessToken => client.auth.currentSession?.accessToken;
  @override
  Stream<SessionUser?> get changes => _changes.stream;

  /// Validate restored identity with the auth server before rendering private UI.
  Future<void> restore() async {
    if (client.auth.currentSession == null) return;
    try {
      // SDK recovery runs in the background after initialize(). Coalesce with
      // its refresh before validating an expired persisted access token.
      if (client.auth.currentSession!.isExpired) {
        await client.auth.refreshSession();
      }
      final user = (await client.auth.getUser()).user;
      await _loadUser(user);
    } on AuthException catch (error) {
      if (const {'401', '403'}.contains(error.statusCode) ||
          const {
            'session_not_found',
            'refresh_token_not_found',
            'refresh_token_already_used',
            'bad_jwt',
          }.contains(error.code)) {
        try {
          await signOut();
        } on AuthFailure {
          /* Local session is already cleared. */
        }
        return;
      }
      throw const AuthFailure(AuthFailureCode.unavailable);
    } on Object {
      throw const AuthFailure(AuthFailureCode.connection);
    }
  }

  Future<void> _onAuthChange(AuthState event) async {
    if (_disposed) return;
    if (event.event == AuthChangeEvent.passwordRecovery) _recovery = true;
    if (event.session == null) {
      _generation++;
      _loadingKey = null;
      _recovery = false;
      _user = null;
      _changes.add(null);
      return;
    }
    if (_user != null && _user!.id != event.session!.user.id) {
      _user = null;
      _changes.add(null);
    }
    try {
      await _loadUser(event.session!.user);
    } on Object catch (_, stack) {
      // Fail closed: stale permissions must not survive a failed role lookup.
      if (_disposed) return;
      _changes.addError(const AuthFailure(AuthFailureCode.connection), stack);
    }
  }

  Future<void> _loadUser(User? user) {
    if (user == null) return Future<void>.value();
    final key = (user.id, accessToken, _recovery);
    if (_loadingKey == key && _loading != null) return _loading!;
    _loadingKey = key;
    final generation = ++_generation;
    final task = _fetchUser(user, generation);
    _loading = task;
    return task.whenComplete(() {
      if (identical(_loading, task)) {
        _loading = null;
        _loadingKey = null;
      }
    });
  }

  Future<void> _fetchUser(User user, int generation) async {
    try {
      final row = await client
          .from('kite_user_roles')
          .select('role')
          .eq('user_id', user.id)
          .maybeSingle();
      if (_disposed || generation != _generation) return;
      final email = user.email ?? '';
      final name = user.userMetadata?['full_name'];
      _user = SessionUser(
        id: user.id,
        email: email,
        name: name is String && name.trim().isNotEmpty ? name.trim() : email,
        role: UserRole.parse(row?['role']),
        needsPasswordReset: _recovery,
      );
      _changes.add(_user);
    } on Object {
      if (!_disposed && generation == _generation) {
        _user = null;
        _changes.add(null);
      }
      rethrow;
    }
  }

  Future<T> _run<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on AuthException catch (error) {
      throw AuthFailure(switch (error.code) {
        'invalid_credentials' ||
        'otp_expired' => AuthFailureCode.invalidCredentials,
        'email_not_confirmed' => AuthFailureCode.unconfirmed,
        'weak_password' => AuthFailureCode.weakPassword,
        'over_request_rate_limit' ||
        'over_email_send_rate_limit' => AuthFailureCode.rateLimited,
        _ => AuthFailureCode.unavailable,
      });
    } on AuthFailure {
      rethrow;
    } on Object {
      throw const AuthFailure(AuthFailureCode.connection);
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) =>
      _run(() async {
        _recovery = false;
        final response = await client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        await _loadUser(response.user);
      });

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) => _run(() async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
      emailRedirectTo: redirectUrl,
    );
    if (response.session != null) await _loadUser(response.user);
    return response.session == null;
  });

  @override
  Future<void> verifyEmail({required String email, required String token}) =>
      _run(() async {
        final response = await client.auth.verifyOTP(
          email: email,
          token: token,
          type: OtpType.signup,
        );
        await _loadUser(response.user);
      });
  @override
  Future<void> resendVerification(String email) => _run(() async {
    await client.auth.resend(
      type: OtpType.signup,
      email: email,
      emailRedirectTo: redirectUrl,
    );
  });
  @override
  Future<void> requestPasswordReset(String email) => _run(
    () => client.auth.resetPasswordForEmail(
      email,
      redirectTo: Uri.parse(redirectUrl)
          .replace(queryParameters: {'flow': 'recovery'})
          .toString(),
    ),
  );
  @override
  Future<void> updatePassword(String password) => _run(() async {
    final response = await client.auth.updateUser(
      UserAttributes(password: password),
    );
    _recovery = false;
    await _loadUser(response.user);
  });
  @override
  Future<void> signOut() => _run(() async {
    _generation++;
    _loadingKey = null;
    _user = null;
    _changes.add(null);
    await client.auth.signOut(scope: SignOutScope.local);
  });
  @override
  Future<void> dispose() async {
    _disposed = true;
    _generation++;
    await _subscription.cancel();
    await _changes.close();
  }
}
