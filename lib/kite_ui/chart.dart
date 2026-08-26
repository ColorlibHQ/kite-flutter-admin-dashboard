import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// A line chart with the chrome an admin actually needs: a faint horizontal
/// grid, no axis furniture competing with the data, an area fill, and colours
/// taken from the theme so it reads in both light and dark.
class KiteLineChart extends StatelessWidget {
  const KiteLineChart({
    super.key,
    required this.spots,
    this.showArea = true,
    this.valueLabel,
  });

  final List<(double, double)> spots;
  final bool showArea;

  /// Formats the hover tooltip. Defaults to one decimal place.
  final String Function(double)? valueLabel;

  @override
  Widget build(BuildContext context) {
    final c = KiteColors.of(context);
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: c.border, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                // Skip the min/max edge labels fl_chart adds — they collide
                // with the plot border and print unrounded values.
                if (value == meta.min || value == meta.max) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    value.round().toString(),
                    style: TextStyle(fontSize: 11, color: c.mutedForeground),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        // Without this, hovering prints the raw double — 74.81973839205.
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => c.foreground,
            tooltipBorderRadius: BorderRadius.circular(6),
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            getTooltipItems: (spots) => [
              for (final s in spots)
                LineTooltipItem(
                  valueLabel?.call(s.y) ?? s.y.toStringAsFixed(1),
                  TextStyle(
                    color: c.background,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          getTouchedSpotIndicator: (bar, indexes) => [
            for (final _ in indexes)
              TouchedSpotIndicatorData(
                FlLine(color: c.border, strokeWidth: 1),
                FlDotData(
                  getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                    radius: 3.5,
                    color: c.primary,
                    strokeWidth: 2,
                    strokeColor: c.card,
                  ),
                ),
              ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [for (final (x, y) in spots) FlSpot(x, y)],
            isCurved: true,
            barWidth: 2,
            color: c.primary,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: showArea,
              color: c.primary.withValues(alpha: 0.10),
            ),
          ),
        ],
      ),
    );
  }
}
