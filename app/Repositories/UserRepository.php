<?php

declare(strict_types=1);

namespace App\Repositories;

class UserRepository extends BaseRepository
{
    public function findByEmail(string $email): ?array
    {
        $stmt = $this->db->prepare('SELECT * FROM users WHERE email = :email LIMIT 1');
        $stmt->execute(['email' => $email]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function findById(string $id): ?array
    {
        $stmt = $this->db->prepare('SELECT id, email, full_name, role, avatar_url, level, experience_points, daily_goal_minutes, preferred_language, created_at FROM users WHERE id = :id AND is_active = 1 LIMIT 1');
        $stmt->execute(['id' => $id]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function create(array $data): array
    {
        $id = $this->uuid();
        $stmt = $this->db->prepare('
            INSERT INTO users (id, email, password_hash, pin_hash, full_name, role)
            VALUES (:id, :email, :password_hash, :pin_hash, :full_name, :role)
        ');
        $stmt->execute([
            'id' => $id,
            'email' => $data['email'],
            'password_hash' => $data['password_hash'],
            'pin_hash' => $data['pin_hash'],
            'full_name' => $data['full_name'],
            'role' => $data['role'] ?? 'user',
        ]);

        return $this->findById($id) ?? [];
    }

    public function saveRefreshToken(string $userId, string $tokenHash, string $expiresAt): void
    {
        $stmt = $this->db->prepare('
            INSERT INTO refresh_tokens (id, user_id, token_hash, expires_at)
            VALUES (:id, :user_id, :token_hash, :expires_at)
        ');
        $stmt->execute([
            'id' => $this->uuid(),
            'user_id' => $userId,
            'token_hash' => $tokenHash,
            'expires_at' => $expiresAt,
        ]);
    }

    public function findRefreshToken(string $tokenHash): ?array
    {
        $stmt = $this->db->prepare('
            SELECT * FROM refresh_tokens
            WHERE token_hash = :hash AND revoked_at IS NULL AND expires_at > NOW()
            LIMIT 1
        ');
        $stmt->execute(['hash' => $tokenHash]);
        $row = $stmt->fetch();
        return $row ?: null;
    }

    public function revokeRefreshToken(string $tokenHash): void
    {
        $stmt = $this->db->prepare('UPDATE refresh_tokens SET revoked_at = NOW() WHERE token_hash = :hash');
        $stmt->execute(['hash' => $tokenHash]);
    }

    public function initUserData(string $userId): void
    {
        $this->insertIgnore('statistics', $userId);
        $this->insertIgnore('streaks', $userId);
        $this->insertIgnore('settings', $userId);
    }

    private function insertIgnore(string $table, string $userId): void
    {
        $id = $this->uuid();
        $stmt = $this->db->prepare("INSERT IGNORE INTO {$table} (id, user_id) VALUES (:id, :user_id)");
        $stmt->execute(['id' => $id, 'user_id' => $userId]);
    }
}
