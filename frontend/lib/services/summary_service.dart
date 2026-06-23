import '../core/api_client.dart';
import '../models/summary_model.dart';

class SummaryService {
  Future<SummaryModel?> getSummary(int noteId) async {
    try {
      final data = await ApiClient.get('/api/summaries/$noteId');
      return SummaryModel.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<SummaryModel> generateSummary(int noteId) async {
    final data = await ApiClient().dio.post('/api/summaries/$noteId/generate', data: {});
    return SummaryModel.fromJson(data.data as Map<String, dynamic>);
  }
}
