<?php

declare(strict_types=1);

namespace App\Services;

class PronunciationAnalysisService
{
    private float $threshold;

    public function __construct()
    {
        $config = require dirname(__DIR__, 2) . '/config/app.php';
        $this->threshold = $config['accuracy_threshold'];
    }

    public function analyze(string $expected, string $transcribed): array
    {
        $expectedWords = $this->tokenize($expected);
        $transcribedWords = $this->tokenize($transcribed);

        $alignment = $this->alignWords($expectedWords, $transcribedWords);

        $correct = 0;
        $skipped = [];
        $extra = [];
        $mispronounced = [];
        $reordered = [];

        foreach ($alignment as $item) {
            match ($item['type']) {
                'correct' => $correct++,
                'skipped' => $skipped[] = [
                    'word' => $item['expected'],
                    'position' => $item['position'],
                ],
                'extra' => $extra[] = [
                    'word' => $item['actual'],
                    'position' => $item['position'],
                ],
                'mispronounced' => $mispronounced[] = [
                    'expected' => $item['expected'],
                    'actual' => $item['actual'],
                    'position' => $item['position'],
                    'similarity' => $item['similarity'],
                ],
                'reordered' => $reordered[] = [
                    'expected' => $item['expected'],
                    'actual' => $item['actual'],
                    'position' => $item['position'],
                ],
                default => null,
            };
        }

        $total = count($expectedWords);
        $accuracy = $total > 0 ? round(($correct / $total) * 100, 2) : 0;

        return [
            'accuracy_percent' => $accuracy,
            'is_passed' => $accuracy >= $this->threshold,
            'words_correct' => $correct,
            'words_total' => $total,
            'words_skipped' => $skipped,
            'words_extra' => $extra,
            'words_mispronounced' => $mispronounced,
            'words_reordered' => $reordered,
            'error_count' => count($skipped) + count($extra) + count($mispronounced) + count($reordered),
        ];
    }

    private function tokenize(string $text): array
    {
        $text = $this->normalizeArabic($text);
        $words = preg_split('/\s+/u', trim($text), -1, PREG_SPLIT_NO_EMPTY);
        return $words ?: [];
    }

    private function normalizeArabic(string $text): string
    {
        $text = preg_replace('/[\x{064B}-\x{065F}\x{0670}]/u', '', $text);
        $text = str_replace(['أ', 'إ', 'آ', 'ٱ'], 'ا', $text);
        $text = str_replace('ة', 'ه', $text);
        $text = str_replace('ى', 'ي', $text);
        return $text;
    }

    private function alignWords(array $expected, array $transcribed): array
    {
        $result = [];
        $tIdx = 0;

        foreach ($expected as $eIdx => $expWord) {
            if ($tIdx >= count($transcribed)) {
                $result[] = ['type' => 'skipped', 'expected' => $expWord, 'position' => $eIdx];
                continue;
            }

            $actWord = $transcribed[$tIdx];
            $similarity = $this->wordSimilarity($expWord, $actWord);

            if ($similarity >= 0.9) {
                $result[] = ['type' => 'correct', 'expected' => $expWord, 'actual' => $actWord, 'position' => $eIdx, 'similarity' => $similarity];
                $tIdx++;
            } elseif ($similarity >= 0.6) {
                $result[] = ['type' => 'mispronounced', 'expected' => $expWord, 'actual' => $actWord, 'position' => $eIdx, 'similarity' => $similarity];
                $tIdx++;
            } else {
                $foundAhead = $this->findWordAhead($expWord, $transcribed, $tIdx + 1, 3);
                if ($foundAhead !== null) {
                    $result[] = ['type' => 'reordered', 'expected' => $expWord, 'actual' => $transcribed[$foundAhead], 'position' => $eIdx];
                    $tIdx = $foundAhead + 1;
                } else {
                    $result[] = ['type' => 'skipped', 'expected' => $expWord, 'position' => $eIdx];
                }
            }
        }

        while ($tIdx < count($transcribed)) {
            $result[] = ['type' => 'extra', 'actual' => $transcribed[$tIdx], 'position' => $tIdx];
            $tIdx++;
        }

        return $result;
    }

    private function wordSimilarity(string $a, string $b): float
    {
        $a = $this->normalizeArabic($a);
        $b = $this->normalizeArabic($b);
        if ($a === $b) return 1.0;
        $maxLen = max(mb_strlen($a), mb_strlen($b));
        if ($maxLen === 0) return 1.0;
        return 1 - (levenshtein($a, $b) / $maxLen);
    }

    private function findWordAhead(string $word, array $transcribed, int $start, int $range): ?int
    {
        $end = min($start + $range, count($transcribed));
        for ($i = $start; $i < $end; $i++) {
            if ($this->wordSimilarity($word, $transcribed[$i]) >= 0.8) {
                return $i;
            }
        }
        return null;
    }

    public function extractProblemLetters(array $mispronounced): array
    {
        $letters = [];
        foreach ($mispronounced as $item) {
            $expected = $item['expected'] ?? '';
            $chars = preg_split('//u', $expected, -1, PREG_SPLIT_NO_EMPTY);
            foreach ($chars as $char) {
                if (preg_match('/[\x{0600}-\x{06FF}]/u', $char)) {
                    $letters[$char] = ($letters[$char] ?? 0) + 1;
                }
            }
        }
        arsort($letters);
        return $letters;
    }
}
