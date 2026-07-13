<?php

declare(strict_types=1);

namespace App\Services;

use App\Helpers\Logger;

class SpeechRecognitionService
{
    private array $config;
    private Logger $logger;

    public function __construct()
    {
        $this->config = require dirname(__DIR__, 2) . '/config/ai.php';
        $this->logger = new Logger();
    }

    public function transcribe(string $audioPath): string
    {
        if (!$this->isApiKeyConfigured()) {
            $this->logger->warning('OpenAI API key not set, using mock transcription');
            return $this->mockTranscribe($audioPath);
        }

        $ch = curl_init($this->config['whisper_url']);
        $postFields = [
            'file' => new \CURLFile($audioPath),
            'model' => $this->config['whisper_model'],
            'language' => 'ar',
            'response_format' => 'json',
        ];

        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => $postFields,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                'Authorization: Bearer ' . $this->config['openai_api_key'],
            ],
            CURLOPT_TIMEOUT => 120,
        ]);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode !== 200) {
            $this->logger->error('Whisper API error', ['code' => $httpCode, 'response' => $response]);
            throw new \RuntimeException('Speech recognition failed');
        }

        $data = json_decode($response, true);
        return $data['text'] ?? '';
    }

    private function isApiKeyConfigured(): bool
    {
        $key = trim($this->config['openai_api_key'] ?? '');
        if ($key === '') {
            return false;
        }

        $placeholders = ['sk-your-openai-key', 'your-openai-key', 'sk-...'];
        return !in_array($key, $placeholders, true) && !str_starts_with($key, 'sk-your-');
    }

    private function mockTranscribe(string $audioPath): string
    {
        return 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
    }
}
