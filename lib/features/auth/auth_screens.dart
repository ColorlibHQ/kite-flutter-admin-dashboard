import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/session.dart';
import '../../core/router/routes.dart';
import '../../kite_ui/kite_ui.dart';
import 'auth_scaffold.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});
  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController(text: 'admin@kite.dev');
  final _password = TextEditingController(text: 'password');
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    await ref.read(sessionProvider.notifier).signIn(email: email);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    return AuthScaffold(
      title: 'Sign in',
      subtitle: 'Any email works — this is the mock provider.',
      fields: [
        AuthField(
          label: 'Email',
          controller: _email,
          hint: 'you@company.com',
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
        ),
        AuthField(
          label: 'Password',
          controller: _password,
          obscure: true,
          autofillHints: const [AutofillHints.password],
          onSubmitted: (_) => _submit(),
        ),
        if (_error != null) ...[
          Text(
            _error!,
            style: t.small.copyWith(color: KiteColors.of(context).destructive),
          ),
          const SizedBox(height: KiteSpace.md),
        ],
        KiteButton(
          expands: true,
          enabled: !_busy,
          onPressed: _submit,
          child: Text(_busy ? 'Signing in…' : 'Sign in'),
        ),
        const SizedBox(height: KiteSpace.md),
        KiteButton.ghost(
          expands: true,
          onPressed: () => context.go(R.forgot),
          child: const Text('Forgot password?'),
        ),
      ],
      footer: GestureDetector(
        onTap: () => context.go(R.signUp),
        child: const Text('No account? Create one'),
      ),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
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

  @override
  Widget build(BuildContext context) => AuthScaffold(
    title: 'Create account',
    subtitle: 'Fourteen days, no card required.',
    fields: [
      AuthField(label: 'Full name', controller: _name, hint: 'Ada Lovelace'),
      AuthField(
        label: 'Email',
        controller: _email,
        hint: 'you@company.com',
        keyboardType: TextInputType.emailAddress,
      ),
      AuthField(label: 'Password', controller: _password, obscure: true),
      KiteButton(
        expands: true,
        onPressed: () => context.go(R.otp),
        child: const Text('Create account'),
      ),
    ],
    footer: GestureDetector(
      onTap: () => context.go(R.signIn),
      child: const Text('Already have an account? Sign in'),
    ),
  );
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    return AuthScaffold(
      title: 'Reset password',
      subtitle: _sent
          ? 'Check your inbox for the reset link.'
          : 'We will email you a link to choose a new one.',
      fields: [
        if (!_sent) ...[
          AuthField(
            label: 'Email',
            controller: _email,
            hint: 'you@company.com',
            keyboardType: TextInputType.emailAddress,
          ),
          KiteButton(
            expands: true,
            onPressed: () => setState(() => _sent = true),
            child: const Text('Send reset link'),
          ),
        ] else
          Row(
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 18,
                color: KiteColors.of(context).mutedForeground,
              ),
              const SizedBox(width: KiteSpace.sm),
              Expanded(child: Text('Sent to ${_email.text}', style: t.small)),
            ],
          ),
      ],
      footer: GestureDetector(
        onTap: () => context.go(R.signIn),
        child: const Text('Back to sign in'),
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return AuthScaffold(
      title: 'Verify your email',
      subtitle: 'Enter the six-digit code we just sent.',
      fields: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < 6; i++)
              SizedBox(
                width: 46,
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _nodes[i],
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  keyboardType: TextInputType.number,
                  style: t.h4,
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
                    if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
                  },
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    filled: true,
                    fillColor: c.background,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: KiteRadius.allSm,
                      borderSide: BorderSide(color: c.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: KiteRadius.allSm,
                      borderSide: BorderSide(color: c.ring, width: 1.5),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: KiteSpace.xl),
        KiteButton(
          expands: true,
          onPressed: () => context.go(R.signIn),
          child: const Text('Verify'),
        ),
      ],
      footer: const Text("Didn't get it? Resend in 0:30"),
    );
  }
}

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});
  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return AuthScaffold(
      title: 'Screen locked',
      subtitle: 'Enter your password to pick up where you left off.',
      fields: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: c.muted, shape: BoxShape.circle),
              child: Text('AL', style: t.small),
            ),
            const SizedBox(width: KiteSpace.md),
            Text('Ada Lovelace', style: t.p),
          ],
        ),
        const SizedBox(height: KiteSpace.xl),
        AuthField(label: 'Password', controller: _password, obscure: true),
        KiteButton(
          expands: true,
          onPressed: () =>
              ref.read(sessionProvider.notifier).signIn(email: 'ada@kite.dev'),
          child: const Text('Unlock'),
        ),
      ],
      footer: GestureDetector(
        onTap: () => context.go(R.signIn),
        child: const Text('Sign in as someone else'),
      ),
    );
  }
}
