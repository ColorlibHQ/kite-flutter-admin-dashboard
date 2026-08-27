import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// A sparkline: trend without axes, labels or grid.
///
/// It belongs inside a stat tile, where the number is the message and the
/// shape is the context — so it gets an area fill and an emphasised endpoint,
/// and nothing else.
class KiteSparkline extends StatelessWidget {
  const KiteSparkline({
    super.key,
    required this.values,
    this.color,
    this.height = 40,
  });

  final List<double> values;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final line = color ?? c.primary;
    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          minY: values.reduce((a, b) => a < b ? a : b) * 0.92,
          maxY: values.reduce((a, b) => a > b ? a : b) * 1.05,
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < values.length; i++)
                  FlSpot(i.toDouble(), values[i]),
              ],
              isCurved: true,
              barWidth: 1.8,
              color: line,
              dotData: FlDotData(
                show: true,
                // Only the last point gets a dot — where the series ends is
                // the part a reader actually looks for.
                checkToShowDot: (spot, _) => spot.x == values.length - 1,
                getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                  radius: 2.5,
                  color: line,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: line.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A horizontal bar chart for ranked categories — the shape that answers
/// "which of these is biggest" faster than a pie ever does.
class KiteBarRow extends StatelessWidget {
  const KiteBarRow({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    required this.display,
    this.color,
  });

  final String label;
  final double value;
  final double max;
  final String display;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    final t = KiteText.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: KiteSpace.md),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: t.small.copyWith(fontSize: 13),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(
                  widthFactor: (value / max).clamp(0.02, 1),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: color ?? c.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: KiteSpace.md),
          SizedBox(
            width: 68,
            child: Text(
              display,
              textAlign: TextAlign.right,
              style: t.small.copyWith(
                fontSize: 13,
                color: c.mutedForeground,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
