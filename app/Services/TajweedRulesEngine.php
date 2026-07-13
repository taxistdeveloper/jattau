<?php

declare(strict_types=1);

namespace App\Services;

class TajweedRulesEngine
{
    private const RULES = [
        'ghunnah' => ['ن', 'م'],
        'qalqalah' => ['ق', 'ط', 'ب', 'ج', 'د'],
        'madd' => ['ا', 'و', 'ي', 'ى'],
        'ikhfa' => ['ت', 'ث', 'ج', 'د', 'ذ', 'ز', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ف', 'ق', 'ك'],
    ];

    private const DESCRIPTIONS = [
        'ru' => [
            'ghunnah' => 'Примените гунну (назализацию) при произнесении нун/мим',
            'qalqalah' => 'Примените калькалю (эхо) для буквы %s',
            'madd' => 'Удлините гласную (мадд) для буквы %s',
        ],
        'kk' => [
            'ghunnah' => 'Нүн/мим әрпін айтқанда гунна (мұрынмен айту) қолданыңыз',
            'qalqalah' => '%s әрпі үшін қалқала (жаңғырық) қолданыңыз',
            'madd' => '%s әрпі үшін дауыстыны созыңыз (мадд)',
        ],
    ];

    public function analyze(string $text, string $transcribed, string $lang = 'ru'): array
    {
        $errors = [];
        $words = preg_split('/\s+/u', trim($text), -1, PREG_SPLIT_NO_EMPTY);

        foreach ($words as $idx => $word) {
            $wordErrors = $this->checkWord($word, $idx, $lang);
            $errors = array_merge($errors, $wordErrors);
        }

        return $errors;
    }

    private function checkWord(string $word, int $position, string $lang = 'ru'): array
    {
        $descriptions = self::DESCRIPTIONS[$lang] ?? self::DESCRIPTIONS['ru'];
        $errors = [];
        $chars = preg_split('//u', $word, -1, PREG_SPLIT_NO_EMPTY);

        foreach ($chars as $i => $char) {
            if ($char === 'ن' && isset($chars[$i + 1]) && in_array($chars[$i + 1], ['ب', 'م'], true)) {
                $errors[] = [
                    'rule' => 'ghunnah',
                    'description' => $descriptions['ghunnah'],
                    'word' => $word,
                    'position' => $position,
                    'char_index' => $i,
                ];
            }

            if (in_array($char, self::RULES['qalqalah'], true) && $i === count($chars) - 1) {
                $errors[] = [
                    'rule' => 'qalqalah',
                    'description' => sprintf($descriptions['qalqalah'], $char),
                    'word' => $word,
                    'position' => $position,
                    'char_index' => $i,
                ];
            }

            if (in_array($char, self::RULES['madd'], true)) {
                $errors[] = [
                    'rule' => 'madd',
                    'description' => sprintf($descriptions['madd'], $char),
                    'word' => $word,
                    'position' => $position,
                    'char_index' => $i,
                ];
            }
        }

        return $errors;
    }
}
