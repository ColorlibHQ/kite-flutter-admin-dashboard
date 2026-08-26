import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/data_provider.dart';
import '../../core/data/mock_data_provider.dart';
import '../../kite_ui/kite_ui.dart';
import '../../shared/widgets/states.dart';

final _recentProvider = FutureProvider<ListResult>((Ref ref) async {
  return ref
      .watch(dataProvider)
      .getList(
        'orders',
        const ListParams(perPage: 8, sort: SortSpec('date', SortDir.desc)),
      );
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(_recentProvider);
    final wide = KiteBreak.isDesktop(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KiteSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KiteAlert(
            title: 'Low stock on 3 products',
            description:
                'Reorder before Friday to avoid backorders over the weekend.',
            tone: KiteTone.warning,
          ),
          const SizedBox(height: KiteSpace.xl),
          const _StatRow(),
          const SizedBox(height: KiteSpace.xl),
          if (wide)
            const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 2, child: _RevenueCard()),
                  SizedBox(width: KiteSpace.xl),
                  Expanded(child: _ChannelsCard()),
                ],
              ),
            )
          else ...[
            const _RevenueCard(),
            const SizedBox(height: KiteSpace.xl),
            const _ChannelsCard(),
          ],
          const SizedBox(height: KiteSpace.xl),
          KiteCard(
            title: 'Recent orders',
            child: recent.when(
              loading: () => const SizedBox(height: 200, child: LoadingState()),
              error: (e, _) =>
                  SizedBox(height: 200, child: ErrorState(message: '$e')),
              data: (result) => Column(
                children: [for (final row in result.rows) _OrderRow(row: row)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow();

  static const _stats = <(String, String, String, KiteTone)>[
    ('Revenue', r'$284,120', '+12.4% vs last month', KiteTone.success),
    ('Orders', '3,412', '+4.1% vs last month', KiteTone.success),
    ('Customers', '1,208', '+8.9% vs last month', KiteTone.success),
    ('Refund rate', '1.4%', '-0.3% vs last month', KiteTone.danger),
  ];

  @override
  Widget build(BuildContext context) {
    final columns = KiteBreak.isMobile(context)
        ? 1
        : (KiteBreak.isTablet(context) ? 2 : 4);
    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: KiteSpace.lg,
      crossAxisSpacing: KiteSpace.lg,
      childAspectRatio: columns == 1 ? 3.4 : 2.1,
      children: [
        for (final (label, value, delta, tone) in _stats)
          KiteStat(label: label, value: value, delta: delta, deltaTone: tone),
      ],
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard();

  @override
  Widget build(BuildContext context) {
    final rnd = Random(9);
    var y = 42.0;
    final spots = <(double, double)>[];
    for (var i = 0; i < 60; i++) {
      y = (y + rnd.nextDouble() * 11 - 4.6).clamp(12, 92);
      spots.add((i.toDouble(), y));
    }
    return KiteCard(
      title: 'Revenue',
      trailing: const KiteBadge('Last 60 days', tone: KiteTone.info),
      child: SizedBox(height: 220, child: KiteLineChart(spots: spots)),
    );
  }
}

class _ChannelsCard extends StatelessWidget {
  const _ChannelsCard();

  static const _channels = <(String, double)>[
    ('Direct', 0.42),
    ('Organic search', 0.27),
    ('Referral', 0.18),
    ('Email', 0.13),
  ];

  @override
  Widget build(BuildContext context) {
    return KiteCard(
      title: 'Traffic by channel',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final (label, share) in _channels)
            KiteMeter(label: label, value: share),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.row});
  final JsonMap row;

  static KiteTone _tone(String status) => switch (status) {
    'Paid' || 'Shipped' => KiteTone.success,
    'Pending' => KiteTone.warning,
    'Refunded' => KiteTone.info,
    'Cancelled' => KiteTone.danger,
    _ => KiteTone.neutral,
  };

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final status = '${row['status']}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              '${row['reference']}',
              style: t.small.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
                color: c.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${row['customer']}',
              style: t.p.copyWith(fontSize: 14),
            ),
          ),
          KiteBadge(status, tone: _tone(status)),
          const SizedBox(width: KiteSpace.xl),
          SizedBox(
            width: 92,
            child: Text(
              KiteFormat.money(row['total']),
              textAlign: TextAlign.right,
              style: t.p.copyWith(
                fontSize: 14,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
