<?php

$surahStmt = $db->prepare('SELECT id FROM surahs WHERE number = 1');
$surahStmt->execute();
$surah = $surahStmt->fetch();

if (!$surah) {
    echo "  Surah Al-Fatiha not found. Run surahs seed first.\n";
    return;
}

$surahId = $surah['id'];

// [number, global_number, uthmani, latin_translit, ru_translation, kk_translit, kk_translation]
$ayahs = [
    [1, 1, 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', 'Bismi Allahi ar-Rahmani ar-Raheem', 'Во имя Аллаха, Милостивого, Милосердного!', 'Бисмилләһир-Рахманир-Рахим', 'Рахман, Рахим – қамқор әрі мейірімді Алланың атымен.'],
    [2, 2, 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', 'Alhamdu lillahi rabbi al-alameen', 'Хвала Аллаху, Господу миров!', 'Әлхамду лилләһи Раббил-ғаләмин', 'Мактоу Эллие ғаламдардың Раббысына!'],
    [3, 3, 'الرَّحْمَٰنِ الرَّحِيمِ', 'Ar-Rahmani ar-Raheem', 'Милостивому, Милосердному,', 'Әр-Рахманир-Рахим', 'Рахман, Рахим!'],
    [4, 4, 'مَالِكِ يَوْمِ الدِّينِ', 'Maliki yawmi ad-deen', 'Властелину Дня воздаяния!', 'Малики явми-ддин', 'Қиямет күнінің әміршісі!'],
    [5, 5, 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ', 'Iyyaka na-budu wa iyyaka nasta-een', 'Тебе одному мы поклоняемся и Тебя одного молим о помощи.', 'Иййәкә нә\'буду уә иййәкә нәста\'ин', '(Тек) Саған ғана табынамыз және (Тек) Сенен ғана көмек сұраймыз.'],
    [6, 6, 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ', 'Ihdina as-sirata al-mustaqeem', 'Веди нас прямым путём,', 'Иһдина-с-сыратал-мұстақым', 'Бізді түзу жолға бағытта!'],
    [7, 7, 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ', 'Sirata alladhina an-amta alayhim ghayri al-maghdubi alayhim wa la ad-dalleen', 'путём тех, к кому Ты явил милость, не тех, на кого пал гнев, и не заблудших.', 'Сыратал-ләзина əн\'амтә \'алейһим ğәйрил-мағдуби \'алейһим уә ләд-дәллин', 'Өз ыңғайына дәл келдіргендердің жолымен, оған ашу күйіп-өнгендердің және адасқандардың емес.'],
];

$ayahStmt = $db->prepare('
    INSERT IGNORE INTO ayahs (id, surah_id, number, global_number, juz_number, page_number, audio_url)
    VALUES (:id, :surah_id, :number, :global_number, :juz_number, :page_number, :audio_url)
');

$textStmt = $db->prepare('
    INSERT INTO quran_text (id, ayah_id, text_uthmani, text_simple, text_transliteration, text_translation_ru,
                            text_transliteration_kk, text_translation_kk, word_count)
    VALUES (:id, :ayah_id, :text_uthmani, :text_simple, :text_transliteration, :text_translation_ru,
            :text_transliteration_kk, :text_translation_kk, :word_count)
    ON DUPLICATE KEY UPDATE
        text_transliteration_kk = VALUES(text_transliteration_kk),
        text_translation_kk = VALUES(text_translation_kk)
');

foreach ($ayahs as $a) {
    $ayahId = seedUuid();
    $ayahStmt->execute([
        'id' => $ayahId,
        'surah_id' => $surahId,
        'number' => $a[0],
        'global_number' => $a[1],
        'juz_number' => 1,
        'page_number' => 1,
        'audio_url' => seedAudioUrl(1, $a[0]),
    ]);

    $findStmt = $db->prepare('SELECT id FROM ayahs WHERE global_number = :gn');
    $findStmt->execute(['gn' => $a[1]]);
    $ayah = $findStmt->fetch();
    if (!$ayah) continue;

    $words = preg_split('/\s+/u', trim($a[2]), -1, PREG_SPLIT_NO_EMPTY);
    $textStmt->execute([
        'id' => seedUuid(),
        'ayah_id' => $ayah['id'],
        'text_uthmani' => $a[2],
        'text_simple' => $a[2],
        'text_transliteration' => $a[3],
        'text_translation_ru' => $a[4],
        'text_transliteration_kk' => $a[5],
        'text_translation_kk' => $a[6],
        'word_count' => count($words),
    ]);
}

echo '  Inserted ' . count($ayahs) . " ayahs for Al-Fatiha.\n";
