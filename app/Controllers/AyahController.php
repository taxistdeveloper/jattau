<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Helpers\Request;
use App\Helpers\Response;
use App\Repositories\AyahRepository;

class AyahController
{
    public function bySurah(Request $request): void
    {
        $page = (int) ($request->input('page', 1));
        $perPage = (int) ($request->input('per_page', 50));

        $repo = new AyahRepository();
        $result = $repo->bySurah($request->params['surahId'], $page, $perPage);
        Response::paginated($result['items'], $result['total'], $page, $perPage);
    }

    public function show(Request $request): void
    {
        $repo = new AyahRepository();
        $ayah = $repo->findById($request->params['id']);
        if (!$ayah) {
            Response::error('Ayah not found', 404);
        }
        Response::success($ayah);
    }
}
