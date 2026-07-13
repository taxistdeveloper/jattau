<?php

declare(strict_types=1);

namespace App\Repositories;

use PDO;

class AyahRepository extends BaseRepository
{
    public function bySurah(string $surahId, int $page = 1, int $perPage = 50): array
    {
        $offset = ($page - 1) * $perPage;

        $countStmt = $this->db->prepare('SELECT COUNT(*) FROM ayahs WHERE surah_id = :surah_id');
        $countStmt->execute(['surah_id' => $surahId]);
        $total = (int) $countStmt->fetchColumn();

        $stmt = $this->db->prepare('
            SELECT a.id, a.number, a.global_number, a.juz_number, a.page_number, a.audio_url,
                   s.number AS surah_number,
                   qt.text_uthmani, qt.text_simple, qt.text_transliteration, qt.text_transliteration_kk,
                   qt.text_translation_ru, qt.text_translation_kk, qt.word_count
            FROM ayahs a
            JOIN surahs s ON s.id = a.surah_id
            LEFT JOIN quran_text qt ON qt.ayah_id = a.id
            WHERE a.surah_id = :surah_id
            ORDER BY a.number ASC
            LIMIT :limit OFFSET :offset
        ');
        $stmt->bindValue('surah_id', $surahId);
        $stmt->bindValue('limit', $perPage, PDO::PARAM_INT);
        $stmt->bindValue('offset', $offset, PDO::PARAM_INT);
        $stmt->execute();

        return ['items' => $stmt->fetchAll(), 'total' => $total];
    }

    public function findById(string $id): ?array
    {
        $stmt = $this->db->prepare('
            SELECT a.*, s.number AS surah_number,
                   qt.text_uthmani, qt.text_simple, qt.text_transliteration, qt.text_transliteration_kk,
                   qt.text_translation_ru, qt.text_translation_kk, qt.word_count, qt.words_json
            FROM ayahs a
            JOIN surahs s ON s.id = a.surah_id
            LEFT JOIN quran_text qt ON qt.ayah_id = a.id
            WHERE a.id = :id LIMIT 1
        ');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();
        return $row ?: null;
    }
}
