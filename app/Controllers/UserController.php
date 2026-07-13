<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Helpers\Request;
use App\Helpers\Response;
use App\Repositories\StatisticsRepository;
use App\Repositories\UserRepository;

class UserController
{
    public function profile(Request $request): void
    {
        $repo = new UserRepository();
        $statsRepo = new StatisticsRepository();
        $statsRepo->syncLevelFromStats($request->userId());

        $user = $repo->findById($request->userId());
        if (!$user) {
            Response::error('User not found', 404);
        }
        Response::success($user);
    }
}
