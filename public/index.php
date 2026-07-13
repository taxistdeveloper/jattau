<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/vendor/autoload.php';

use Dotenv\Dotenv;
use App\Middleware\CorsMiddleware;
use App\Helpers\Request;
use App\Helpers\Response;
use App\Helpers\Logger;

$dotenv = Dotenv::createImmutable(dirname(__DIR__));
$dotenv->safeLoad();

set_error_handler(function (int $errno, string $errstr, string $errfile, int $errline) {
    throw new ErrorException($errstr, 0, $errno, $errfile, $errline);
});

set_exception_handler(function (Throwable $e) {
    $logger = new Logger();
    $logger->error($e->getMessage(), [
        'file' => $e->getFile(),
        'line' => $e->getLine(),
        'trace' => $e->getTraceAsString(),
    ]);

    $config = require dirname(__DIR__) . '/config/app.php';
    $message = $config['debug'] ? $e->getMessage() : 'Internal Server Error';
    Response::error($message, 500);
});

$uri = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
$scriptName = $_SERVER['SCRIPT_NAME'] ?? '';
$basePath = str_ends_with($scriptName, '.php') ? rtrim(dirname($scriptName), '/') : '';

if ($basePath !== '' && str_starts_with($uri, $basePath)) {
    $uri = substr($uri, strlen($basePath)) ?: '/';
} else {
    $projectRoot = dirname($basePath);
    if ($projectRoot !== '/' && $projectRoot !== '\\' && str_starts_with($uri, $projectRoot)) {
        $uri = substr($uri, strlen($projectRoot)) ?: '/';
    }
}

$cors = new CorsMiddleware();
$request = new Request($_SERVER['REQUEST_METHOD'], $uri);
$cors->handle($request);

$router = require dirname(__DIR__) . '/routes/api.php';
$router->dispatch($_SERVER['REQUEST_METHOD'], $uri);
