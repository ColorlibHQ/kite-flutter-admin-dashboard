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
        const ListParams(perPage: 6, sort: SortSpec('date', SortDir.desc)),
      );
});

final _topProductsProvider = FutureProvider<ListResult>((Ref ref) async {
  return ref
      .watch(dataProvider)
      .getList(
        'products',
        const ListParams(perPage: 5, sort: SortSpec('price', SortDir.desc)),
      );
});

/// The dashboard.
///
/// This is the screenshot the product is judged on before anyone clones it, so
/// it earns more than four tiles and a line chart: trend in every stat, a
/// ranked breakdown, a funnel, an activity feed and live tables — each one a
/// different shape, because a page of identical cards reads as filler.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = KiteBreak.isDesktop(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KiteSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StatRow(),
          const SizedBox(height: KiteSpace.xl),
          if (wide)
            const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 5, child: _RevenueCard()),
                  SizedBox(width: KiteSpace.xl),
                  Expanded(flex: 3, child: _FunnelCard()),
                ],
              ),
            )
          else ...[
            const _RevenueCard(),
            const SizedBox(height: KiteSpace.xl),
            const _FunnelCard(),
          ],
          const SizedBox(height: KiteSpace.xl),
          if (wide)
            const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _ChannelsCard()),
                  SizedBox(width: KiteSpace.xl),
                  Expanded(child: _TopProductsCard()),
                  SizedBox(width: KiteSpace.xl),
                  Expanded(child: _ActivityCard()),
                ],
              ),
            )
          else ...[
            const _ChannelsCard(),
            const SizedBox(height: KiteSpace.xl),
            const _TopProductsCard(),
            const SizedBox(height: KiteSpace.xl),
            const _ActivityCard(),
          ],
          const SizedBox(height: KiteSpace.xl),
          if (wide)
            const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: _RecentOrdersCard()),
                  SizedBox(width: KiteSpace.xl),
                  Expanded(flex: 2, child: _OrderStatusCard()),
                ],
              ),
            )
          else ...[
            const _RecentOrdersCard(),
            const SizedBox(height: KiteSpace.xl),
            const _OrderStatusCard(),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- stat row

class _StatRow extends StatelessWidget {
  const _StatRow();

  static const _stats = <(String, String, String, KiteTone, List<double>)>[
    (
      'Revenue',
      r'$284,120',
      '+12.4%',
      KiteTone.success,
      [31, 34, 33, 38, 41, 39, 45, 44, 49, 53, 51, 58],
    ),
    (
      'Orders',
      '3,412',
      '+4.1%',
      KiteTone.success,
      [42, 40, 44, 43, 47, 45, 48, 47, 50, 49, 52, 54],
    ),
    (
      'Customers',
      '1,208',
      '+8.9%',
      KiteTone.success,
      [22, 25, 24, 28, 27, 31, 33, 32, 36, 38, 41, 44],
    ),
    (
      'Refund rate',
      '1.4%',
      '-0.3%',
      KiteTone.danger,
      [26, 25, 27, 24, 23, 24, 21, 22, 19, 18, 17, 15],
    ),
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
      childAspectRatio: columns == 1 ? 3.0 : 1.55,
      children: [
        for (final (label, value, delta, tone, spark) in _stats)
          _TrendStat(
            label: label,
            value: value,
            delta: delta,
            tone: tone,
            spark: spark,
          ),
      ],
    );
  }
}

class _TrendStat extends StatelessWidget {
  const _TrendStat({
    required this.label,
    required this.value,
    required this.delta,
    required this.tone,
    required this.spark,
  });

  final String label;
  final String value;
  final String delta;
  final KiteTone tone;
  final List<double> spark;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final good = tone == KiteTone.success;
    final accent = good ? const Color(0xFF0C6B62) : const Color(0xFFB03D0B);
    return Container(
      padding: const EdgeInsets.all(KiteSpace.xl),
      decoration: BoxDecoration(
        color: c.card,
        border: Border.all(color: c.border),
        borderRadius: KiteRadius.allLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.muted),
          const SizedBox(height: KiteSpace.xs),
          Text(
            value,
            style: t.h3.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: KiteSpace.xs),
          Row(
            children: [
              Icon(
                good ? Icons.trending_up : Icons.trending_down,
                size: 14,
                color: accent,
              ),
              const SizedBox(width: 4),
              Text(delta, style: t.small.copyWith(fontSize: 12, color: accent)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'vs last month',
                  overflow: TextOverflow.ellipsis,
                  style: t.muted.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
          const Spacer(),
          KiteSparkline(values: spark, color: accent, height: 34),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ charts

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
      child: SizedBox(
        height: 250,
        child: KiteLineChart(
          spots: spots,
          valueLabel: (v) => KiteFormat.money(v * 1000),
        ),
      ),
    );
  }
}

/// A funnel. Stage-to-stage drop-off is the number that matters, so each row
/// carries its own conversion rather than only its count.
class _FunnelCard extends StatelessWidget {
  const _FunnelCard();

  static const _stages = <(String, int)>[
    ('Sessions', 48210),
    ('Product views', 21430),
    ('Added to cart', 7860),
    ('Checkout started', 4120),
    ('Purchased', 3412),
  ];

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final top = _stages.first.$2.toDouble();
    return KiteCard(
      title: 'Conversion funnel',
      trailing: const KiteBadge('7.1% end to end', tone: KiteTone.success),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _stages.length; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: KiteSpace.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _stages[i].$1,
                          style: t.small.copyWith(fontSize: 13),
                        ),
                      ),
                      Text(
                        KiteFormat.count(_stages[i].$2),
                        style: t.small.copyWith(
                          fontSize: 13,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (i > 0) ...[
                        const SizedBox(width: KiteSpace.sm),
                        SizedBox(
                          width: 44,
                          child: Text(
                            '${(_stages[i].$2 / _stages[i - 1].$2 * 100).round()}%',
                            textAlign: TextAlign.right,
                            style: t.muted.copyWith(fontSize: 11),
                          ),
                        ),
                      ] else
                        const SizedBox(width: 52),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FractionallySizedBox(
                        widthFactor: _stages[i].$2 / top,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            // Blend toward the surface rather than fading
                            // opacity — a translucent bar over a card reads
                            // muddy, especially in dark mode.
                            color: Color.lerp(
                              c.primary,
                              c.muted,
                              i / (_stages.length - 1) * 0.72,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChannelsCard extends StatelessWidget {
  const _ChannelsCard();

  static const _channels = <(String, double, String)>[
    ('Direct', 20460, '42%'),
    ('Organic', 13010, '27%'),
    ('Referral', 8680, '18%'),
    ('Email', 6060, '13%'),
  ];

  @override
  Widget build(BuildContext context) {
    return KiteCard(
      title: 'Traffic by channel',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (label, value, pct) in _channels)
            KiteBarRow(label: label, value: value, max: 20460, display: pct),
          const SizedBox(height: KiteSpace.sm),
          const KiteSeparator(),
          const SizedBox(height: KiteSpace.md),
          const _MiniFact(label: 'Sessions today', value: '4,812'),
          const _MiniFact(label: 'Avg. session', value: '3m 12s'),
          const _MiniFact(label: 'Bounce rate', value: '38.4%'),
        ],
      ),
    );
  }
}

class _MiniFact extends StatelessWidget {
  const _MiniFact({required this.label, required this.value});
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
          Text(
            value,
            style: t.small.copyWith(
              fontSize: 12,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopProductsCard extends ConsumerWidget {
  const _TopProductsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_topProductsProvider);
    final t = KiteText.of(context);
    return KiteCard(
      title: 'Top products',
      child: async.when(
        loading: () => const SizedBox(height: 180, child: LoadingState()),
        error: (e, _) =>
            SizedBox(height: 180, child: ErrorState(message: '$e')),
        data: (result) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final row in result.rows)
              Padding(
                padding: const EdgeInsets.only(bottom: KiteSpace.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${row['name']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.small.copyWith(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: KiteSpace.sm),
                    Text(
                      KiteFormat.money(row['price']),
                      style: t.small.copyWith(
                        fontSize: 13,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: KiteSpace.sm),
            const KiteSeparator(),
            const SizedBox(height: KiteSpace.md),
            const _MiniFact(label: 'Units sold this month', value: '8,412'),
            const _MiniFact(label: 'Average order value', value: r'$83.27'),
            const _MiniFact(label: 'Out of stock', value: '3 SKUs'),
          ],
        ),
      ),
    );
  }
}

/// An activity feed. A timeline rail is honest here — these events really are
/// a sequence, so the ordering device encodes something true.
class _ActivityCard extends StatelessWidget {
  const _ActivityCard();

  static const _events = <(String, String, String, KiteTone)>[
    ('Ada Lovelace', 'refunded order #10265', '4m', KiteTone.danger),
    ('Grace Hopper', 'closed the Q3 reconciliation', '31m', KiteTone.success),
    ('Linus Torvalds', 'rate-limited the export API', '1h', KiteTone.warning),
    ('Radia Perlman', 'shipped the dark mode pass', '3h', KiteTone.info),
    ('Ken Thompson', 'added 40 units of SKU-2014', '5h', KiteTone.neutral),
  ];

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return KiteCard(
      title: 'Activity',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _events.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 5),
                        decoration: BoxDecoration(
                          color: switch (_events[i].$4) {
                            KiteTone.success => const Color(0xFF0C6B62),
                            KiteTone.warning => const Color(0xFFC08A19),
                            KiteTone.danger => c.destructive,
                            KiteTone.info => c.primary,
                            KiteTone.neutral => c.mutedForeground,
                          },
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (i != _events.length - 1)
                        Expanded(child: Container(width: 1, color: c.border)),
                    ],
                  ),
                  const SizedBox(width: KiteSpace.md),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: KiteSpace.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: _events[i].$1,
                                  style: t.small.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${_events[i].$2}',
                                  style: t.small.copyWith(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${_events[i].$3} ago',
                            style: t.muted.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RecentOrdersCard extends ConsumerWidget {
  const _RecentOrdersCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(_recentProvider);
    return KiteCard(
      title: 'Recent orders',
      trailing: KiteButton.ghost(
        onPressed: () => KiteToast.show(context, title: 'Opening orders'),
        child: const Text('View all'),
      ),
      child: recent.when(
        loading: () => const SizedBox(height: 200, child: LoadingState()),
        error: (e, _) =>
            SizedBox(height: 200, child: ErrorState(message: '$e')),
        data: (result) => Column(
          children: [for (final row in result.rows) _OrderRow(row: row)],
        ),
      ),
    );
  }
}

/// Sits beside the orders list. A donut is the one shape this page does not
/// already use, and status mix is the obvious question to ask of the table
/// next to it — the two cards answer each other.
class _OrderStatusCard extends StatelessWidget {
  const _OrderStatusCard();

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final slices = [
      const KiteSlice(label: 'Paid', value: 1412, color: Color(0xFF0C6B62)),
      const KiteSlice(label: 'Shipped', value: 986, color: Color(0xFF2A9D8F)),
      const KiteSlice(label: 'Pending', value: 604, color: Color(0xFFC08A19)),
      const KiteSlice(label: 'Refunded', value: 271, color: Color(0xFF0663CE)),
      const KiteSlice(label: 'Cancelled', value: 139, color: Color(0xFFB03D0B)),
    ];

    return KiteCard(
      title: 'Order status',
      trailing: const KiteBadge('This month', tone: KiteTone.neutral),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KiteDonut(
            slices: slices,
            centerLabel: 'orders',
            centerValue: KiteFormat.count(
              slices.fold<double>(0, (s, e) => s + e.value).round(),
            ),
          ),
          const SizedBox(height: KiteSpace.lg),
          const KiteSeparator(),
          const SizedBox(height: KiteSpace.md),
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: c.mutedForeground),
              const SizedBox(width: KiteSpace.sm),
              Expanded(
                child: Text(
                  'Average time to ship',
                  style: t.muted.copyWith(fontSize: 12),
                ),
              ),
              Text(
                '1d 4h',
                style: t.small.copyWith(
                  fontSize: 12,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: KiteSpace.sm),
          Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                size: 14,
                color: c.mutedForeground,
              ),
              const SizedBox(width: KiteSpace.sm),
              Expanded(
                child: Text(
                  'Awaiting dispatch',
                  style: t.muted.copyWith(fontSize: 12),
                ),
              ),
              const KiteBadge('604', tone: KiteTone.warning),
            ],
          ),
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
          KiteAvatar(name: '${row['customer']}', size: 28),
          const SizedBox(width: KiteSpace.md),
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
