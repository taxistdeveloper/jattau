import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jattau/features/auth/data/pin_repository.dart';
import 'package:jattau/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider), ref.watch(pinRepositoryProvider));
});

final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(authRepositoryProvider).getProfile();
});

class AuthRepository {
  final Dio _dio;
  final PinRepository _pinRepo;

  AuthRepository(this._dio, this._pinRepo);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = response.data['data'];
    await _saveTokens(data);
    return data;
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'password_confirmation': password,
      'full_name': fullName,
    });
    final data = response.data['data'];
    await _saveTokens(data);
    return data;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await _pinRepo.clearPin();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/user/profile');
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', data['access_token']);
    await prefs.setString('refresh_token', data['refresh_token']);
  }
}
