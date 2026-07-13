<?php

$surahStmt = $db->prepare('SELECT id FROM surahs WHERE number = 1');
$surahStmt->execute();
$surah = $surahStmt->fetch();

if (!$surah) return;

$lessons = [
    ['Аль-Фатиха — Начало', 'Изучите суру Аль-Фатиха с нуля', $surah['id'], 1, 7, 'beginner', 1, 50],
    ['Аль-Ихляс', 'Короткая сура для запоминания', null, 1, 4, 'beginner', 2, 20],
    ['Аль-Фалак и Ан-Нас', 'Суры-защиты', null, 1, 5, 'beginner', 3, 30],
];

$stmt = $db->prepare('
    INSERT INTO lessons (id, title, description, surah_id, start_ayah, end_ayah, difficulty, order_index, xp_reward)
    VALUES (:id, :title, :description, :surah_id, :start_ayah, :end_ayah, :difficulty, :order_index, :xp_reward)
');

foreach ($lessons as $l) {
    $stmt->execute([
        'id' => seedUuid(),
        'title' => $l[0],
        'description' => $l[1],
        'surah_id' => $l[2],
        'start_ayah' => $l[3],
        'end_ayah' => $l[4],
        'difficulty' => $l[5],
        'order_index' => $l[6],
        'xp_reward' => $l[7],
    ]);
}

echo "  Inserted " . count($lessons) . " lessons.\n";
