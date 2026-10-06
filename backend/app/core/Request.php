<?php

declare(strict_types=1);

namespace SmartChildHub\Core;

use SmartChildHub\Config\Config;

/**
 * Wraps the incoming HTTP request (method, path, query, JSON body, headers).
 */
final class Request
{
    private array $query;
    private array $body;
    private array $headers;

    public function __construct()
    {
        $this->query = $_GET;
        $this->headers = getallheaders() ?: [];
        $this->body = $this->parseBody();
    }

    private function parseBody(): array
    {
        $raw = file_get_contents('php://input');
        if ($raw === false || trim($raw) === '') {
            return [];
        }

        $contentType = strtolower($_SERVER['CONTENT_TYPE'] ?? '');
        if (str_contains($contentType, 'application/json')) {
            $decoded = json_decode($raw, true);
            return is_array($decoded) ? $decoded : [];
        }

        parse_str($raw, $parsed);
        return is_array($parsed) ? $parsed : [];
    }

    public function method(): string
    {
        return strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');
    }

    public function path(): string
    {
        $uri = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
        // Strip the directory prefix when the project is nested under DocumentRoot
        // (e.g. /Smart-Child-Daily-Activity-Tracking-System/backend/public/api/health => api/health).
        $scriptDir = rtrim(dirname($_SERVER['SCRIPT_NAME'] ?? ''), '/\\');
        if ($scriptDir !== '' && str_starts_with($uri, $scriptDir)) {
            $uri = substr($uri, strlen($scriptDir));
        }
        return trim($uri, '/');
    }

    /**
     * Path parameter (segment) by position, e.g. /api/children/{id} => segment 2.
     */
    public function param(int $index): ?string
    {
        $segments = explode('/', $this->path());
        return $segments[$index] ?? null;
    }

    public function query(string $key, mixed $default = null): mixed
    {
        return $this->query[$key] ?? $default;
    }

    public function input(string $key, mixed $default = null): mixed
    {
        return $this->body[$key] ?? $default;
    }

    public function all(): array
    {
        return $this->body;
    }

    public function has(string $key): bool
    {
        return array_key_exists($key, $this->body);
    }

    public function header(string $name, string $default = ''): string
    {
        $normalized = strtolower($name);
        foreach ($this->headers as $key => $value) {
            if (strtolower($key) === $normalized) {
                return is_string($value) ? $value : (string) $value;
            }
        }
        return $default;
    }

    /**
     * Bearer token from the Authorization header, or null when absent.
     */
    public function bearerToken(): ?string
    {
        $auth = $this->header('Authorization');
        if (preg_match('/^Bearer\s+(.+)$/i', $auth, $m)) {
            return trim($m[1]);
        }
        return null;
    }

    public function wantsJson(): bool
    {
        $accept = strtolower($this->header('Accept'));
        return str_contains($accept, 'application/json') || str_contains($accept, '*/*');
    }

    public function isMethod(string $method): bool
    {
        return $this->method() === strtoupper($method);
    }

    /**
     * True when running under the built-in PHP dev server.
     */
    public static function isCliServer(): bool
    {
        return PHP_SAPI === 'cli-server';
    }

    /**
     * Public URL of this API, without a trailing slash.
     *
     * Uses the configured BASE_URL when set, otherwise auto-detects the current
     * request (including the reverse-proxy headers used by HTTPS terminating
     * hosts, so the result is never downgraded to http in production).
     */
    public static function baseUrl(): string
    {
        return Config::publicBaseUrl();
    }
}
