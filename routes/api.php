<?php

declare(strict_types=1);

use App\Helpers\Router;
use App\Middleware\AuthMiddleware;
use App\Controllers\AuthController;
use App\Controllers\UserController;
use App\Controllers\SurahController;
use App\Controllers\AyahController;
use App\Controllers\RecitationController;
use App\Controllers\StatisticsController;
use App\Controllers\MemorizationController;

$router = new Router();

// Auth (public)
$router->post('/api/v1/auth/register', [AuthController::class, 'register']);
$router->post('/api/v1/auth/login', [AuthController::class, 'login']);
$router->post('/api/v1/auth/refresh', [AuthController::class, 'refresh']);

// User (protected)
$router->get('/api/v1/user/profile', [UserController::class, 'profile'], [AuthMiddleware::class]);

// Surahs (protected)
$router->get('/api/v1/surahs', [SurahController::class, 'index'], [AuthMiddleware::class]);
$router->get('/api/v1/surahs/{id}', [SurahController::class, 'show'], [AuthMiddleware::class]);

// Ayahs (protected)
$router->get('/api/v1/surahs/{surahId}/ayahs', [AyahController::class, 'bySurah'], [AuthMiddleware::class]);
$router->get('/api/v1/ayahs/{id}', [AyahController::class, 'show'], [AuthMiddleware::class]);

// Recitations (protected)
$router->post('/api/v1/recitations', [RecitationController::class, 'store'], [AuthMiddleware::class]);
$router->get('/api/v1/recitations/{id}', [RecitationController::class, 'show'], [AuthMiddleware::class]);
$router->get('/api/v1/recitations/errors', [RecitationController::class, 'errors'], [AuthMiddleware::class]);

// Statistics (protected)
$router->get('/api/v1/statistics', [StatisticsController::class, 'index'], [AuthMiddleware::class]);
$router->get('/api/v1/mentor/recommendations', [StatisticsController::class, 'mentor'], [AuthMiddleware::class]);

// Memorization (protected)
$router->get('/api/v1/memorization/due', [MemorizationController::class, 'dueCards'], [AuthMiddleware::class]);
$router->post('/api/v1/memorization/review', [MemorizationController::class, 'review'], [AuthMiddleware::class]);

// Health check
$router->get('/api/v1/health', function () {
    \App\Helpers\Response::success(['status' => 'ok', 'version' => '1.0.0']);
});

$router->get('/', function () {
    $basePath = rtrim(dirname($_SERVER['SCRIPT_NAME'] ?? ''), '/');
    \App\Helpers\Response::success([
        'name' => 'Jattau API',
        'version' => '1.0.0',
        'health' => $basePath . '/api/v1/health',
        'docs' => $basePath . '/api/docs',
        'openapi' => $basePath . '/api/openapi.yaml',
    ]);
});

$router->get('/api/v1', function () {
    \App\Helpers\Response::success([
        'version' => '1.0.0',
        'endpoints' => [
            'POST /api/v1/auth/register',
            'POST /api/v1/auth/login',
            'POST /api/v1/auth/refresh',
            'GET /api/v1/health',
            'GET /api/v1/surahs',
            'GET /api/v1/statistics',
        ],
    ]);
});

$router->get('/api/docs', function () {
    $basePath = rtrim(dirname($_SERVER['SCRIPT_NAME'] ?? ''), '/');
    $specUrl = htmlspecialchars($basePath . '/api/openapi.yaml', ENT_QUOTES);

    http_response_code(200);
    header('Content-Type: text/html; charset=utf-8');
    echo <<<HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Jattau API Docs</title>
    <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css">
</head>
<body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
    <script>
        SwaggerUIBundle({
            url: '{$specUrl}',
            dom_id: '#swagger-ui',
        });
    </script>
</body>
</html>
HTML;
    exit;
});

return $router;
