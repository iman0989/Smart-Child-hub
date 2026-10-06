import '../../models/report_model.dart';
import '../network/api_client.dart';

/// Data access for the `/api/children/{id}/reports/*` endpoints.
class ReportRepository {
  ReportRepository([ApiClient? client]) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<ReportStatsModel> report(String childId, ReportPeriod period) async {
    final dynamic data = await _client.get('/api/children/$childId/reports/${period.name}');
    return ReportStatsModel.fromJson(data as Map<String, dynamic>);
  }
}
