import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/report_model.dart';

/// Smooth line/area chart for trends over time.
class TrendLineChart extends StatelessWidget {
  const TrendLineChart({
    super.key,
    required this.data,
    this.height = 180,
    this.color,
    this.areaColor,
    this.showLabels = true,
  });

  final List<ChartDatum> data;
  final double height;
  final Color? color;
  final Color? areaColor;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color lineColor = color ?? scheme.primary;

    if (data.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'Not enough data yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      );
    }

    final double maxY = data.map((d) => d.value).reduce((a, b) => a > b ? a : b) * 1.3;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
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
          lineBarsData: [
            LineChartBarData(
              spots: [for (int i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].value)],
              isCurved: true,
              curveSmoothness: 0.35,
              color: lineColor,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: (areaColor ?? lineColor).withValues(alpha: 0.18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
