<?php

declare(strict_types=1);

require_once dirname(__DIR__) . '/vendor/autoload.php';

use Dotenv\Dotenv;
use App\Helpers\Database;

$dotenv = Dotenv::createImmutable(dirname(__DIR__));
$dotenv->safeLoad();

$db = Database::connect();

function seedUuid(): string
{
    $data = random_bytes(16);
    $data[6] = chr((ord($data[6]) & 0x0f) | 0x40);
    $data[8] = chr((ord($data[8]) & 0x3f) | 0x80);

    return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
}

require_once __DIR__ . '/seeds/audio_url.php';

echo "Seeding surahs...\n";
require __DIR__ . '/seeds/surahs.php';

echo "Seeding Al-Fatiha ayahs...\n";
require __DIR__ . '/seeds/al_fatiha.php';

echo "Seeding short surahs (112-114)...\n";
require __DIR__ . '/seeds/short_surahs.php';

echo "Seeding Kazakh surah names...\n";
require __DIR__ . '/seeds/kazakh_surahs.php';

echo "Seeding achievements...\n";
require __DIR__ . '/seeds/achievements.php';

echo "Seeding lessons...\n";
require __DIR__ . '/seeds/lessons.php';

echo "Seeding demo user...\n";
require __DIR__ . '/seeds/demo_user.php';

echo "All seeds completed.\n";
