<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/vendor/autoload.php';

use Dotenv\Dotenv;
use App\Helpers\Database;

$dotenv = Dotenv::createImmutable(dirname(__DIR__));
$dotenv->safeLoad();

$db = Database::connect();

$db->exec('CREATE TABLE IF NOT EXISTS migrations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    migration VARCHAR(255) NOT NULL,
    executed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');

function runSqlStatements(\PDO $db, string $sql): void
{
    $sql = preg_replace('/--.*$/m', '', $sql);
    $statements = array_filter(array_map('trim', explode(';', $sql)));

    foreach ($statements as $statement) {
        if ($statement !== '') {
            $db->exec($statement);
        }
    }
}

$migrationsDir = __DIR__ . '/migrations';
$files = glob($migrationsDir . '/*.sql');
sort($files);

foreach ($files as $file) {
    $name = basename($file);
    $check = $db->prepare('SELECT id FROM migrations WHERE migration = :name');
    $check->execute(['name' => $name]);

    if ($check->fetch()) {
        echo "Skipping: {$name}\n";
        continue;
    }

    echo "Running: {$name}\n";
    runSqlStatements($db, file_get_contents($file));

    $db->prepare('INSERT INTO migrations (migration) VALUES (:name)')->execute(['name' => $name]);
    echo "Done: {$name}\n";
}

echo "All migrations completed.\n";
