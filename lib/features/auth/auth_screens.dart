import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kite_ui/kite_ui.dart';
import 'package:url_launcher/link.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/auth/session.dart';
import '../../core/router/routes.dart';
import '../../l10n/app_localizations.dart';
import 'auth_scaffold.dart';

const _demoEmail = 'admin@kite.dev';
const _demoPassword = 'password';
const _publicPreviewUrl = String.fromEnvironment(
  'KITE_PREVIEW_URL',
  defaultValue: 'https://demo.dashboardpack.com/kite/',
);

String authFailureMessage(L l, AuthFailure failure) => switch (failure.code) {
  AuthFailureCode.invalidCredentials => l.authInvalidCredentials,
  AuthFailureCode.unconfirmed => l.authUnconfirmed,
  AuthFailureCode.weakPassword => l.authWeakPassword,
  AuthFailureCode.rateLimited => l.authRateLimited,
  AuthFailureCode.connection => l.authConnectionError,
  AuthFailureCode.unavailable => l.authUnavailable,
};

String _authPath(BuildContext context, String path, {String? email}) => Uri(
  path: path,
  queryParameters: {
    if (GoRouterState.of(context).uri.queryParameters['from']
        case final String from)
      'from': from,
    'email': ?email,
  },
).toString();

bool _validEmail(String value) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);

mixin _AuthActions<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool busy = false;
  String? validation;
  AuthFailure? failure;
  String? get error =>
      validation ??
      (failure == null ? null : authFailureMessage(L.of(context), failure!));
  void invalid(String message) => setState(() => validation = message);
  Future<void> run(Future<void> Function() action) async {
    if (busy) return;
    setState(() {
      busy = true;
      validation = null;
      failure = null;
    });
    try {
      await action();
    } on AuthFailure catch (e) {
      if (mounted) setState(() => failure = e);
    } on Object {
      if (mounted) {
        setState(() => failure = const AuthFailure(AuthFailureCode.connection));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget errorNotice() => error == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(bottom: KiteSpace.md),
          child: Semantics(
            container: true,
            liveRegion: true,
            label: error,
            child: ExcludeSemantics(
              child: Text(
                error!,
                style: KiteText.of(context).small
                    .copyWith(color: KiteColors.of(context).destructive),
              ),
            ),
          ),
        );
}

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});
  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with _AuthActions<SignInScreen> {
  late final _email = TextEditingController(
    text: ref.read(authRepositoryProvider).isDemo ? _demoEmail : '',
  );
  late final _password = TextEditingController(
    text: ref.read(authRepositoryProvider).isDemo ? _demoPassword : '',
  );
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = L.of(context);
    if (!_validEmail(_email.text.trim())) return invalid(l.authInvalidEmail);
    if (!ref.read(authRepositoryProvider).isDemo && _password.text.isEmpty) {
      return invalid(l.authPasswordRequired);
    }
    await run(
      () => ref
          .read(sessionProvider.notifier)
          .signIn(email: _email.text.trim(), password: _password.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final demo = ref.watch(authRepositoryProvider).isDemo;
    return AuthScaffold(
      title: l.signInTitle,
      subtitle: demo ? l.authDemoNotice : l.authProductionSubtitle,
      fields: [
        AutofillGroup(
          child: Column(
            children: [
              AuthField(
                label: l.fieldEmail,
                controller: _email,
                hint: demo ? _demoEmail : 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.username],
                enabled: !busy,
              ),
              AuthField(
                label: l.fieldPassword,
                controller: _password,
                hint: demo ? _demoPassword : l.authPasswordRequired,
                obscure: true,
                autofillHints: const [AutofillHints.password],
                onSubmitted: (_) => _submit(),
                enabled: !busy,
              ),
            ],
          ),
        ),
        if (demo) ...[
          Container(
            padding: const EdgeInsets.all(KiteSpace.md),
            margin: const EdgeInsets.only(bottom: KiteSpace.lg),
            decoration: BoxDecoration(
              color: KiteColors.of(context).muted,
              borderRadius: KiteRadius.allSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.authDemoAccount, style: KiteText.of(context).small),
                const SizedBox(height: KiteSpace.xs),
                Text(
                  l.authDemoCredentials(_demoEmail, _demoPassword),
                  style: KiteText.of(context).small,
                ),
                const SizedBox(height: KiteSpace.sm),
                Text(l.authDemoHelp, style: KiteText.of(context).muted),
              ],
            ),
          ),
        ],
        errorNotice(),
        KiteButton(
          expands: true,
          enabled: !busy,
          onPressed: _submit,
          child: Text(busy ? l.authSigningIn : l.actionSignIn),
        ),
        const SizedBox(height: KiteSpace.md),
        KiteButton.ghost(
          onPressed: () => context.go(_authPath(context, R.forgot)),
          child: Text(l.forgotPassword),
        ),
      ],
      footer: Column(
        children: [
          KiteButton(
            variant: KiteButtonVariant.link,
            onPressed: () => context.go(_authPath(context, R.signUp)),
            child: Text(l.noAccount),
          ),
          if (!demo && _publicPreviewUrl.isNotEmpty) ...[
            const SizedBox(height: KiteSpace.md),
            Text(l.authPreviewHelp, textAlign: TextAlign.center),
            Link(
              uri: Uri.parse(_publicPreviewUrl),
              target: LinkTarget.blank,
              builder: (context, followLink) => KiteButton(
                variant: KiteButtonVariant.link,
                onPressed: followLink,
                child: Text(l.authOpenDemo),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});
  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with _AuthActions<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = L.of(context);
    if (_name.text.trim().isEmpty) {
      return invalid(l.requiredField(l.authFullName));
    }
    if (!_validEmail(_email.text.trim())) return invalid(l.authInvalidEmail);
    if (_password.text.length < 12) return invalid(l.authWeakPassword);
    await run(() async {
      final needsConfirmation = await ref
          .read(authRepositoryProvider)
          .signUp(
            email: _email.text.trim(),
            password: _password.text,
            name: _name.text.trim(),
          );
      if (mounted && needsConfirmation) {
        context.go(_authPath(context, R.otp, email: _email.text.trim()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return AuthScaffold(
      title: l.authCreateAccount,
      subtitle: l.authCreateSubtitle,
      fields: [
        AuthField(
          label: l.authFullName,
          controller: _name,
          autofillHints: const [AutofillHints.name],
          enabled: !busy,
        ),
        AuthField(
          label: l.fieldEmail,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          enabled: !busy,
        ),
        AuthField(
          label: l.fieldPassword,
          controller: _password,
          hint: l.authPasswordHint,
          obscure: true,
          autofillHints: const [AutofillHints.newPassword],
          onSubmitted: (_) => _submit(),
          enabled: !busy,
        ),
        errorNotice(),
        KiteButton(
          expands: true,
          enabled: !busy,
          onPressed: _submit,
          child: Text(busy ? l.working : l.authCreateAccount),
        ),
      ],
      footer: KiteButton(
        variant: KiteButtonVariant.link,
        onPressed: () => context.go(_authPath(context, R.signIn)),
        child: Text(l.authAlreadyAccount),
      ),
    );
  }
}

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with _AuthActions<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sent = false;
  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_validEmail(_email.text.trim())) {
      return invalid(L.of(context).authInvalidEmail);
    }
    await run(() async {
      await ref
          .read(authRepositoryProvider)
          .requestPasswordReset(_email.text.trim());
      if (mounted) setState(() => _sent = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final demo = ref.watch(authRepositoryProvider).isDemo;
    return AuthScaffold(
      title: l.authResetTitle,
      subtitle: _sent
          ? (demo ? l.authDemoNotice : l.authResetSent)
          : l.authResetSubtitle,
      fields: [
        if (!_sent) ...[
          AuthField(
            label: l.fieldEmail,
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            onSubmitted: (_) => _submit(),
            enabled: !busy,
          ),
          errorNotice(),
          KiteButton(
            expands: true,
            enabled: !busy,
            onPressed: _submit,
            child: Text(busy ? l.working : l.authSendReset),
          ),
        ],
      ],
      footer: KiteButton(
        variant: KiteButtonVariant.link,
        onPressed: () => context.go(_authPath(context, R.signIn)),
        child: Text(l.authBackToSignIn),
      ),
    );
  }
}

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});
  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with _AuthActions<OtpScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  bool _seeded = false;
  bool _sent = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_seeded) {
      _email.text =
          GoRouterState.of(context).uri.queryParameters['email'] ?? '';
      _seeded = true;
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_validEmail(_email.text.trim())) {
      return invalid(L.of(context).authInvalidEmail);
    }
    if (_code.text.length < 6 || _code.text.length > 10) {
      return invalid(L.of(context).authInvalidCredentials);
    }
    await run(
      () => ref
          .read(authRepositoryProvider)
          .verifyEmail(email: _email.text.trim(), token: _code.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return AuthScaffold(
      title: l.authVerifyTitle,
      subtitle: ref.watch(authRepositoryProvider).isDemo
          ? l.authDemoCode
          : l.authVerifySubtitle,
      fields: [
        AuthField(
          label: l.fieldEmail,
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          enabled: !busy,
        ),
        AuthField(
          label: l.authVerificationCode,
          controller: _code,
          keyboardType: TextInputType.number,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          onSubmitted: (_) => _submit(),
          enabled: !busy,
        ),
        errorNotice(),
        if (_sent) Semantics(liveRegion: true, child: Text(l.authCodeSent)),
        KiteButton(
          expands: true,
          enabled: !busy,
          onPressed: _submit,
          child: Text(busy ? l.working : l.authVerify),
        ),
        KiteButton.ghost(
          enabled: !busy,
          onPressed: () {
            if (!_validEmail(_email.text.trim())) {
              invalid(l.authInvalidEmail);
              return;
            }
            unawaited(
              run(() async {
                await ref
                    .read(authRepositoryProvider)
                    .resendVerification(_email.text.trim());
                if (mounted) setState(() => _sent = true);
              }),
            );
          },
          child: Text(l.authResend),
        ),
      ],
      footer: KiteButton(
        variant: KiteButtonVariant.link,
        onPressed: () => context.go(_authPath(context, R.signIn)),
        child: Text(l.authBackToSignIn),
      ),
    );
  }
}

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen>
    with _AuthActions<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = L.of(context);
    if (_password.text.length < 12) return invalid(l.authWeakPassword);
    if (_password.text != _confirm.text) {
      return invalid(l.authPasswordsMismatch);
    }
    await run(() async {
      await ref.read(authRepositoryProvider).updatePassword(_password.text);
      if (mounted) context.go(R.dashboard);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return AuthScaffold(
      title: l.authUpdatePassword,
      subtitle: l.authPasswordHint,
      fields: [
        AuthField(
          label: l.authNewPassword,
          controller: _password,
          obscure: true,
          autofillHints: const [AutofillHints.newPassword],
          enabled: !busy,
        ),
        AuthField(
          label: l.authConfirmPassword,
          controller: _confirm,
          obscure: true,
          autofillHints: const [AutofillHints.newPassword],
          enabled: !busy,
          onSubmitted: (_) => _submit(),
        ),
        errorNotice(),
        KiteButton(
          expands: true,
          enabled: !busy,
          onPressed: _submit,
          child: Text(busy ? l.working : l.authUpdatePassword),
        ),
      ],
      footer: KiteButton.ghost(
        onPressed: () => ref.read(sessionProvider.notifier).signOut(),
        child: Text(l.actionSignOut),
      ),
    );
  }
}

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});
  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen>
    with _AuthActions<LockScreen> {
  final _password = TextEditingController();
  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final user = ref.watch(sessionProvider);
    return AuthScaffold(
      title: l.authLockTitle,
      subtitle: user?.email ?? '',
      fields: [
        AuthField(
          label: l.fieldPassword,
          controller: _password,
          obscure: true,
          autofillHints: const [AutofillHints.password],
        ),
        errorNotice(),
        KiteButton(
          expands: true,
          enabled: !busy,
          onPressed: () => run(() async {
            await ref
                .read(sessionProvider.notifier)
                .signIn(email: user?.email ?? '', password: _password.text);
            if (context.mounted) context.go(R.dashboard);
          }),
          child: Text(busy ? l.working : l.authUnlock),
        ),
      ],
      footer: KiteButton(
        variant: KiteButtonVariant.link,
        onPressed: () => ref.read(sessionProvider.notifier).signOut(),
        child: Text(l.authOtherAccount),
      ),
    );
  }
}

class AuthCallbackScreen extends ConsumerStatefulWidget {
  const AuthCallbackScreen({super.key});
  @override
  ConsumerState<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  late final Timer _timeout;
  late final StreamSubscription<SessionUser?> _subscription;
  bool _failed = false;
  @override
  void initState() {
    super.initState();
    _timeout = Timer(const Duration(seconds: 15), () {
      if (mounted) setState(() => _failed = true);
    });
    _subscription = ref
        .read(authRepositoryProvider)
        .changes
        .listen(
          (_) {},
          onError: (Object error, StackTrace stack) {
            if (mounted) setState(() => _failed = true);
          },
        );
  }

  @override
  void dispose() {
    _timeout.cancel();
    unawaited(_subscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return AuthScaffold(
      title: l.authVerifyTitle,
      subtitle: _failed ? l.authCallbackFailed : l.working,
      fields: [
        if (!_failed) CircularProgressIndicator(semanticsLabel: l.loading),
      ],
      footer: KiteButton(
        variant: KiteButtonVariant.link,
        onPressed: () => context.go(R.signIn),
        child: Text(l.authBackToSignIn),
      ),
    );
  }
}

class ForbiddenScreen extends ConsumerWidget {
  const ForbiddenScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L.of(context);
    return AuthScaffold(
      title: l.accessDenied,
      subtitle: l.accessDeniedMessage,
      fields: [
        KiteButton(
          onPressed: () => context.go(R.settings),
          child: Text(l.navSettings),
        ),
      ],
      footer: KiteButton.ghost(
        onPressed: () => ref.read(sessionProvider.notifier).signOut(),
        child: Text(l.actionSignOut),
      ),
    );
  }
}
