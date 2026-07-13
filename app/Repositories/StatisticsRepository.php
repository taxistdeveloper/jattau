<?php

declare(strict_types=1);

namespace App\Repositories;

class StatisticsRepository extends BaseRepository
{
    public function getByUser(string $userId): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM statistics WHERE user_id = :user_id LIMIT 1');
        $stmt->execute(['user_id' => $userId]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function updateAfterRecitation(string $userId, float $accuracy, int $errorCount, array $problemLetters): void
    {
        $stats = $this->getByUser($userId);
        $letters = json_decode($stats['problem_letters'] ?? '{}', true) ?: [];

        foreach ($problemLetters as $letter => $count) {
            $letters[$letter] = ($letters[$letter] ?? 0) + $count;
        }

        $totalRecitations = ($stats['total_recitations'] ?? 0) + 1;
        $avgAccuracy = (($stats['avg_accuracy'] ?? 0) * ($totalRecitations - 1) + $accuracy) / $totalRecitations;

        $stmt = $this->db->prepare('
            UPDATE statistics SET
                total_recitations = total_recitations + 1,
                total_errors = total_errors + :errors,
                avg_accuracy = :avg_accuracy,
                problem_letters = :letters,
                updated_at = NOW()
            WHERE user_id = :user_id
        ');
        $stmt->execute([
            'user_id' => $userId,
            'errors' => $errorCount,
            'avg_accuracy' => round($avgAccuracy, 2),
            'letters' => json_encode($letters, JSON_UNESCAPED_UNICODE),
        ]);
    }

    /**
     * Пересчитывает пройденные суры/аяты и заученные аяты из истории чтений.
     * Идемпотентно: считает уникальные аяты, поэтому повторные чтения не дублируются.
     */
    public function recalcProgress(string $userId): void
    {
        $stmt = $this->db->prepare('
            UPDATE statistics s
            JOIN (
                SELECT
                    COUNT(DISTINCT r.ayah_id) AS ayahs_studied,
                    COUNT(DISTINCT a.surah_id) AS surahs_studied,
                    COUNT(DISTINCT CASE WHEN rr.is_passed = 1 THEN r.ayah_id END) AS ayahs_memorized
                FROM recitations r
                JOIN ayahs a ON a.id = r.ayah_id
                LEFT JOIN recitation_results rr ON rr.recitation_id = r.id
                WHERE r.user_id = :user_id
            ) sub ON s.user_id = :owner_id
            SET
                s.ayahs_studied = sub.ayahs_studied,
                s.surahs_studied = sub.surahs_studied,
                s.ayahs_memorized = sub.ayahs_memorized,
                s.updated_at = NOW()
        ');
        $stmt->execute([
            'user_id' => $userId,
            'owner_id' => $userId,
        ]);

        $this->syncLevelFromStats($userId);
    }

    /**
     * Синхронизирует level и experience_points в таблице users из statistics.
     */
    public function syncLevelFromStats(string $userId): void
    {
        $stats = $this->getByUser($userId);
        if (!$stats) {
            return;
        }

        $xp = (int) ($stats['ayahs_studied'] ?? 0) * 20
            + (int) ($stats['ayahs_memorized'] ?? 0) * 50
            + (int) ($stats['total_recitations'] ?? 0) * 10;
        $level = intdiv($xp, 500) + 1;

        $stmt = $this->db->prepare('
            UPDATE users SET experience_points = :xp, level = :level, updated_at = NOW()
            WHERE id = :user_id
        ');
        $stmt->execute([
            'xp' => $xp,
            'level' => $level,
            'user_id' => $userId,
        ]);
    }

    public function getStreak(string $userId): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM streaks WHERE user_id = :user_id LIMIT 1');
        $stmt->execute(['user_id' => $userId]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function updateStreak(string $userId): void
    {
        $streak = $this->getStreak($userId);
        $today = date('Y-m-d');
        $lastDate = $streak['last_activity_date'] ?? null;

        if ($lastDate === $today) {
            return;
        }

        $yesterday = date('Y-m-d', strtotime('-1 day'));
        $current = ($lastDate === $yesterday) ? ($streak['current_streak'] ?? 0) + 1 : 1;
        $longest = max($current, $streak['longest_streak'] ?? 0);

        $stmt = $this->db->prepare('
            UPDATE streaks SET current_streak = :current, longest_streak = :longest, last_activity_date = :today
            WHERE user_id = :user_id
        ');
        $stmt->execute([
            'user_id' => $userId,
            'current' => $current,
            'longest' => $longest,
            'today' => $today,
        ]);
    }
}
