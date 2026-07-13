class AppConfig {
  static const String appName = 'Jattau';

  /// Production: https://jattau.krg-ktsk.kz/api/v1
  /// MAMP local: --dart-define=API_BASE_URL=http://localhost/jattau/api/v1
  /// Android emulator: --dart-define=API_BASE_URL=http://10.0.2.2/jattau/api/v1
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://jattau.krg-ktsk.kz/api/v1',
  );
  static const double accuracyThreshold = 85.0;
  static const int maxRecordingSeconds = 120;
  static const int dailyGoalMinutes = 15;
}
