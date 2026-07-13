<?php

declare(strict_types=1);

namespace App\Helpers;

class Request
{
    public function __construct(
        public readonly string $method,
        public readonly string $uri,
        public readonly array $params = [],
    ) {}

    public function input(string $key, mixed $default = null): mixed
    {
        $body = $this->body();
        return $body[$key] ?? $_POST[$key] ?? $_GET[$key] ?? $default;
    }

    public function body(): array
    {
        static $parsed = null;
        if ($parsed === null) {
            $raw = file_get_contents('php://input');
            $parsed = json_decode($raw ?: '{}', true) ?? [];
        }
        return $parsed;
    }

    public function bearerToken(): ?string
    {
        $header = $_SERVER['HTTP_AUTHORIZATION']
            ?? $_SERVER['REDIRECT_HTTP_AUTHORIZATION']
            ?? $this->apacheAuthorizationHeader()
            ?? '';

        if (preg_match('/Bearer\s+(.+)/i', $header, $matches)) {
            return trim($matches[1]);
        }
        return null;
    }

    private function apacheAuthorizationHeader(): ?string
    {
        if (function_exists('apache_request_headers')) {
            $headers = apache_request_headers();
            foreach ($headers as $key => $value) {
                if (strtolower($key) === 'authorization') {
                    return $value;
                }
            }
        }

        if (function_exists('getallheaders')) {
            foreach (getallheaders() as $key => $value) {
                if (strtolower($key) === 'authorization') {
                    return $value;
                }
            }
        }

        return null;
    }

    public function file(string $key): ?array
    {
        return $_FILES[$key] ?? null;
    }

    public function header(string $name): ?string
    {
        $key = 'HTTP_' . strtoupper(str_replace('-', '_', $name));
        return $_SERVER[$key] ?? null;
    }

    public function userId(): ?string
    {
        return $GLOBALS['auth_user_id'] ?? null;
    }

    /**
     * Resolves the request language from the Accept-Language header.
     * Falls back to Russian when the language is missing or unsupported.
     */
    public function language(): string
    {
        $supported = ['ru', 'kk'];
        $header = $this->header('Accept-Language') ?? '';
        $lang = strtolower(substr(trim($header), 0, 2));
        return in_array($lang, $supported, true) ? $lang : 'ru';
    }

    public function userRole(): ?string
    {
        return $GLOBALS['auth_user_role'] ?? null;
    }
}
