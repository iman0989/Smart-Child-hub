<?php

declare(strict_types=1);

/**
 * Application configuration.
 *
 * Single source of truth for the environment.
 *
 * Every deployment-specific value is read from the environment first and falls
 * back to the local XAMPP defaults below, so a fresh checkout keeps working on
 * localhost with zero configuration while a hosted deployment only needs
 * environment variables.
 *
 * Call {@see Config::load()} once at the start of every entry point (the front
 * controller, migrations, seeds and test harnesses) to apply the environment.
 *
 * Recognised environment variables:
 *   APP_ENV                 local | production
 *   APP_DEBUG               1/true/on | 0/false/off (defaults to on unless APP_ENV=production)
 *   BASE_URL                Public HTTPS URL of this API, e.g. https://api.example.com.
 *                           Leave empty to auto-detect (fine for localhost, not for hosting).
 *   DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASS
 *   CORS_ALLOWED_ORIGINS    Comma separated origins, or * for any.
 */

namespace SmartChildHub\Config;

final class Config
{
    public const APP_NAME = 'Smart Child Hub API';
    public const APP_VERSION = '1.0.0';

    /**
     * Base URL of the API. Empty means "auto-detect from the request", which is
     * what local development wants and what hosted deployments must override.
     */
    public static string $BASE_URL = '';

    /** 'local' or 'production'. */
    public static string $APP_ENV = 'local';

    /** Show real exception messages in the response body. Never enable in production. */
    public static bool $APP_DEBUG = true;

    // Database.
    public static string $DB_HOST = '127.0.0.1';
    public static int $DB_PORT = 3306;
    public static string $DB_NAME = 'smart_child_hub';
    public static string $DB_USER = 'root';
    public static string $DB_PASS = '';

    /** Comma separated allowed origins, or * for development. */
    public static string $CORS_ALLOWED_ORIGINS = '*';

    // Security.
    public const PASSWORD_MIN_LENGTH = 6;
    public const TOKEN_TTL_HOURS = 720;            // 30 days
    public const RESET_TOKEN_TTL_MINUTES = 60;
    public const RESET_TOKEN_CHARS = 32;
    public const CHILD_PIN_REGEX = '/^[0-9]{4}$/';

    // Child profile rules. The kids zone is built for primary school children.
    public const CHILD_AGE_MIN = 4;
    public const CHILD_AGE_MAX = 14;
    public const CHILD_GRADE_MIN = 1;
    public const CHILD_GRADE_MAX = 9;
    public const CHILD_ABOUT_MAX_LENGTH = 255;

    // Child PIN self-service recovery (security questions + one-time token).
    public const CHILD_RECOVERY_TOKEN_TTL_MINUTES = 15;
    public const CHILD_RECOVERY_TOKEN_CHARS = 32;
    public const CHILD_RECOVERY_MAX_ATTEMPTS = 5;
    public const CHILD_RECOVERY_LOCKOUT_MINUTES = 15;

    // JSON response flags.
    public const JSON_UNESCAPED = JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE;

    /**
     * Applies environment variables over the defaults. Idempotent and
     * order-independent: the declared defaults are restored first, so a second
     * call with a different environment cannot inherit stale values.
     */
    public static function load(): void
    {
        // Start from the documented local defaults on every call.
        self::$BASE_URL = '';
        self::$APP_ENV = 'local';
        self::$DB_HOST = '127.0.0.1';
        self::$DB_PORT = 3306;
        self::$DB_NAME = 'smart_child_hub';
        self::$DB_USER = 'root';
        self::$DB_PASS = '';
        self::$CORS_ALLOWED_ORIGINS = '*';

        self::$APP_ENV = self::str('APP_ENV', self::$APP_ENV);
        self::$BASE_URL = rtrim((string) self::str('BASE_URL', ''), '/');

        $debug = self::str('APP_DEBUG', null);
        if ($debug !== null) {
            self::$APP_DEBUG = self::toBool($debug);
        } else {
            // Debug output leaks stack traces and SQL, so it is opt-in only.
            self::$APP_DEBUG = self::isProduction() ? false : true;
        }

        self::$DB_HOST = (string) self::str('DB_HOST', self::$DB_HOST);
        self::$DB_PORT = self::toInt(self::str('DB_PORT', null), self::$DB_PORT);
        self::$DB_NAME = (string) self::str('DB_NAME', self::$DB_NAME);
        self::$DB_USER = (string) self::str('DB_USER', self::$DB_USER);
        self::$DB_PASS = (string) self::str('DB_PASS', '');

        self::$CORS_ALLOWED_ORIGINS = (string) self::str('CORS_ALLOWED_ORIGINS', self::$CORS_ALLOWED_ORIGINS);
    }

    public static function isProduction(): bool
    {
        return strtolower(trim(self::$APP_ENV)) === 'production';
    }

    /**
     * Public URL of this API without a trailing slash.
     *
     * Returns the configured BASE_URL when set. Otherwise auto-detects from the
     * current request, honouring the reverse-proxy headers used by HTTPS
     * terminating hosts (otherwise photos would be advertised over plain http
     * and the browser would block them as mixed content).
     */
    public static function publicBaseUrl(): string
    {
        if (self::$BASE_URL !== '') {
            return self::$BASE_URL;
        }

        return self::requestScheme() . '://' . self::requestHost() . self::scriptDirectory();
    }

    /** Public URL of the uploaded child photos directory. */
    public static function uploadsBaseUrl(): string
    {
        return self::publicBaseUrl() . '/uploads';
    }

    private static function requestScheme(): string
    {
        $https = $_SERVER['HTTPS'] ?? '';
        if ($https !== '' && strtolower((string) $https) !== 'off') {
            return 'https';
        }
        if (strtolower((string) ($_SERVER['REQUEST_SCHEME'] ?? '')) === 'https') {
            return 'https';
        }
        if (strtolower(self::firstHeaderValue($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? null)) === 'https') {
            return 'https';
        }
        if (strpos((string) ($_SERVER['HTTP_CF_VISITOR'] ?? ''), '"https"') !== false) {
            return 'https';
        }

        return 'http';
    }

    private static function requestHost(): string
    {
        $host = $_SERVER['HTTP_X_FORWARDED_HOST'] ?? $_SERVER['HTTP_HOST'] ?? $_SERVER['SERVER_NAME'] ?? '';
        $host = self::firstHeaderValue($host);
        if ($host === '') {
            return 'localhost';
        }

        // Only ever echo back a syntactically valid host[:port].
        if (!preg_match('/^[A-Za-z0-9.\-]+(:[0-9]{1,5})?$/', $host)) {
            return 'localhost';
        }

        return $host;
    }

    /**
     * Directory the front controller is served from, without a trailing slash.
     * Empty when the API is hosted at the domain root.
     */
    private static function scriptDirectory(): string
    {
        $script = (string) ($_SERVER['SCRIPT_NAME'] ?? '');
        // dirname() returns the platform separator, so on Windows a
        // forward-slashed "/index.php" yields a backslash. Normalise it, or the
        // URL would come out as "https://host\".
        $dir = str_replace('\\', '/', dirname(str_replace('\\', '/', $script)));

        return rtrim($dir, '/');
    }

    /**
     * Proxies may append a comma separated list; the first entry is the client.
     */
    private static function firstHeaderValue(mixed $value): string
    {
        if (!is_string($value)) {
            return '';
        }

        return trim(explode(',', $value)[0]);
    }

    /**
     * Reads a variable from the environment.
     *
     * $_SERVER is checked as well as $_ENV/getenv() because shared hosting has
     * no shell access: values are commonly injected with `SetEnv` in .htaccess
     * or through the control panel, which populates $_SERVER without touching
     * the process environment that getenv() reads.
     */
    private static function str(string $key, ?string $default): ?string
    {
        if (array_key_exists($key, $_SERVER)) {
            $value = $_SERVER[$key];
            if (is_string($value) && $value !== '') {
                return $value;
            }
        }
        if (array_key_exists($key, $_ENV)) {
            $value = $_ENV[$key];
            if (is_string($value) && $value !== '') {
                return $value;
            }
        }

        $value = getenv($key);
        if (is_string($value) && $value !== '') {
            return $value;
        }

        return $default;
    }

    private static function toBool(string $value): bool
    {
        $value = strtolower(trim($value));

        return in_array($value, ['1', 'true', 'yes', 'on'], true);
    }

    private static function toInt(?string $value, int $default): int
    {
        if ($value === null || !preg_match('/^[0-9]+$/', trim($value))) {
            return $default;
        }

        return (int) trim($value);
    }
}
