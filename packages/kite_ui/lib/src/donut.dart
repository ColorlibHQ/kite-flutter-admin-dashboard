import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

import 'tokens.dart';

@immutable
class KiteSlice {
  const KiteSlice({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;
}

/// A donut with the total in the hole and a legend beside it.
///
/// Deliberately a donut and not a pie: the centre is the most valuable space
/// on the shape, and a total there answers the first question a reader has
/// before they start comparing wedges. Slice labels live in the legend rather
/// than on the arcs, which stops small slices printing text over each other.
class KiteDonut extends StatelessWidget {
  const KiteDonut({
    super.key,
    required this.slices,
    required this.centerLabel,
    required this.centerValue,
    this.size = 168,
  });

  final List<KiteSlice> slices;
  final String centerLabel;
  final String centerValue;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = KiteText.of(context);
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: size * 0.30,
                  startDegreeOffset: -90,
                  pieTouchData: PieTouchData(enabled: false),
                  sections: [
                    for (final s in slices)
                      PieChartSectionData(
                        value: s.value,
                        color: s.color,
                        radius: size * 0.19,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerValue,
                    style: t.h4.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(centerLabel, style: t.muted.copyWith(fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: KiteSpace.lg),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final s in slices)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: s.color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: KiteSpace.sm),
                      Expanded(
                        child: Text(
                          s.label,
                          overflow: TextOverflow.ellipsis,
                          style: t.small.copyWith(fontSize: 12.5),
                        ),
                      ),
                      Text(
                        '${(s.value / total * 100).round()}%',
                        style: t.muted.copyWith(
                          fontSize: 12,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
