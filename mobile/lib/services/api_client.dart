import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jattau/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'Accept': 'application/json'},
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final prefs = await SharedPreferences.getInstance();
      options.headers['Accept-Language'] = prefs.getString('app_locale') ?? 'ru';

      final isAuthRoute = options.path.contains('/auth/login') ||
          options.path.contains('/auth/register') ||
          options.path.contains('/auth/refresh');
      if (!isAuthRoute) {
        final token = prefs.getString('access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      final isAuthRoute = error.requestOptions.path.contains('/auth/login') ||
          error.requestOptions.path.contains('/auth/register');
      if (!isAuthRoute && error.response?.statusCode == 401) {
        final prefs = await SharedPreferences.getInstance();
        final refresh = prefs.getString('refresh_token');
        if (refresh != null) {
          try {
            final response = await Dio().post(
              '${AppConfig.apiBaseUrl}/auth/refresh',
              data: {'refresh_token': refresh},
            );
            final newToken = response.data['data']['access_token'];
            await prefs.setString('access_token', newToken);
            error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final retry = await dio.fetch(error.requestOptions);
            return handler.resolve(retry);
          } catch (_) {
            await prefs.remove('access_token');
            await prefs.remove('refresh_token');
          }
        }
      }
      handler.next(error);
    },
  ));

  return dio;
});
