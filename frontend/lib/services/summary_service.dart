import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/summary_model.dart';
import 'auth_service.dart';

class SummaryService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Fetch existing summary for [noteId]. Returns null if not yet generated.
  Future<SummaryModel?> getSummary(int noteId) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/api/summaries/$noteId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return SummaryModel.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    }
    throw Exception('Failed to fetch summary: ${response.statusCode}');
  }

  /// Trigger AI generation (or re-generation) for [noteId].
  Future<SummaryModel> generateSummary(int noteId) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/summaries/$noteId/generate'),
      headers: await _headers(),
      body: jsonEncode({}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return SummaryModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to generate summary: ${response.statusCode}');
  }
}
