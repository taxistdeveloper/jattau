<?php

// Short surahs with full transliterations (Latin + Kazakh Cyrillic) and translations
$shortSurahs = [
    112 => [
        'global_start' => 6222,
        'juz' => 30,
        'page' => 604,
        'ayahs' => [
            [1, 'قُلْ هُوَ اللَّهُ أَحَدٌ', 'Qul huwa Allahu ahad', 'Де: Он – Аллах Един.', 'Құл һува Аллаһу əхад', 'Де: Ол – Алла, Жалғыз.'],
            [2, 'اللَّهُ الصَّمَدُ', 'Allahu as-Samad', 'Аллах – Вечный!', 'Аллаһус-сәмәд', 'Алла – Мəңгілік!'],
            [3, 'لَمْ يَلِدْ وَلَمْ يُولَدْ', 'Lam yalid wa lam yulad', 'Он не рождал и не был рождён,', 'Ләм ялид уә ләм йулад', 'Ол туған жоқ, туылмаған.'],
            [4, 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ', 'Wa lam yakun lahu kufuwan ahad', 'и нет никого, равного Ему.', 'Уә ләм якүн ләһу куфуән əхад', 'Оның теңі болған ешкім жоқ.'],
        ],
    ],
    113 => [
        'global_start' => 6226,
        'juz' => 30,
        'page' => 604,
        'ayahs' => [
            [1, 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ', 'Qul a-oodhu bi rabbi al-falaq', 'Скажи: «Прибегаю к защите Господа рассвета', 'Құл ә\'узу би Раббил-фәләқ', 'Де: Тaңның Раббысына сыйынамын'],
            [2, 'مِن شَرِّ مَا خَلَقَ', 'Min sharri ma khalaq', 'от зла того, что Он сотворил,', 'Мин шарри мә хәлақ', 'Оның жаратқанының зиянынан,'],
            [3, 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ', 'Wa min sharri ghasiqin idha waqab', 'от зла мрака, когда он сгущается,', 'Уә мин шарри ғасиқин изә уәқаб', 'Қараңғы түскенде түннің зиянынан,'],
            [4, 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ', 'Wa min sharri an-naffathati fil-uqad', 'от зла колдуний, дующих на узлы,', 'Уә мин шаррин-нәффасати фил-\'уқад', 'Түйіндерге үргендердің зиянынан,'],
            [5, 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَдَ', 'Wa min sharri hasidin idha hasad', 'и от зла завистника, когда он завидует».', 'Уә мин шарри хасидин изә хәсәд', 'Көңілі қалғанда қызғанышкердің зиянынан.'],
        ],
    ],
    114 => [
        'global_start' => 6231,
        'juz' => 30,
        'page' => 604,
        'ayahs' => [
            [1, 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ', 'Qul a-oodhu bi rabbi an-nas', 'Скажи: «Прибегаю к защите Господа людей,', 'Құл ә\'узу би Раббин-нас', 'Де: Адамзаттың Раббысына сыйынамын,'],
            [2, 'مَلِكِ النَّاسِ', 'Maliki an-nas', 'Царя людей,', 'Мәликин-нас', 'Адамзаттың Пəтшасына,'],
            [3, 'إِلَٰهِ النَّاسِ', 'Ilahi an-nas', 'Бога людей', 'Илаһин-нас', 'Адамзаттың Құдайына,'],
            [4, 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ', 'Min sharri al-waswasi al-khannas', 'от зла наущающего шептуна,', 'Мин шаррил-васвасил-хәннас', 'Жасырын уытқырдың зиянынан,'],
            [5, 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ', 'Alladhi yuwaswisu fi suduri an-nas', 'который нашёптывает в груди людей,', 'Әл-ләзи йуәсвису фи судурир-нас', 'Адамзаттың кеудесіне уытқырлағаннан,'],
            [6, 'مِنَ الْجِنَّةِ وَالنَّاسِ', 'Mina al-jinnati wan-nas', 'из числа джиннов и людей».', 'Минәл-жиннати уан-нас', 'Джіндер мен адамдар арасынан.'],
        ],
    ],
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
        text_transliteration = VALUES(text_transliteration),
        text_transliteration_kk = VALUES(text_transliteration_kk),
        text_translation_ru = VALUES(text_translation_ru),
        text_translation_kk = VALUES(text_translation_kk)
');

$total = 0;

foreach ($shortSurahs as $surahNumber => $data) {
    $surahStmt = $db->prepare('SELECT id FROM surahs WHERE number = :number');
    $surahStmt->execute(['number' => $surahNumber]);
    $surah = $surahStmt->fetch();
    if (!$surah) {
        echo "  Surah {$surahNumber} not found, skipping.\n";
        continue;
    }

    foreach ($data['ayahs'] as $i => $a) {
        $globalNumber = $data['global_start'] + $i;
        $ayahStmt->execute([
            'id' => seedUuid(),
            'surah_id' => $surah['id'],
            'number' => $a[0],
            'global_number' => $globalNumber,
            'juz_number' => $data['juz'],
            'page_number' => $data['page'],
            'audio_url' => seedAudioUrl($surahNumber, $a[0]),
        ]);

        $findStmt = $db->prepare('SELECT id FROM ayahs WHERE global_number = :gn');
        $findStmt->execute(['gn' => $globalNumber]);
        $ayah = $findStmt->fetch();
        if (!$ayah) continue;

        $words = preg_split('/\s+/u', trim($a[1]), -1, PREG_SPLIT_NO_EMPTY);
        $textStmt->execute([
            'id' => seedUuid(),
            'ayah_id' => $ayah['id'],
            'text_uthmani' => $a[1],
            'text_simple' => $a[1],
            'text_transliteration' => $a[2],
            'text_translation_ru' => $a[3],
            'text_transliteration_kk' => $a[4],
            'text_translation_kk' => $a[5],
            'word_count' => count($words),
        ]);
        $total++;
    }
}

echo "  Inserted {$total} ayahs for short surahs (112-114).\n";
