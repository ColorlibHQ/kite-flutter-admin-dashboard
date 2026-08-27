import 'package:flutter/material.dart';

import '../../kite_ui/kite_ui.dart';

/// The showcase.
///
/// Every template is judged on one page, and this is it: the reader wants to
/// know what they get before they read a line of source. So it shows real,
/// working controls with real state — nothing here is a picture of a control.
class ComponentsScreen extends StatefulWidget {
  const ComponentsScreen({super.key});
  @override
  State<ComponentsScreen> createState() => _ComponentsScreenState();
}

class _ComponentsScreenState extends State<ComponentsScreen> {
  bool _checkbox = true;
  bool _switchOn = true;
  double _slider = 42;
  DateTime? _date;
  String? _fruit;
  final _input = TextEditingController();
  final _textarea = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    _textarea.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = KiteBreak.isDesktop(context);

    final sections = <Widget>[
      _Section(
        title: 'Buttons',
        description:
            'Six variants, each with optional leading and trailing icons.',
        child: Wrap(
          spacing: KiteSpace.md,
          runSpacing: KiteSpace.md,
          children: [
            KiteButton(onPressed: () {}, child: const Text('Primary')),
            KiteButton.secondary(
              onPressed: () {},
              child: const Text('Secondary'),
            ),
            KiteButton.outline(onPressed: () {}, child: const Text('Outline')),
            KiteButton.ghost(onPressed: () {}, child: const Text('Ghost')),
            KiteButton.destructive(
              onPressed: () {},
              child: const Text('Destructive'),
            ),
            KiteButton.outline(
              leading: const Icon(Icons.download, size: 16),
              onPressed: () {},
              child: const Text('With icon'),
            ),
            const KiteButton(enabled: false, child: Text('Disabled')),
          ],
        ),
      ),
      const _Section(
        title: 'Status badges',
        description:
            'Semantic tone, separate from the brand accent — state reads at a '
            'glance without parsing the label.',
        child: Wrap(
          spacing: KiteSpace.sm,
          runSpacing: KiteSpace.sm,
          children: [
            KiteBadge('Neutral'),
            KiteBadge('Paid', tone: KiteTone.success),
            KiteBadge('Pending', tone: KiteTone.warning),
            KiteBadge('Cancelled', tone: KiteTone.danger),
            KiteBadge('Refunded', tone: KiteTone.info),
          ],
        ),
      ),
      _Section(
        title: 'Inputs',
        description: 'Labels sit outside the control so they never move.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KiteField(
              label: 'Email',
              hint: 'We only use this for receipts.',
              child: KiteInput(
                controller: _input,
                placeholder: 'you@company.com',
              ),
            ),
            KiteField(
              label: 'Notes',
              child: KiteTextarea(
                controller: _textarea,
                placeholder: 'Anything the warehouse should know…',
              ),
            ),
            KiteField(
              label: 'Category',
              child: KiteSelect<String>(
                options: const ['Hardware', 'Software', 'Services'],
                labelOf: (v) => v,
                value: _fruit,
                placeholder: 'Choose one',
                onChanged: (v) => setState(() => _fruit = v),
              ),
            ),
            KiteField(
              label: 'Ship date',
              child: KiteDatePicker(
                selected: _date,
                onChanged: (v) => setState(() => _date = v),
              ),
            ),
            const KiteField(
              label: 'Validation',
              error: 'Enter an address with an @ in it.',
              child: KiteInput(placeholder: 'broken@'),
            ),
          ],
        ),
      ),
      _Section(
        title: 'Toggles',
        description: 'All wired to real state — flip them.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KiteCheckbox(
              value: _checkbox,
              label: 'Email me when stock runs low',
              sublabel: 'At most one message a day.',
              onChanged: (v) => setState(() => _checkbox = v),
            ),
            const SizedBox(height: KiteSpace.lg),
            KiteSwitch(
              value: _switchOn,
              label: 'Two-factor authentication',
              sublabel: 'Required for admin accounts.',
              onChanged: (v) => setState(() => _switchOn = v),
            ),
            const SizedBox(height: KiteSpace.xl),
            Text(
              'Discount — ${_slider.round()}%',
              style: KiteText.of(context).small,
            ),
            const SizedBox(height: KiteSpace.sm),
            KiteSlider(
              value: _slider,
              onChanged: (v) => setState(() => _slider = v),
            ),
          ],
        ),
      ),
      const _Section(
        title: 'Alerts',
        description: 'Inline notices for state the page has to explain.',
        child: Column(
          children: [
            KiteAlert(
              title: 'Mock data provider',
              description:
                  'Search, filter, sort and pagination all execute server-side. '
                  'Swap one line for a REST adapter.',
            ),
            SizedBox(height: KiteSpace.md),
            KiteAlert(
              title: 'Low stock on 3 products',
              description: 'Reorder before Friday to avoid backorders.',
              tone: KiteTone.warning,
            ),
            SizedBox(height: KiteSpace.md),
            KiteAlert(
              title: 'Payment gateway unreachable',
              description:
                  'Retrying every 30 seconds. Orders are queued, not lost.',
              tone: KiteTone.danger,
            ),
          ],
        ),
      ),
      _Section(
        title: 'Overlays',
        description: 'Dialogs, drawers and toasts — the three ways an admin answers back.',
        child: Wrap(
          spacing: KiteSpace.md,
          runSpacing: KiteSpace.md,
          children: [
            KiteButton.outline(
              onPressed: () => KiteToast.show(
                context,
                title: 'Saved',
                description: 'Your changes are live.',
                tone: KiteTone.success,
              ),
              child: const Text('Show toast'),
            ),
            KiteButton.outline(
              onPressed: () => KiteToast.show(
                context,
                title: 'Could not reach the server',
                description: 'Check your connection and try again.',
                tone: KiteTone.danger,
              ),
              child: const Text('Error toast'),
            ),
            KiteButton.outline(
              onPressed: () async {
                final ok = await kiteConfirm(
                  context,
                  title: 'Delete this order?',
                  message: 'Order #10042 will be removed permanently. This cannot be undone.',
                );
                if (ok && context.mounted) {
                  KiteToast.show(
                    context,
                    title: 'Order deleted',
                    tone: KiteTone.danger,
                  );
                }
              },
              child: const Text('Confirm dialog'),
            ),
            KiteButton.outline(
              onPressed: () => kiteSheet<void>(
                context,
                title: 'Order #10042',
                description: 'Placed 24 August 2026 by Ada Lovelace.',
                body: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DetailRow(label: 'Status', value: 'Shipped'),
                    _DetailRow(label: 'Items', value: '3'),
                    _DetailRow(label: 'Total', value: r'$412.90'),
                    _DetailRow(label: 'Carrier', value: 'DHL Express'),
                  ],
                ),
              ),
              child: const Text('Detail drawer'),
            ),
            KiteTooltip(
              message: 'Tooltips work on hover and long-press',
              child: KiteButton.ghost(
                onPressed: () {},
                child: const Text('Hover me'),
              ),
            ),
          ],
        ),
      ),
      const _Section(
        title: 'People and progress',
        description:
            'Avatars fall back to initials, because admin tables rarely '
            'have photographs.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                KiteAvatar(name: 'Ada Lovelace', size: 40),
                SizedBox(width: KiteSpace.md),
                KiteAvatar(name: 'Grace Hopper', size: 40),
                SizedBox(width: KiteSpace.md),
                KiteAvatar(name: 'Linus Torvalds', size: 40),
                SizedBox(width: KiteSpace.md),
                KiteAvatar(name: 'Radia Perlman', size: 40),
              ],
            ),
            SizedBox(height: KiteSpace.xl),
            KiteMeter(
              label: 'Storage used',
              value: 0.72,
              trailing: '72 of 100 GB',
            ),
            KiteMeter(label: 'API quota', value: 0.31, trailing: '31%'),
            KiteMeter(label: 'Seats', value: 0.9, trailing: '18 of 20'),
          ],
        ),
      ),
      const _Section(
        title: 'Stat tiles',
        description: 'Direction is encoded in colour as well as sign.',
        child: Row(
          children: [
            Expanded(
              child: KiteStat(
                label: 'Revenue',
                value: r'$284,120',
                delta: '+12.4%',
                deltaTone: KiteTone.success,
              ),
            ),
            SizedBox(width: KiteSpace.lg),
            Expanded(
              child: KiteStat(
                label: 'Refund rate',
                value: '1.4%',
                delta: '-0.3%',
                deltaTone: KiteTone.danger,
              ),
            ),
          ],
        ),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KiteSpace.xl),
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: wide
              ? _Masonry(children: sections)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final s in sections) ...[
                      s,
                      const SizedBox(height: KiteSpace.xl),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

/// Two balanced columns. Sections have wildly different heights, so a grid
/// would leave ragged gaps.
class _Masonry extends StatelessWidget {
  const _Masonry({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final left = <Widget>[];
    final right = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      (i.isEven ? left : right).add(children[i]);
    }
    Widget column(List<Widget> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final w in items) ...[w, const SizedBox(height: KiteSpace.xl)],
      ],
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: column(left)),
        const SizedBox(width: KiteSpace.xl),
        Expanded(child: column(right)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    return KiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: t.large),
          const SizedBox(height: KiteSpace.xs),
          Text(description, style: t.muted),
          const SizedBox(height: KiteSpace.xl),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KiteSpace.sm),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: t.muted)),
          Expanded(child: Text(value, style: t.p.copyWith(fontSize: 14))),
        ],
      ),
    );
  }
}
