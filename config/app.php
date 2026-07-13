<?php

return [
    'name' => $_ENV['APP_NAME'] ?? 'Jattau',
    'env' => $_ENV['APP_ENV'] ?? 'production',
    'debug' => filter_var($_ENV['APP_DEBUG'] ?? false, FILTER_VALIDATE_BOOLEAN),
    'url' => $_ENV['APP_URL'] ?? 'http://localhost:8080',
    'accuracy_threshold' => (float) ($_ENV['ACCURACY_THRESHOLD'] ?? 85),
    'max_audio_size_mb' => (int) ($_ENV['MAX_AUDIO_SIZE_MB'] ?? 10),
    'allowed_audio_types' => explode(',', $_ENV['ALLOWED_AUDIO_TYPES'] ?? 'audio/wav,audio/mpeg,audio/mp4'),
    'log_level' => $_ENV['LOG_LEVEL'] ?? 'info',
    'storage_path' => dirname(__DIR__) . '/' . ($_ENV['STORAGE_PATH'] ?? 'storage'),
];
