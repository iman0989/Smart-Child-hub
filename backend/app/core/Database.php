<?php

declare(strict_types=1);

namespace SmartChildHub\Core;

use PDO;
use PDOException;
use SmartChildHub\Config\Config;

/**
 * Shared PDO connection (singleton).
 */
final class Database
{
    private static ?PDO $instance = null;

    public static function pdo(): PDO
    {
        if (self::$instance === null) {
            $dsn = sprintf(
                'mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4',
                Config::$DB_HOST,
                Config::$DB_PORT,
                Config::$DB_NAME
            );
            try {
                self::$instance = new PDO($dsn, Config::$DB_USER, Config::$DB_PASS, [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                    PDO::ATTR_STRINGIFY_FETCHES => false,
                ]);
            } catch (PDOException $e) {
                throw new AppException('Database connection failed.', 500, $e);
            }
        }
        return self::$instance;
    }
}
