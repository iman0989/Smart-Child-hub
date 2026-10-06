import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/report_model.dart';

/// Vertical bar chart used for weekly / monthly task summaries.
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({
    super.key,
    required this.data,
    this.height = 180,
    this.color,
    this.trackColor,
    this.showLabels = true,
  });

  final List<ChartDatum> data;
  final double height;
  final Color? color;
  final Color? trackColor;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color barColor = color ?? scheme.primary;
    final Color track = trackColor ?? scheme.surfaceContainerHighest;
    final double maxValue = data.isEmpty
        ? 1
        : data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue * 1.25,
          minY: 0,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => scheme.inverseSurface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.round()}',
                  TextStyle(
                    color: scheme.onInverseSurface,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showLabels,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final int index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data[index].label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (int i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: data[i].value,
                    width: 18,
                    color: barColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxValue * 1.25,
                      color: track.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
