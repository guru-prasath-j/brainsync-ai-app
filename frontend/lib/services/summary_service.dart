import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/summary_model.dart';

class SummaryService {
  final Dio _dio = ApiClient.instance;

  Future<SummaryModel?> getSummary(int noteId) async {
    try {
      final response = await _dio.get('/api/summaries/$noteId');
      return SummaryModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<SummaryModel> generateSummary(int noteId) async {
    final response = await _dio.post('/api/summaries/$noteId/generate');
    return SummaryModel.fromJson(response.data as Map<String, dynamic>);
  }
}
