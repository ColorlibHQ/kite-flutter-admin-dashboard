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
          if (wide)
            const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: _BurndownCard()),
                  SizedBox(width: KiteSpace.xl),
                  Expanded(flex: 2, child: _IssueMixCard()),
                ],
              ),
            )
          else ...[
            const _BurndownCard(),
            const SizedBox(height: KiteSpace.xl),
            const _IssueMixCard(),
          ],
          const SizedBox(height: KiteSpace.xl),
          if (wide)
            const IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 2, child: _ReleasesCard()),
                  SizedBox(width: KiteSpace.xl),
                  Expanded(flex: 3, child: _RisksCard()),
                ],
              ),
            )
          else ...[
            const _ReleasesCard(),
            const SizedBox(height: KiteSpace.xl),
            const _RisksCard(),
          ],
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
          const SizedBox(height: KiteSpace.sm),
          const KiteSeparator(),
          const SizedBox(height: KiteSpace.md),
          // Capacity in one line, so the card carries its own conclusion
          // rather than leaving the reader to add up the column above.
          const KiteMeter(
            label: 'Sprint capacity used',
            value: 0.78,
            trailing: '37 of 47',
          ),
          const _Capacity(label: 'Unassigned issues', value: '10'),
          const _Capacity(label: 'Blocked', value: '2'),
          const _Capacity(label: 'Carried from Sprint 13', value: '6'),
        ],
      ),
    );
  }
}

class _Capacity extends StatelessWidget {
  const _Capacity({required this.label, required this.value});
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

/// Where the open work sits. A donut because the question is proportion, and
/// the total belongs in the middle.
class _IssueMixCard extends StatelessWidget {
  const _IssueMixCard();

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    final slices = [
      const KiteSlice(label: 'Bug', value: 18, color: Color(0xFFB03D0B)),
      const KiteSlice(label: 'Feature', value: 15, color: Color(0xFF0663CE)),
      const KiteSlice(label: 'Chore', value: 9, color: Color(0xFFC08A19)),
      const KiteSlice(label: 'Docs', value: 5, color: Color(0xFF0C6B62)),
    ];
    return KiteCard(
      title: 'Open issues by type',
      trailing: const KiteBadge('47 open', tone: KiteTone.neutral),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KiteDonut(
            slices: slices,
            centerLabel: 'open',
            centerValue: KiteFormat.count(
              slices.fold<double>(0, (s, e) => s + e.value).round(),
            ),
          ),
          const SizedBox(height: KiteSpace.lg),
          const KiteSeparator(),
          const SizedBox(height: KiteSpace.md),
          Row(
            children: [
              Icon(Icons.bolt_outlined, size: 14, color: c.mutedForeground),
              const SizedBox(width: KiteSpace.sm),
              Expanded(
                child: Text(
                  'Oldest open issue',
                  style: t.muted.copyWith(fontSize: 12),
                ),
              ),
              Text('34 days', style: t.small.copyWith(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReleasesCard extends StatelessWidget {
  const _ReleasesCard();

  static const _releases = <(String, String, String, KiteTone)>[
    ('v1.4.0', 'Board drag-and-drop', 'Shipped', KiteTone.success),
    ('v1.3.2', 'Icon font subsetting', 'Shipped', KiteTone.success),
    ('v1.5.0', 'Localisation', 'In QA', KiteTone.warning),
    ('v1.6.0', 'Backend adapters', 'Planned', KiteTone.neutral),
  ];

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    return KiteCard(
      title: 'Releases',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (version, summary, status, tone) in _releases)
            Padding(
              padding: const EdgeInsets.only(bottom: KiteSpace.md),
              child: Row(
                children: [
                  SizedBox(
                    width: 58,
                    child: Text(
                      version,
                      style: t.small.copyWith(
                        fontSize: 12.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      summary,
                      overflow: TextOverflow.ellipsis,
                      style: t.muted.copyWith(fontSize: 12.5),
                    ),
                  ),
                  const SizedBox(width: KiteSpace.sm),
                  KiteBadge(status, tone: tone),
                ],
              ),
            ),
          const SizedBox(height: KiteSpace.sm),
          const KiteSeparator(),
          const SizedBox(height: KiteSpace.md),
          const _Capacity(label: 'Releases this quarter', value: '6'),
          const _Capacity(label: 'Median time to ship', value: '9 days'),
          const _Capacity(label: 'Rolled back', value: '0'),
        ],
      ),
    );
  }
}

/// Risks, ordered by how much attention they need rather than when they were
/// raised — a risk register sorted by date is a diary, not a tool.
class _RisksCard extends StatelessWidget {
  const _RisksCard();

  static const _risks = <(String, String, String, KiteTone)>[
    (
      'Localisation will miss 19 Sep',
      'One designer, three weeks, 12% done.',
      'High',
      KiteTone.danger,
    ),
    (
      'shadcn_ui is pre-1.0 and slowing',
      '7 commits last quarter. Wrapper keeps the swap cheap.',
      'Medium',
      KiteTone.warning,
    ),
    (
      'No Android device in the test rack',
      'Mid-range perf is unverified outside CI.',
      'Medium',
      KiteTone.warning,
    ),
    (
      'Bundle budget has 179 KB of headroom',
      'Two more chart-heavy screens would exceed it.',
      'Low',
      KiteTone.info,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return KiteCard(
      title: 'Risks',
      trailing: const KiteBadge('1 high', tone: KiteTone.danger),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (title, detail, severity, tone) in _risks)
            Padding(
              padding: const EdgeInsets.only(bottom: KiteSpace.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3,
                    height: 34,
                    decoration: BoxDecoration(
                      color: switch (tone) {
                        KiteTone.danger => c.destructive,
                        KiteTone.warning => const Color(0xFFC08A19),
                        KiteTone.info => c.primary,
                        _ => c.border,
                      },
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: KiteSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: t.small.copyWith(fontSize: 13),
                              ),
                            ),
                            KiteBadge(severity, tone: tone),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(detail, style: t.muted.copyWith(fontSize: 12)),
                      ],
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
