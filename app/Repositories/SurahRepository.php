<?php

declare(strict_types=1);

namespace App\Repositories;

use PDO;

class SurahRepository extends BaseRepository
{
    public function all(int $page = 1, int $perPage = 114): array
    {
        $offset = ($page - 1) * $perPage;
        $countStmt = $this->db->query('SELECT COUNT(*) FROM surahs');
        $total = (int) $countStmt->fetchColumn();

        $stmt = $this->db->prepare('
            SELECT id, number, name_arabic, name_transliteration, name_translation,
                   name_translation_kk, revelation_type, ayah_count, order_index
            FROM surahs ORDER BY number ASC LIMIT :limit OFFSET :offset
        ');
        $stmt->bindValue('limit', $perPage, PDO::PARAM_INT);
        $stmt->bindValue('offset', $offset, PDO::PARAM_INT);
        $stmt->execute();

        return ['items' => $stmt->fetchAll(), 'total' => $total];
    }

    public function findById(string $id): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM surahs WHERE id = :id LIMIT 1');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function findByNumber(int $number): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM surahs WHERE number = :number LIMIT 1');
        $stmt->execute(['number' => $number]);
        $row = $stmt->fetch();
        return $row ?: null;
    }
}
