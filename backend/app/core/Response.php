<?php

declare(strict_types=1);

namespace SmartChildHub\Core;

use SmartChildHub\Config\Config;

/**
 * Standard JSON response helper.
 *
 * Every response uses the envelope:
 *   { "success": true|false, "data": ..., "message": ..., "errors": {...} }
 */
final class Response
{
    public static function send(int $status, array $payload): never
    {
        http_response_code($status);
        header('Content-Type: application/json; charset=utf-8');
        self::applyCors();
        echo json_encode($payload, Config::JSON_UNESCAPED);
        exit;
    }

    public static function success(mixed $data = null, int $status = 200, string $message = 'OK'): never
    {
        self::send($status, [
            'success' => true,
            'message' => $message,
            'data'    => $data,
        ]);
    }

    public static function created(mixed $data = null, string $message = 'Created'): never
    {
        self::success($data, 201, $message);
    }

    public static function noContent(string $message = 'Deleted'): never
    {
        http_response_code(204);
        self::applyCors();
        exit;
    }

    public static function error(string $message, int $status = 400, array $errors = []): never
    {
        self::send($status, [
            'success' => false,
            'message' => $message,
            'errors'  => (object) $errors,
            'data'    => null,
        ]);
    }

    private static function applyCors(): void
    {
        $origin = $_SERVER['HTTP_ORIGIN'] ?? '';

        // Configured list wins. Defaults to * for local development, which is
        // safe here because the API authenticates with a bearer token and never
        // sets Access-Control-Allow-Credentials (no cookies are used).
        $allowed = Config::$CORS_ALLOWED_ORIGINS;
        if (trim($allowed) === '*') {
            header('Access-Control-Allow-Origin: *');
        } else {
            $origins = array_filter(array_map('trim', explode(',', $allowed)));
            if ($origin !== '' && in_array($origin, $origins, true)) {
                header("Access-Control-Allow-Origin: $origin");
            }
            header('Vary: Origin');
        }

        header('Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS');
        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-CSRF-Token');
        header('Access-Control-Max-Age: 86400');
        header('X-Content-Type-Options: nosniff');
        header('X-Frame-Options: DENY');
        header('Referrer-Policy: no-referrer');
    }
}
