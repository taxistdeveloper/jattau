import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jattau/services/api_client.dart';

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository(ref.watch(dioProvider));
});

class QuranRepository {
  final Dio _dio;
  QuranRepository(this._dio);

  Future<List<dynamic>> getSurahs() async {
    final response = await _dio.get('/surahs');
    return response.data['data']['items'] as List;
  }

  Future<Map<String, dynamic>> getSurah(String id) async {
    final response = await _dio.get('/surahs/$id');
    return response.data['data'];
  }

  Future<List<dynamic>> getAyahs(String surahId) async {
    final response = await _dio.get('/surahs/$surahId/ayahs');
    return response.data['data']['items'] as List;
  }

  Future<Map<String, dynamic>> getAyah(String id) async {
    final response = await _dio.get('/ayahs/$id');
    return response.data['data'];
  }
}

final recitationRepositoryProvider = Provider<RecitationRepository>((ref) {
  return RecitationRepository(ref.watch(dioProvider));
});

class RecitationRepository {
  final Dio _dio;
  RecitationRepository(this._dio);

  Future<Map<String, dynamic>> submitRecitation(String ayahId, String audioPath, double duration) async {
    final formData = FormData.fromMap({
      'ayah_id': ayahId,
      'audio': await MultipartFile.fromFile(audioPath),
      'duration': duration,
    });
    final response = await _dio.post('/recitations', data: formData);
    return response.data['data'];
  }

  Future<Map<String, dynamic>> getResult(String recitationId) async {
    final response = await _dio.get('/recitations/$recitationId');
    return response.data['data'];
  }

  Future<List<dynamic>> getErrors() async {
    final response = await _dio.get('/recitations/errors');
    return response.data['data'] as List;
  }
}

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepository(ref.watch(dioProvider));
});

class StatisticsRepository {
  final Dio _dio;
  StatisticsRepository(this._dio);

  Future<Map<String, dynamic>> getStatistics() async {
    final response = await _dio.get('/statistics');
    return response.data['data'];
  }

  Future<List<dynamic>> getMentorRecommendations() async {
    final response = await _dio.get('/mentor/recommendations');
    return response.data['data'] as List;
  }
}
