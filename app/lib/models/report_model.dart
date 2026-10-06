/// Reporting period selector.
enum ReportPeriod { daily, weekly, monthly }

extension ReportPeriodX on ReportPeriod {
  String get label {
    switch (this) {
      case ReportPeriod.daily:
        return 'Daily';
      case ReportPeriod.weekly:
        return 'Weekly';
      case ReportPeriod.monthly:
        return 'Monthly';
    }
  }
}

/// A single point on a chart.
class ChartDatum {
  const ChartDatum(this.label, this.value);

  final String label;
  final double value;

  factory ChartDatum.fromJson(Map<String, dynamic> json) =>
      ChartDatum(json['label'] as String? ?? '', (json['value'] as num?)?.toDouble() ?? 0);
}

/// Aggregated statistics for a report screen.
class ReportStatsModel {
  const ReportStatsModel({
    this.tasksDone = 0,
    this.completionRate = 0,
    this.coins = 0,
    this.dayStreak = 0,
    this.sleepHours = 0,
    this.waterGlasses = 0,
    this.taskChart = const [],
    this.trendChart = const [],
    this.categoryChart = const [],
  });

  final int tasksDone;
  final double completionRate;
  final int coins;
  final int dayStreak;
  final double sleepHours;
  final int waterGlasses;

  /// Tasks completed per day (Mon–Sun for weekly reports).
  final List<ChartDatum> taskChart;

  /// Trend line values.
  final List<ChartDatum> trendChart;

  /// Tasks by category (Health / Learning / Activity / Routine).
  final List<ChartDatum> categoryChart;

  factory ReportStatsModel.fromJson(Map<String, dynamic> json) {
    List<ChartDatum> charts(String key) => (json[key] as List<dynamic>? ?? const [])
        .map((e) => ChartDatum.fromJson(e as Map<String, dynamic>))
        .toList();

    return ReportStatsModel(
      tasksDone: (json['tasksDone'] as num?)?.toInt() ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0,
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      dayStreak: (json['dayStreak'] as num?)?.toInt() ?? 0,
      sleepHours: (json['sleepHours'] as num?)?.toDouble() ?? 0,
      waterGlasses: (json['waterGlasses'] as num?)?.toInt() ?? 0,
      taskChart: charts('taskChart'),
      trendChart: charts('trendChart'),
      categoryChart: charts('categoryChart'),
    );
  }
}
