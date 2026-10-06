import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A single donut slice definition.
class DonutSlice {
  const DonutSlice(this.value, this.color, this.label);

  final double value;
  final Color color;
  final String label;
}

/// Donut / pie chart with a customisable center label.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.slices,
    this.centerLabel,
    this.centerValue,
    this.size = 180,
    this.showCenterLabels = true,
  });

  final List<DonutSlice> slices;
  final String? centerLabel;
  final String? centerValue;
  final double size;
  final bool showCenterLabels;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double total = slices.fold(0, (sum, s) => sum + s.value);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: size * 0.34,
              startDegreeOffset: -90,
              sections: [
                for (final DonutSlice slice in slices)
                  PieChartSectionData(
                    value: slice.value,
                    color: slice.color,
                    radius: size * 0.38,
                    showTitle: showCenterLabels && slice.value / total > 0.06,
                    title: showCenterLabels && slice.value / total > 0.06
                        ? '${(slice.value / total * 100).round()}%'
                        : '',
                    titleStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
          if (centerValue != null || centerLabel != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (centerValue != null)
                  Text(
                    centerValue!,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                if (centerLabel != null)
                  Text(
                    centerLabel!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Legend row next to a donut chart.
class DonutLegendItem extends StatelessWidget {
  const DonutLegendItem({super.key, required this.color, required this.label, required this.value});

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
