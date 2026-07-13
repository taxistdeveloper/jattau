<?php

// [code, title_ru, description_ru, icon, xp_reward, category, title_kk, description_kk]
$achievements = [
    ['first_ayah', 'Первый аят', 'Прочитайте свой первый аят', 'star', 10, 'reading', 'Бірінші аят', 'Алғашқы аятыңызды оқыңыз'],
    ['first_surah', 'Первая сура', 'Завершите чтение целой суры', 'book', 50, 'reading', 'Бірінші сүре', 'Бүкіл сүрені оқып бітіріңіз'],
    ['streak_3', '3 дня подряд', 'Занимайтесь 3 дня без пропусков', 'fire', 20, 'streak', 'Қатарынан 3 күн', '3 күн үзіліссіз айналысыңыз'],
    ['streak_7', 'Неделя', '7 дней подряд без пропусков', 'fire', 50, 'streak', 'Апта', 'Қатарынан 7 күн үзіліссіз'],
    ['streak_30', 'Месяц', '30 дней подряд без пропусков', 'fire', 200, 'streak', 'Ай', 'Қатарынан 30 күн үзіліссіз'],
    ['accuracy_90', 'Точность 90%', 'Достигните 90% точности в чтении', 'target', 30, 'reading', 'Дәлдік 90%', 'Оқуда 90% дәлдікке жетіңіз'],
    ['accuracy_100', 'Идеально', 'Прочитайте аят со 100% точностью', 'trophy', 50, 'reading', 'Мінсіз', 'Аятты 100% дәлдікпен оқыңыз'],
    ['ayahs_10', '10 аятов', 'Изучите 10 аятов', 'book', 25, 'reading', '10 аят', '10 аят үйреніңіз'],
    ['ayahs_50', '50 аятов', 'Изучите 50 аятов', 'book', 100, 'reading', '50 аят', '50 аят үйреніңіз'],
    ['ayahs_100', '100 аятов', 'Изучите 100 аятов', 'book', 250, 'reading', '100 аят', '100 аят үйреніңіз'],
    ['memorize_5', '5 аятов наизусть', 'Запомните 5 аятов', 'brain', 75, 'memorization', '5 аят жатқа', '5 аятты жаттаңыз'],
    ['memorize_20', '20 аятов наизусть', 'Запомните 20 аятов', 'brain', 200, 'memorization', '20 аят жатқа', '20 аятты жаттаңыз'],
    ['level_5', 'Уровень 5', 'Достигните 5 уровня', 'level', 0, 'reading', '5-деңгей', '5-деңгейге жетіңіз'],
    ['level_10', 'Уровень 10', 'Достигните 10 уровня', 'level', 0, 'reading', '10-деңгей', '10-деңгейге жетіңіз'],
    ['daily_goal', 'Ежедневная цель', 'Выполните ежедневную цель', 'check', 15, 'streak', 'Күнделікті мақсат', 'Күнделікті мақсатты орындаңыз'],
];

$stmt = $db->prepare('
    INSERT INTO achievements (id, code, title, description, icon, xp_reward, category, title_kk, description_kk)
    VALUES (:id, :code, :title, :description, :icon, :xp_reward, :category, :title_kk, :description_kk)
    ON DUPLICATE KEY UPDATE
        title_kk = VALUES(title_kk),
        description_kk = VALUES(description_kk)
');

foreach ($achievements as $a) {
    $stmt->execute([
        'id' => seedUuid(),
        'code' => $a[0],
        'title' => $a[1],
        'description' => $a[2],
        'icon' => $a[3],
        'xp_reward' => $a[4],
        'category' => $a[5],
        'title_kk' => $a[6],
        'description_kk' => $a[7],
    ]);
}

echo "  Inserted " . count($achievements) . " achievements.\n";
