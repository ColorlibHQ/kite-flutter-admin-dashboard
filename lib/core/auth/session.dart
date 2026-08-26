import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class SessionUser {
  const SessionUser({
    required this.name,
    required this.email,
    this.role = 'Admin',
  });

  final String name;
  final String email;
  final String role;

  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
      .join();
}

/// Auth state for the router guard.
///
/// Deliberately trivial and in-memory: a template that demands a Firebase
/// project before anything renders loses the reader in the first minute. Swap
/// [signIn] for a real call and the guard, redirects and every screen keep
/// working unchanged.
class SessionController extends Notifier<SessionUser?> {
  @override
  SessionUser? build() => null;

  bool get isSignedIn => state != null;

  Future<void> signIn({required String email}) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final handle = email.split('@').first.replaceAll(RegExp(r'[._-]+'), ' ');
    state = SessionUser(
      name: handle.isEmpty
          ? 'Admin User'
          : handle
                .split(' ')
                .map(
                  (w) =>
                      w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}',
                )
                .join(' '),
      email: email,
    );
  }

  void signOut() => state = null;
}

final sessionProvider = NotifierProvider<SessionController, SessionUser?>(
  SessionController.new,
);
