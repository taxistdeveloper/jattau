<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Helpers\Request;
use App\Helpers\Response;
use App\Services\SpacedRepetitionService;

class MemorizationController
{
    public function dueCards(Request $request): void
    {
        $service = new SpacedRepetitionService();
        $cards = $service->getDueCards($request->userId());
        Response::success($cards);
    }

    public function review(Request $request): void
    {
        $ayahId = $request->input('ayah_id');
        $quality = (int) $request->input('quality', 3);

        if (!$ayahId) {
            Response::error('ayah_id is required', 400);
        }

        $service = new SpacedRepetitionService();
        $card = $service->reviewCard($request->userId(), $ayahId, $quality);
        Response::success($card);
    }
}
