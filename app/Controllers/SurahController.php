<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Helpers\Request;
use App\Helpers\Response;
use App\Repositories\SurahRepository;

class SurahController
{
    public function index(Request $request): void
    {
        $page = (int) ($request->input('page', 1));
        $perPage = (int) ($request->input('per_page', 114));

        $repo = new SurahRepository();
        $result = $repo->all($page, $perPage);
        Response::paginated($result['items'], $result['total'], $page, $perPage);
    }

    public function show(Request $request): void
    {
        $repo = new SurahRepository();
        $surah = $repo->findById($request->params['id']);
        if (!$surah) {
            Response::error('Surah not found', 404);
        }
        Response::success($surah);
    }
}
