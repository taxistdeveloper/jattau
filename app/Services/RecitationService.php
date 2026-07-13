<?php

declare(strict_types=1);

namespace App\Services;

use App\Repositories\RecitationRepository;
use App\Repositories\AyahRepository;
use App\Repositories\StatisticsRepository;
use App\Helpers\Logger;

class RecitationService
{
    public function __construct(
        private RecitationRepository $recitationRepo = new RecitationRepository(),
        private AyahRepository $ayahRepo = new AyahRepository(),
        private StatisticsRepository $statsRepo = new StatisticsRepository(),
        private SpeechRecognitionService $stt = new SpeechRecognitionService(),
        private PronunciationAnalysisService $analysis = new PronunciationAnalysisService(),
        private TajweedRulesEngine $tajweed = new TajweedRulesEngine(),
        private AiFeedbackService $aiFeedback = new AiFeedbackService(),
        private Logger $logger = new Logger(),
    ) {}

    public function process(string $userId, string $ayahId, string $audioPath, ?float $duration = null, string $lang = 'ru'): array
    {
        $startTime = microtime(true);
        $ayah = $this->ayahRepo->findById($ayahId);
        if (!$ayah) {
            throw new \InvalidArgumentException('Ayah not found');
        }

        $attemptNumber = $this->recitationRepo->countAttempts($userId, $ayahId) + 1;

        $recitation = $this->recitationRepo->create([
            'user_id' => $userId,
            'ayah_id' => $ayahId,
            'audio_path' => $audioPath,
            'audio_duration_seconds' => $duration,
            'status' => 'processing',
            'attempt_number' => $attemptNumber,
        ]);

        try {
            $transcribed = $this->stt->transcribe($audioPath);
            $expected = $ayah['text_uthmani'] ?? $ayah['text_simple'] ?? '';

            $analysisResult = $this->analysis->analyze($expected, $transcribed);
            $tajweedErrors = $this->tajweed->analyze($expected, $transcribed, $lang);

            $processingTime = (int) ((microtime(true) - $startTime) * 1000);

            $result = $this->recitationRepo->saveResult([
                'recitation_id' => $recitation['id'],
                'accuracy_percent' => $analysisResult['accuracy_percent'],
                'is_passed' => $analysisResult['is_passed'],
                'transcribed_text' => $transcribed,
                'expected_text' => $expected,
                'words_correct' => $analysisResult['words_correct'],
                'words_total' => $analysisResult['words_total'],
                'words_skipped' => json_encode($analysisResult['words_skipped'], JSON_UNESCAPED_UNICODE),
                'words_extra' => json_encode($analysisResult['words_extra'], JSON_UNESCAPED_UNICODE),
                'words_mispronounced' => json_encode($analysisResult['words_mispronounced'], JSON_UNESCAPED_UNICODE),
                'words_reordered' => json_encode($analysisResult['words_reordered'], JSON_UNESCAPED_UNICODE),
                'tajweed_errors' => json_encode($tajweedErrors, JSON_UNESCAPED_UNICODE),
                'processing_time_ms' => $processingTime,
            ]);

            $this->saveErrors($result['id'], $userId, $ayahId, $analysisResult);
            $problemLetters = $this->analysis->extractProblemLetters($analysisResult['words_mispronounced']);
            $this->statsRepo->updateAfterRecitation($userId, $analysisResult['accuracy_percent'], $analysisResult['error_count'], $problemLetters);
            $this->statsRepo->recalcProgress($userId);
            $this->statsRepo->updateStreak($userId);

            $this->recitationRepo->updateStatus($recitation['id'], 'completed');

            $feedback = $this->aiFeedback->generateRecitationFeedback($analysisResult, $lang);

            return [
                'recitation' => $recitation,
                'result' => $result,
                'feedback' => $feedback,
                'can_proceed' => $analysisResult['is_passed'],
            ];
        } catch (\Exception $e) {
            $this->recitationRepo->updateStatus($recitation['id'], 'failed');
            $this->logger->error('Recitation processing failed', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    private function saveErrors(string $resultId, string $userId, string $ayahId, array $analysis): void
    {
        foreach ($analysis['words_skipped'] as $item) {
            $this->recitationRepo->savePronunciationError([
                'recitation_result_id' => $resultId,
                'user_id' => $userId,
                'ayah_id' => $ayahId,
                'error_type' => 'skipped',
                'word_expected' => $item['word'],
                'word_actual' => null,
                'word_position' => $item['position'],
                'letter_problem' => null,
                'severity' => 'high',
            ]);
        }

        foreach ($analysis['words_mispronounced'] as $item) {
            $this->recitationRepo->savePronunciationError([
                'recitation_result_id' => $resultId,
                'user_id' => $userId,
                'ayah_id' => $ayahId,
                'error_type' => 'mispronounced',
                'word_expected' => $item['expected'],
                'word_actual' => $item['actual'],
                'word_position' => $item['position'],
                'letter_problem' => mb_substr($item['expected'], 0, 1),
                'severity' => ($item['similarity'] ?? 0) < 0.7 ? 'high' : 'medium',
            ]);
        }
    }
}
