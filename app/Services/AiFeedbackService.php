<?php

declare(strict_types=1);

namespace App\Services;

use App\Helpers\Logger;

class AiFeedbackService
{
    private array $config;
    private Logger $logger;

    public function __construct()
    {
        $this->config = require dirname(__DIR__, 2) . '/config/ai.php';
        $this->logger = new Logger();
    }

    public function generateErrorExplanation(array $error, string $language = 'ru'): string
    {
        if (empty($this->config['openai_api_key'])) {
            return $this->mockExplanation($error, $language);
        }

        $prompt = sprintf(
            "Ты — учитель Корана. Объясни ошибку чтения на %s языке кратко (2-3 предложения).\n" .
            "Тип ошибки: %s\nОжидалось: %s\nПрочитано: %s\nДай совет по исправлению.",
            $language,
            $error['error_type'] ?? 'mispronounced',
            $error['word_expected'] ?? '',
            $error['word_actual'] ?? ''
        );

        return $this->chat($prompt, $language);
    }

    public function generateRecitationFeedback(array $analysis, string $language = 'ru'): string
    {
        if (empty($this->config['openai_api_key'])) {
            return $this->mockRecitationFeedback($analysis, $language);
        }

        $errorsJson = json_encode($analysis, JSON_UNESCAPED_UNICODE);
        $prompt = sprintf(
            "Ты — наставник по чтению Корана. Пользователь прочитал аят с точностью %s%%. " .
            "Ошибки: %s. Дай мотивирующий отзыв и 2-3 конкретных совета на %s языке.",
            $analysis['accuracy_percent'] ?? 0,
            $errorsJson,
            $language
        );

        return $this->chat($prompt, $language);
    }

    private function chat(string $prompt, string $language = 'ru'): string
    {
        $payload = json_encode([
            'model' => $this->config['gpt_model'],
            'messages' => [
                ['role' => 'system', 'content' => 'Ты — опытный учитель Корана и таджвида. Отвечай кратко и по делу.'],
                ['role' => 'user', 'content' => $prompt],
            ],
            'max_tokens' => 300,
            'temperature' => 0.7,
        ]);

        $ch = curl_init($this->config['chat_url']);
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $payload,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'Authorization: Bearer ' . $this->config['openai_api_key'],
            ],
            CURLOPT_TIMEOUT => 30,
        ]);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode !== 200) {
            $this->logger->error('GPT API error', ['code' => $httpCode]);
            return self::STRINGS[$language]['api_error'] ?? self::STRINGS['ru']['api_error'];
        }

        $data = json_decode($response, true);
        return $data['choices'][0]['message']['content'] ?? '';
    }

    private const STRINGS = [
        'ru' => [
            'api_error' => 'Продолжайте практиковаться. Обратите внимание на выделенные ошибки.',
            'explanation' => 'Слово "%s" было прочитано неверно. Правильное произношение: "%s". Попробуйте прослушать эталонное аудио и повторите.',
            'feedback_good' => 'Отличная работа! Вы прочитали аят правильно. Продолжайте в том же духе.',
            'feedback_bad' => 'Есть ошибки в чтении. Обратите внимание на пропущенные и неверно произнесённые слова. Прослушайте эталон и повторите.',
        ],
        'kk' => [
            'api_error' => 'Жаттығуды жалғастырыңыз. Белгіленген қателерге назар аударыңыз.',
            'explanation' => '"%s" сөзі қате оқылды. Дұрыс айтылуы: "%s". Эталондық аудионы тыңдап, қайталап көріңіз.',
            'feedback_good' => 'Тамаша жұмыс! Аятты дұрыс оқыдыңыз. Осылай жалғастыра беріңіз.',
            'feedback_bad' => 'Оқуда қателер бар. Өткізіп алған және қате айтылған сөздерге назар аударыңыз. Эталонды тыңдап, қайталаңыз.',
        ],
    ];

    private function mockExplanation(array $error, string $language = 'ru'): string
    {
        $template = self::STRINGS[$language]['explanation'] ?? self::STRINGS['ru']['explanation'];
        return sprintf(
            $template,
            $error['word_actual'] ?? '',
            $error['word_expected'] ?? ''
        );
    }

    private function mockRecitationFeedback(array $analysis, string $language = 'ru'): string
    {
        $strings = self::STRINGS[$language] ?? self::STRINGS['ru'];
        $accuracy = $analysis['accuracy_percent'] ?? 0;
        return $accuracy >= 85 ? $strings['feedback_good'] : $strings['feedback_bad'];
    }
}
