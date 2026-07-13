<?php

declare(strict_types=1);

namespace App\Controllers;

use App\Helpers\Request;
use App\Helpers\Response;
use App\Services\AuthService;
use App\Validators\Validator;

class AuthController
{
    public function register(Request $request): void
    {
        $data = $request->body();
        $validator = new Validator();

        if (!$validator->validate($data, [
            'email' => 'required|email',
            'password' => 'required|min:8|confirmed',
            'full_name' => 'required|min:2|max:255',
        ])) {
            Response::error('Validation failed', 422, $validator->errors());
        }

        try {
            $auth = new AuthService();
            $result = $auth->register($data['email'], $data['password'], $data['full_name']);
            Response::success($result, 'Registration successful', 201);
        } catch (\InvalidArgumentException $e) {
            Response::error($e->getMessage(), 400);
        }
    }

    public function login(Request $request): void
    {
        $data = $request->body();
        $validator = new Validator();

        if (!$validator->validate($data, [
            'email' => 'required|email',
            'password' => 'required',
        ])) {
            Response::error('Validation failed', 422, $validator->errors());
        }

        try {
            $auth = new AuthService();
            $result = $auth->login($data['email'], $data['password']);
            Response::success($result, 'Login successful');
        } catch (\InvalidArgumentException $e) {
            Response::error($e->getMessage(), 401);
        }
    }

    public function refresh(Request $request): void
    {
        $refreshToken = $request->input('refresh_token');
        if (!$refreshToken) {
            Response::error('Refresh token required', 400);
        }

        try {
            $auth = new AuthService();
            $result = $auth->refresh($refreshToken);
            Response::success($result, 'Token refreshed');
        } catch (\InvalidArgumentException $e) {
            Response::error($e->getMessage(), 401);
        }
    }
}
