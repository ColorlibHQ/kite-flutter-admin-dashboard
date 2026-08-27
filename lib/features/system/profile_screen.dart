import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/session.dart';
import '../../kite_ui/kite_ui.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final _name = TextEditingController(
    text: ref.read(sessionProvider)?.name ?? '',
  );
  late final _email = TextEditingController(
    text: ref.read(sessionProvider)?.email ?? '',
  );
  final _bio = TextEditingController(
    text: 'Runs the storefront. Mostly lives in the orders table.',
  );

  bool _weeklyDigest = true;
  bool _stockAlerts = true;
  bool _marketing = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider);
    final t = KiteText.of(context);
    final wide = KiteBreak.isDesktop(context);

    final identity = KiteCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KiteAvatar(name: user?.name ?? 'Admin', size: 76),
          const SizedBox(height: KiteSpace.md),
          Text(user?.name ?? 'Admin', style: t.large),
          Text(user?.email ?? '', style: t.muted),
          const SizedBox(height: KiteSpace.sm),
          KiteBadge(user?.role ?? 'Admin', tone: KiteTone.info),
          const SizedBox(height: KiteSpace.xl),
          KiteButton.outline(
            expands: true,
            onPressed: () => KiteToast.show(
              context,
              title: 'Nothing to upload yet',
              description: 'Wire this to your storage provider.',
            ),
            child: const Text('Change photo'),
          ),
          const SizedBox(height: KiteSpace.lg),
          const KiteSeparator(),
          const SizedBox(height: KiteSpace.md),
          const _Fact(label: 'Member since', value: 'March 2024'),
          const _Fact(label: 'Last sign-in', value: 'Today, 09:12'),
          const _Fact(label: 'Two-factor', value: 'Enabled'),
        ],
      ),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KiteCard(
          title: 'Your details',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KiteField(
                label: 'Name',
                child: KiteInput(controller: _name),
              ),
              KiteField(
                label: 'Email',
                hint: 'Used for sign-in and receipts.',
                child: KiteInput(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              KiteField(
                label: 'Bio',
                child: KiteTextarea(controller: _bio),
              ),
              Row(
                children: [
                  KiteButton(
                    onPressed: () => KiteToast.show(
                      context,
                      title: 'Profile saved',
                      tone: KiteTone.success,
                    ),
                    child: const Text('Save changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: KiteSpace.xl),
        KiteCard(
          title: 'Notifications',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KiteSwitch(
                value: _weeklyDigest,
                label: 'Weekly digest',
                sublabel: 'A summary of orders and revenue every Monday.',
                onChanged: (v) => setState(() => _weeklyDigest = v),
              ),
              const SizedBox(height: KiteSpace.lg),
              KiteSwitch(
                value: _stockAlerts,
                label: 'Low stock alerts',
                sublabel: 'When a product drops below its reorder point.',
                onChanged: (v) => setState(() => _stockAlerts = v),
              ),
              const SizedBox(height: KiteSpace.lg),
              KiteSwitch(
                value: _marketing,
                label: 'Product news',
                sublabel: 'Occasional updates. No more than monthly.',
                onChanged: (v) => setState(() => _marketing = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: KiteSpace.xl),
        KiteCard(
          title: 'Danger zone',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deleting your account removes every order, customer and '
                'product you own. It cannot be undone.',
                style: t.muted,
              ),
              const SizedBox(height: KiteSpace.lg),
              KiteButton.destructive(
                onPressed: () async {
                  final ok = await kiteConfirm(
                    context,
                    title: 'Delete your account?',
                    message:
                        'Every order, customer and product you own goes with '
                        'it. This cannot be undone.',
                    confirmLabel: 'Delete account',
                  );
                  if (!ok || !context.mounted) return;
                  KiteToast.show(
                    context,
                    title: 'Not in the demo',
                    description: 'The mock provider has nothing to delete.',
                  );
                },
                child: const Text('Delete account'),
              ),
            ],
          ),
        ),
      ],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KiteSpace.xl),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 300, child: identity),
                    const SizedBox(width: KiteSpace.xl),
                    Expanded(child: details),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    identity,
                    const SizedBox(height: KiteSpace.xl),
                    details,
                  ],
                ),
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: t.muted.copyWith(fontSize: 12))),
          Text(value, style: t.small.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}
