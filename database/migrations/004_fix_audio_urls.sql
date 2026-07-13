-- Fix reference audio URLs (CORS-friendly CDN for web/mobile)

UPDATE ayahs a
JOIN surahs s ON s.id = a.surah_id
SET a.audio_url = CONCAT(
    'https://everyayah.com/data/Alafasy_128kbps/',
    LPAD(s.number, 3, '0'),
    LPAD(a.number, 3, '0'),
    '.mp3'
);
