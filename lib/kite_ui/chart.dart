import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// A line chart with the chrome an admin actually needs: a faint horizontal
/// grid, no axis furniture competing with the data, an area fill, and colours
/// taken from the theme so it reads in both light and dark.
class KiteLineChart extends StatelessWidget {
  const KiteLineChart({super.key, required this.spots, this.showArea = true});

  final List<(double, double)> spots;
  final bool showArea;

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
