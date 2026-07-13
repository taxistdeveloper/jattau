class AppConfig {
  static const String appName = 'Jattau';

  /// MAMP: http://localhost/jattau/api/v1
  /// Android emulator: http://10.0.2.2/jattau/api/v1
  /// Physical phone: http://YOUR_LAN_IP/jattau/api/v1
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost/jattau/api/v1',
  );
  static const double accuracyThreshold = 85.0;
  static const int maxRecordingSeconds = 120;
  static const int dailyGoalMinutes = 15;
}
