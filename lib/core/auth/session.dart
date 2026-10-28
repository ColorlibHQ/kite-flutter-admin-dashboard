import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_models.dart';
import 'auth_repository.dart';

export 'auth_models.dart';
export 'auth_repository.dart' show kDemoAutoSignIn;

class SessionController extends Notifier<SessionUser?> {
  @override
  SessionUser? build() {
    final repository = ref.watch(authRepositoryProvider);
    final subscription = repository.changes.listen(
      (user) => state = user,
      // Transient refresh failures leave SDK retry/session handling in charge.
      // Explicit sign-out/revocation events still clear state immediately.
      onError: (Object error, StackTrace stack) {},
    );
    ref.onDispose(() => unawaited(subscription.cancel()));
    return repository.currentUser;
  }

  bool get isSignedIn => state != null;

  Future<void> signIn({required String email, String password = ''}) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signIn(email: email, password: password);
    if (ref.mounted) state = repo.currentUser;
  }

  Future<void> signOut() async {
    state = null;
    try {
      await ref.read(authRepositoryProvider).signOut();
    } on AuthFailure {
      // The SDK clears its local session before attempting remote revocation.
      // Offline revocation must not resurrect a signed-out local identity.
    }
  }
}

final sessionProvider = NotifierProvider<SessionController, SessionUser?>(
  SessionController.new,
);
