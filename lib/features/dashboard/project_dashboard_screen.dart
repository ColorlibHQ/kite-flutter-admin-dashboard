import 'package:flutter/material.dart';

import '../../kite_ui/kite_ui.dart';

/// A second dashboard with a genuinely different job.
///
/// Shipping three near-identical dashboards is padding; this one answers
/// "is the work on track", so it leads with schedule and people rather than
/// money.
class ProjectDashboardScreen extends StatelessWidget {
  const ProjectDashboardScreen({super.key});

  static const _milestones = <(String, String, double, KiteTone)>[
    ('Design system', 'Shipped 12 Aug', 1.0, KiteTone.success),
    ('Data layer', 'Due 29 Aug', 0.82, KiteTone.info),
    ('Mobile shell', 'Due 5 Sep', 0.46, KiteTone.info),
    ('Localisation', 'Due 19 Sep', 0.12, KiteTone.warning),
    ('Backend adapters', 'Not started', 0.0, KiteTone.neutral),
  ];

  static const _team = <(String, String, int, int)>[
    ('Ada Lovelace', 'Design', 12, 14),
    ('Barbara Liskov', 'Backend', 9, 11),
    ('Radia Perlman', 'Design', 7, 7),
    ('Ken Thompson', 'Backend', 5, 9),
    ('Margaret Hamilton', 'Mobile', 4, 6),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = KiteBreak.isDesktop(context);
    final c = KiteColors.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(KiteSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KiteAlert(
            title: 'One milestone is at risk',
            description:
                'Localisation is 12% complete with three weeks left. Move a '
                'designer across or push the date.',
            tone: KiteTone.warning,
          ),
          const SizedBox(height: KiteSpace.xl),
          const _Stats(),
          const SizedBox(height: KiteSpace.xl),
          if (wide)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: _MilestonesCard(c: c)),
                  const SizedBox(width: KiteSpace.xl),
                  const Expanded(flex: 2, child: _WorkloadCard()),
                ],
              ),
            )
          else ...[
            _MilestonesCard(c: c),
            const SizedBox(height: KiteSpace.xl),
            const _WorkloadCard(),
          ],
          const SizedBox(height: KiteSpace.xl),
          const _BurndownCard(),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats();

  @override
  Widget build(BuildContext context) {
    // Shorter than the main dashboard's tiles: these carry no sparkline.
    return const KiteStatGrid(
      height: 128,
      children: [
        KiteStat(
          label: 'Open issues',
          value: '47',
          delta: '-8 this week',
          deltaTone: KiteTone.success,
        ),
        KiteStat(
          label: 'In review',
          value: '12',
          delta: '+3 this week',
          deltaTone: KiteTone.danger,
        ),
        KiteStat(label: 'Cycle time', value: '2.4d', delta: '-0.6d'),
        KiteStat(
          label: 'On schedule',
          value: '3 of 5',
          delta: 'Localisation at risk',
          deltaTone: KiteTone.danger,
        ),
      ],
    );
  }
}

class _MilestonesCard extends StatelessWidget {
  const _MilestonesCard({required this.c});
  final KiteColors c;

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    return KiteCard(
      title: 'Milestones',
      trailing: const KiteBadge('Q3', tone: KiteTone.info),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (name, due, progress, tone)
              in ProjectDashboardScreen._milestones)
            Padding(
              padding: const EdgeInsets.only(bottom: KiteSpace.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(name, style: t.small)),
                      KiteBadge(due, tone: tone),
                    ],
                  ),
                  const SizedBox(height: KiteSpace.sm),
                  KiteMeter(
                    label: '',
                    value: progress,
                    trailing: '${(progress * 100).round()}%',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _WorkloadCard extends StatelessWidget {
  const _WorkloadCard();

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    return KiteCard(
      title: 'Workload',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (name, team, done, total) in ProjectDashboardScreen._team)
            Padding(
              padding: const EdgeInsets.only(bottom: KiteSpace.md),
              child: Row(
                children: [
                  KiteAvatar(name: name, size: 28),
                  const SizedBox(width: KiteSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: t.small.copyWith(fontSize: 13),
                        ),
                        Text(team, style: t.muted.copyWith(fontSize: 11)),
                      ],
                    ),
                  ),
                  Text(
                    '$done / $total',
                    style: t.small.copyWith(
                      fontSize: 12,
                      fontFeatures: const [FontFeature.tabularFigures()],
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

class _BurndownCard extends StatelessWidget {
  const _BurndownCard();

  @override
  Widget build(BuildContext context) {
    // Remaining work, sprint day 0..21.
    const remaining = <double>[
      92,
      90,
      86,
      83,
      79,
      78,
      71,
      68,
      66,
      61,
      58,
      55,
      54,
      48,
      44,
      41,
      39,
      33,
      29,
      24,
      19,
      14,
    ];
    return KiteCard(
      title: 'Burndown',
      trailing: const KiteBadge('Sprint 14', tone: KiteTone.neutral),
      child: SizedBox(
        height: 220,
        child: KiteLineChart(
          spots: [
            for (var i = 0; i < remaining.length; i++)
              (i.toDouble(), remaining[i]),
          ],
          valueLabel: (v) => '${v.round()} points left',
        ),
      ),
    );
  }
}
