import '../core/api_client.dart';

class ApiService {
  static Future<dynamic> get(String path) => ApiClient.get(path);
  static Future<dynamic> put(String path, Map<String, dynamic> data) => ApiClient.put(path, data);
  static Future<dynamic> patch(String path, Map<String, dynamic> data) => ApiClient.patch(path, data);
}
