<?php

declare(strict_types=1);

namespace App\Services;

use App\Repositories\BaseRepository;
use PDO;

class SpacedRepetitionService extends BaseRepository
{
    public function getDueCards(string $userId, int $limit = 20): array
    {
        $stmt = $this->db->prepare('
            SELECT mc.*, qt.text_uthmani, a.number as ayah_number, s.name_transliteration
            FROM memorization_cards mc
            JOIN ayahs a ON a.id = mc.ayah_id
            JOIN quran_text qt ON qt.ayah_id = a.id
            JOIN surahs s ON s.id = a.surah_id
            WHERE mc.user_id = :user_id AND mc.next_review_at <= NOW()
            ORDER BY mc.next_review_at ASC
            LIMIT :limit
        ');
        $stmt->bindValue('user_id', $userId);
        $stmt->bindValue('limit', $limit, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    public function reviewCard(string $userId, string $ayahId, int $quality): array
    {
        $stmt = $this->db->prepare('SELECT * FROM memorization_cards WHERE user_id = :user_id AND ayah_id = :ayah_id');
        $stmt->execute(['user_id' => $userId, 'ayah_id' => $ayahId]);
        $card = $stmt->fetch();

        if (!$card) {
            return $this->createCard($userId, $ayahId, $quality);
        }

        $ef = (float) $card['ease_factor'];
        $interval = (int) $card['interval_days'];
        $reps = (int) $card['repetitions'];

        if ($quality < 3) {
            $reps = 0;
            $interval = 1;
        } else {
            if ($reps === 0) {
                $interval = 1;
            } elseif ($reps === 1) {
                $interval = 6;
            } else {
                $interval = (int) round($interval * $ef);
            }
            $reps++;
            $ef = max(1.3, $ef + (0.1 - (5 - $quality) * (0.08 + (5 - $quality) * 0.02)));
        }

        $memPercent = min(100, $reps * 15 + $quality * 5);
        $nextReview = date('Y-m-d H:i:s', strtotime("+{$interval} days"));

        $update = $this->db->prepare('
            UPDATE memorization_cards SET
                ease_factor = :ef, interval_days = :interval, repetitions = :reps,
                next_review_at = :next_review, memorization_percent = :mem_percent
            WHERE user_id = :user_id AND ayah_id = :ayah_id
        ');
        $update->execute([
            'ef' => $ef,
            'interval' => $interval,
            'reps' => $reps,
            'next_review' => $nextReview,
            'mem_percent' => $memPercent,
            'user_id' => $userId,
            'ayah_id' => $ayahId,
        ]);

        $stmt = $this->db->prepare('SELECT * FROM memorization_cards WHERE user_id = :user_id AND ayah_id = :ayah_id');
        $stmt->execute(['user_id' => $userId, 'ayah_id' => $ayahId]);
        return $stmt->fetch() ?: [];
    }

    private function createCard(string $userId, string $ayahId, int $quality): array
    {
        $interval = $quality >= 3 ? 1 : 0;
        $nextReview = date('Y-m-d H:i:s', strtotime($interval > 0 ? '+1 day' : 'now'));
        $id = $this->uuid();

        $stmt = $this->db->prepare('
            INSERT INTO memorization_cards (id, user_id, ayah_id, ease_factor, interval_days, repetitions, next_review_at, memorization_percent)
            VALUES (:id, :user_id, :ayah_id, 2.5, :interval, 1, :next_review, :mem_percent)
        ');
        $stmt->execute([
            'id' => $id,
            'user_id' => $userId,
            'ayah_id' => $ayahId,
            'interval' => $interval,
            'next_review' => $nextReview,
            'mem_percent' => $quality * 10,
        ]);

        $stmt = $this->db->prepare('SELECT * FROM memorization_cards WHERE id = :id');
        $stmt->execute(['id' => $id]);
        return $stmt->fetch() ?: [];
    }
}
