<?php

declare(strict_types=1);

namespace App\Middleware;

use App\Helpers\JwtHelper;
use App\Helpers\Request;
use App\Helpers\Response;
use Firebase\JWT\ExpiredException;

class AuthMiddleware
{
    public function handle(Request $request): void
    {
        $token = $request->bearerToken();
        if (!$token) {
            Response::error('Unauthorized', 401);
        }

        try {
            $jwt = new JwtHelper();
            $decoded = $jwt->decode($token);

            if (($decoded->type ?? '') !== 'access') {
                Response::error('Invalid token type', 401);
            }

            $GLOBALS['auth_user_id'] = $decoded->sub;
            $GLOBALS['auth_user_role'] = $decoded->role ?? 'user';
        } catch (ExpiredException) {
            Response::error('Token expired', 401);
        } catch (\Exception) {
            Response::error('Invalid token', 401);
        }
    }
}
