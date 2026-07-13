import 'package:dio/dio.dart';
import 'package:jattau/l10n/app_localizations.dart';

String parseApiError(Object error, [AppLocalizations? l10n]) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return _translateMessage(data['message'] as String, l10n);
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout) {
      return l10n?.connectionError ??
          'Не удалось подключиться к серверу. Проверьте, что backend запущен.';
    }
  }
  return error.toString();
}

String _translateMessage(String message, AppLocalizations? l10n) {
  if (l10n == null) {
    return _translateMessageRu(message);
  }
  return switch (message) {
    'Invalid credentials' => l10n.invalidCredentials,
    'Email already registered' => l10n.emailRegistered,
    'Validation failed' => l10n.validationFailed,
    'Account is deactivated' => l10n.accountDeactivated,
    'Unauthorized' => l10n.sessionExpired,
    'Invalid token' => l10n.sessionExpired,
    'Token expired' => l10n.sessionExpired,
    'Speech recognition failed' => l10n.speechRecognitionFailed,
    _ => message,
  };
}

String _translateMessageRu(String message) {
  return switch (message) {
    'Invalid credentials' => 'Неверный email или пароль',
    'Email already registered' => 'Этот email уже зарегистрирован',
    'Validation failed' => 'Проверьте правильность введённых данных',
    'Account is deactivated' => 'Аккаунт деактивирован',
    'Unauthorized' => 'Сессия истекла. Войдите снова',
    'Invalid token' => 'Сессия истекла. Войдите снова',
    'Token expired' => 'Сессия истекла. Войдите снова',
    'Speech recognition failed' =>
      'Распознавание речи недоступно. Проверьте OPENAI_API_KEY в backend/.env',
    _ => message,
  };
}
