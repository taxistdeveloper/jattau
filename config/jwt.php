<?php

return [
    'secret' => $_ENV['JWT_SECRET'] ?? 'insecure-default-change-me',
    'access_ttl' => (int) ($_ENV['JWT_ACCESS_TTL'] ?? 900),
    'refresh_ttl' => (int) ($_ENV['JWT_REFRESH_TTL'] ?? 604800),
    'algorithm' => 'HS256',
    'issuer' => $_ENV['APP_URL'] ?? 'http://localhost:8080',
];
