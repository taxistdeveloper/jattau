<?php

declare(strict_types=1);

namespace App\Helpers;

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JwtHelper
{
    private array $config;

    public function __construct()
    {
        $this->config = require dirname(__DIR__, 2) . '/config/jwt.php';
    }

    public function generateAccessToken(string $userId, string $role): string
    {
        $now = time();
        $payload = [
            'iss' => $this->config['issuer'],
            'sub' => $userId,
            'role' => $role,
            'type' => 'access',
            'iat' => $now,
            'exp' => $now + $this->config['access_ttl'],
        ];

        return JWT::encode($payload, $this->config['secret'], $this->config['algorithm']);
    }

    public function generateRefreshToken(string $userId): string
    {
        $now = time();
        $payload = [
            'iss' => $this->config['issuer'],
            'sub' => $userId,
            'type' => 'refresh',
            'iat' => $now,
            'exp' => $now + $this->config['refresh_ttl'],
            'jti' => bin2hex(random_bytes(16)),
        ];

        return JWT::encode($payload, $this->config['secret'], $this->config['algorithm']);
    }

    public function decode(string $token): object
    {
        return JWT::decode($token, new Key($this->config['secret'], $this->config['algorithm']));
    }

    public function hashToken(string $token): string
    {
        return hash('sha256', $token);
    }
}
