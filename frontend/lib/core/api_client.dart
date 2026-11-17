import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class ApiClient {
  static const String _baseUrl = AppConstants.baseUrl;
  static final ApiClient _singleton = ApiClient._internal();

  late final Dio _dio;

  factory ApiClient() => _singleton;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      // Free Render instances can take ~50s to wake up; AI calls can be slow.
      connectTimeout: const Duration(seconds: 90),
      receiveTimeout: const Duration(seconds: 120),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Dio get dio => _dio;

  static Dio get instance => ApiClient()._dio;

  static Future<dynamic> get(String path) async {
    final response = await ApiClient().dio.get(path);
    return response.data;
  }

  static Future<dynamic> put(String path, Map<String, dynamic> data) async {
    final response = await ApiClient().dio.put(path, data: data);
    return response.data;
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> data) async {
    final response = await ApiClient().dio.patch(path, data: data);
    return response.data;
  }
}

final apiClient = ApiClient();
