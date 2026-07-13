<?php

declare(strict_types=1);

namespace App\Services;

use App\Repositories\StatisticsRepository;
use App\Repositories\RecitationRepository;

class AiMentorService
{
    public function __construct(
        private StatisticsRepository $statsRepo = new StatisticsRepository(),
        private RecitationRepository $recitationRepo = new RecitationRepository(),
        private AiFeedbackService $feedbackService = new AiFeedbackService(),
    ) {}

    private const MESSAGES = [
        'ru' => [
            'streak' => 'Начните серию! Прочитайте хотя бы один аят сегодня.',
            'pronunciation' => 'Вы часто ошибаетесь в произношении буквы «%s». Рекомендуем повторить соответствующие аяты.',
            'practice' => 'Ваша средняя точность ниже 70%. Рекомендуем повторить суру Аль-Фатиха.',
            'continue' => 'Отличный прогресс! Продолжайте изучение следующей суры.',
        ],
        'kk' => [
            'streak' => 'Серияны бастаңыз! Бүгін кемінде бір аят оқыңыз.',
            'pronunciation' => '«%s» әрпін айтуда жиі қателесесіз. Тиісті аяттарды қайталауды ұсынамыз.',
            'practice' => 'Орташа дәлдігіңіз 70%-дан төмен. Әл-Фатиха сүресін қайталауды ұсынамыз.',
            'continue' => 'Керемет прогресс! Келесі сүрені оқуды жалғастырыңыз.',
        ],
    ];

    public function getRecommendations(string $userId, string $lang = 'ru'): array
    {
        $messages = self::MESSAGES[$lang] ?? self::MESSAGES['ru'];
        $stats = $this->statsRepo->getByUser($userId);
        $streak = $this->statsRepo->getStreak($userId);
        $recommendations = [];

        if (($streak['current_streak'] ?? 0) === 0) {
            $recommendations[] = [
                'type' => 'streak',
                'priority' => 'high',
                'message' => $messages['streak'],
            ];
        }

        $problemLetters = json_decode($stats['problem_letters'] ?? '{}', true) ?: [];
        if (!empty($problemLetters)) {
            arsort($problemLetters);
            $topLetter = array_key_first($problemLetters);
            $recommendations[] = [
                'type' => 'pronunciation',
                'priority' => 'medium',
                'message' => sprintf($messages['pronunciation'], $topLetter),
                'data' => ['letter' => $topLetter, 'count' => $problemLetters[$topLetter]],
            ];
        }

        if (($stats['avg_accuracy'] ?? 0) < 70) {
            $recommendations[] = [
                'type' => 'practice',
                'priority' => 'high',
                'message' => $messages['practice'],
                'data' => ['surah_number' => 1],
            ];
        }

        if (empty($recommendations)) {
            $recommendations[] = [
                'type' => 'continue',
                'priority' => 'low',
                'message' => $messages['continue'],
            ];
        }

        return $recommendations;
    }
}
