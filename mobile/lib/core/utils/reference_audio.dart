class ReferenceAudio {
  static const _baseUrl = 'https://everyayah.com/data/Alafasy_128kbps';

  static String? urlForAyah(Map<String, dynamic> ayah) {
    final surahNumber = _asInt(ayah['surah_number']);
    final ayahNumber = _asInt(ayah['number']);
    if (surahNumber != null && ayahNumber != null) {
      return '$_baseUrl/${surahNumber.toString().padLeft(3, '0')}${ayahNumber.toString().padLeft(3, '0')}.mp3';
    }

    final existing = ayah['audio_url'] as String?;
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    return null;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
