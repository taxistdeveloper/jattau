<?php

declare(strict_types=1);

namespace App\Services;

use App\Repositories\UserRepository;
use App\Helpers\JwtHelper;

class AuthService
{
    public function __construct(
        private UserRepository $userRepo = new UserRepository(),
        private JwtHelper $jwt = new JwtHelper(),
    ) {}

    public function register(string $email, string $password, string $fullName): array
    {
        if ($this->userRepo->findByEmail($email)) {
            throw new \InvalidArgumentException('Email already registered');
        }

        $user = $this->userRepo->create([
            'email' => $email,
            'password_hash' => password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]),
            'full_name' => $fullName,
            'role' => 'user',
        ]);

        $this->userRepo->initUserData($user['id']);

        return $this->generateTokens($user);
    }

    public function login(string $email, string $password): array
    {
        $user = $this->userRepo->findByEmail($email);
        if (!$user || !password_verify($password, $user['password_hash'])) {
            throw new \InvalidArgumentException('Invalid credentials');
        }

        if (!$user['is_active']) {
            throw new \InvalidArgumentException('Account is deactivated');
        }

        return $this->generateTokens($user);
    }

    public function refresh(string $refreshToken): array
    {
        $decoded = $this->jwt->decode($refreshToken);
        if (($decoded->type ?? '') !== 'refresh') {
            throw new \InvalidArgumentException('Invalid refresh token');
        }

        $tokenHash = $this->jwt->hashToken($refreshToken);
        $stored = $this->userRepo->findRefreshToken($tokenHash);
        if (!$stored) {
            throw new \InvalidArgumentException('Refresh token revoked or expired');
        }

        $this->userRepo->revokeRefreshToken($tokenHash);

        $user = $this->userRepo->findById($decoded->sub);
        if (!$user) {
            throw new \InvalidArgumentException('User not found');
        }

        return $this->generateTokens($user);
    }

    private function generateTokens(array $user): array
    {
        $accessToken = $this->jwt->generateAccessToken($user['id'], $user['role']);
        $refreshToken = $this->jwt->generateRefreshToken($user['id']);

        $expiresAt = date('Y-m-d H:i:s', time() + 604800);
        $this->userRepo->saveRefreshToken($user['id'], $this->jwt->hashToken($refreshToken), $expiresAt);

        return [
            'user' => [
                'id' => $user['id'],
                'email' => $user['email'],
                'full_name' => $user['full_name'],
                'role' => $user['role'],
                'level' => $user['level'] ?? 1,
                'experience_points' => $user['experience_points'] ?? 0,
            ],
            'access_token' => $accessToken,
            'refresh_token' => $refreshToken,
            'token_type' => 'Bearer',
            'expires_in' => 900,
        ];
    }
}
