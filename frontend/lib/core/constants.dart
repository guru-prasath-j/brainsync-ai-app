class AppConstants {
  /// Backend URL. Defaults to the live Render server.
  /// Local dev: flutter run --dart-define=API_URL=http://localhost:8001
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://brainsync-api.onrender.com',
  );
}
