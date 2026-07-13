<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Helpers\Request;
use App\Helpers\Response;
use App\Services\RecitationService;
use App\Repositories\RecitationRepository;

class RecitationController
{
    public function store(Request $request): void
    {
        $ayahId = $request->input('ayah_id');
        $file = $request->file('audio');

        if (!$ayahId) {
            Response::error('ayah_id is required', 400);
        }
        if (!$file || $file['error'] !== UPLOAD_ERR_OK) {
            Response::error('Audio file is required', 400);
        }

        $config = require dirname(__DIR__, 2) . '/config/app.php';
        $maxSize = $config['max_audio_size_mb'] * 1024 * 1024;
        if ($file['size'] > $maxSize) {
            Response::error('Audio file too large', 400);
        }

        $audioDir = $config['storage_path'] . '/audio/' . date('Y/m');
        if (!is_dir($audioDir)) {
            mkdir($audioDir, 0755, true);
        }

        $ext = pathinfo($file['name'], PATHINFO_EXTENSION) ?: 'wav';
        $filename = uniqid('rec_') . '.' . $ext;
        $audioPath = $audioDir . '/' . $filename;

        if (!move_uploaded_file($file['tmp_name'], $audioPath)) {
            Response::error('Failed to save audio file', 500);
        }

        try {
            $service = new RecitationService();
            $duration = $request->input('duration');
            $result = $service->process(
                $request->userId(),
                $ayahId,
                $audioPath,
                $duration ? (float) $duration : null,
                $request->language()
            );
            Response::success($result, 'Recitation analyzed', 201);
        } catch (\Exception $e) {
            Response::error($e->getMessage(), 500);
        }
    }

    public function show(Request $request): void
    {
        $repo = new RecitationRepository();
        $recitation = $repo->findById($request->params['id']);
        if (!$recitation) {
            Response::error('Recitation not found', 404);
        }

        $result = $repo->getResult($recitation['id']);
        Response::success([
            'recitation' => $recitation,
            'result' => $result,
        ]);
    }

    public function errors(Request $request): void
    {
        $repo = new RecitationRepository();
        $errors = $repo->getErrorsByUser($request->userId());
        Response::success($errors);
    }
}
