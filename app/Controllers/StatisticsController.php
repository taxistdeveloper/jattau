<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Helpers\Request;
use App\Helpers\Response;
use App\Repositories\StatisticsRepository;
use App\Services\AiMentorService;

class StatisticsController
{
    public function index(Request $request): void
    {
        $repo = new StatisticsRepository();
        $stats = $repo->getByUser($request->userId());
        $streak = $repo->getStreak($request->userId());

        Response::success([
            'statistics' => $stats,
            'streak' => $streak,
        ]);
    }

    public function mentor(Request $request): void
    {
        $mentor = new AiMentorService();
        $recommendations = $mentor->getRecommendations($request->userId(), $request->language());
        Response::success($recommendations);
    }
}
