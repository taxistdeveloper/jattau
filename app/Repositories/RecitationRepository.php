<?php

declare(strict_types=1);

namespace App\Repositories;

use PDO;

class RecitationRepository extends BaseRepository
{
    public function create(array $data): array
    {
        $id = $this->uuid();
        $stmt = $this->db->prepare('
            INSERT INTO recitations (id, user_id, ayah_id, audio_path, audio_duration_seconds, status, attempt_number)
            VALUES (:id, :user_id, :ayah_id, :audio_path, :audio_duration_seconds, :status, :attempt_number)
        ');
        $this->execute($stmt, array_merge($data, ['id' => $id]));

        return $this->findById($id) ?? [];
    }

    public function findById(string $id): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM recitations WHERE id = :id LIMIT 1');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function updateStatus(string $id, string $status): void
    {
        $stmt = $this->db->prepare('UPDATE recitations SET status = :status WHERE id = :id');
        $stmt->execute(['id' => $id, 'status' => $status]);
    }

    public function saveResult(array $data): array
    {
        $id = $this->uuid();
        $stmt = $this->db->prepare('
            INSERT INTO recitation_results (
                id, recitation_id, accuracy_percent, is_passed, transcribed_text, expected_text,
                words_correct, words_total, words_skipped, words_extra, words_mispronounced,
                words_reordered, tajweed_errors, processing_time_ms
            ) VALUES (
                :id, :recitation_id, :accuracy_percent, :is_passed, :transcribed_text, :expected_text,
                :words_correct, :words_total, :words_skipped, :words_extra, :words_mispronounced,
                :words_reordered, :tajweed_errors, :processing_time_ms
            )
        ');
        $this->execute($stmt, array_merge($data, ['id' => $id]));

        $stmt = $this->db->prepare('SELECT * FROM recitation_results WHERE id = :id LIMIT 1');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();

        return $row ?: [];
    }

    public function getResult(string $recitationId): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM recitation_results WHERE recitation_id = :id LIMIT 1');
        $stmt->execute(['id' => $recitationId]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function countAttempts(string $userId, string $ayahId): int
    {
        $stmt = $this->db->prepare('SELECT COUNT(*) FROM recitations WHERE user_id = :user_id AND ayah_id = :ayah_id');
        $stmt->execute(['user_id' => $userId, 'ayah_id' => $ayahId]);
        return (int) $stmt->fetchColumn();
    }

    public function savePronunciationError(array $data): void
    {
        $stmt = $this->db->prepare('
            INSERT INTO pronunciation_errors (
                id, recitation_result_id, user_id, ayah_id, error_type,
                word_expected, word_actual, word_position, letter_problem, severity
            ) VALUES (
                :id, :recitation_result_id, :user_id, :ayah_id, :error_type,
                :word_expected, :word_actual, :word_position, :letter_problem, :severity
            )
        ');
        $stmt->execute(array_merge($data, ['id' => $this->uuid()]));
    }

    public function getErrorsByUser(string $userId, int $limit = 50): array
    {
        $stmt = $this->db->prepare('
            SELECT pe.*, a.number as ayah_number, s.name_transliteration as surah_name
            FROM pronunciation_errors pe
            JOIN ayahs a ON a.id = pe.ayah_id
            JOIN surahs s ON s.id = a.surah_id
            WHERE pe.user_id = :user_id
            ORDER BY pe.created_at DESC
            LIMIT :limit
        ');
        $stmt->bindValue('user_id', $userId);
        $stmt->bindValue('limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll();
    }
}
