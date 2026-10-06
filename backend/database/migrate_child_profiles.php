<?php

declare(strict_types=1);

/**
 * Smart Child Hub – child profile migration.
 *
 * Adds the child profile rules (age 4-14, Grade 1-9), the optional
 * "About child" field that replaces "School", hashed child PINs, the
 * child-specific PIN recovery tables, and the persistent child photo column.
 *
 * Run from CLI (idempotent, safe to run more than once):
 *   php database/migrate_child_profiles.php
 *
 * Existing rows are preserved: `school` is renamed rather than dropped, and
 * profiles created before hashed PINs existed keep their plain `pin` value,
 * which the API still accepts as a read-only fallback until the PIN is next
 * changed.
 */

require __DIR__ . '/../app/config/config.php';

use SmartChildHub\Config\Config;

Config::load();

$db = new PDO(
    'mysql:host=' . Config::$DB_HOST . ';dbname=' . Config::$DB_NAME . ';charset=utf8mb4',
    Config::$DB_USER,
    Config::$DB_PASS,
    [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]
);

/** True when the given column exists on the given table. */
function hasColumn(PDO $db, string $table, string $column): bool
{
    $stmt = $db->prepare(
        'SELECT COUNT(*) AS count FROM information_schema.COLUMNS
         WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?'
    );
    $stmt->execute([$table, $column]);

    return (int) ($stmt->fetch()['count'] ?? 0) > 0;
}

/** True when the given table exists. */
function hasTable(PDO $db, string $table): bool
{
    $stmt = $db->prepare(
        'SELECT COUNT(*) AS count FROM information_schema.TABLES
         WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ?'
    );
    $stmt->execute([$table]);

    return (int) ($stmt->fetch()['count'] ?? 0) > 0;
}

$steps = 0;

function run(string $label, callable $fn): void
{
    global $steps;
    if ($fn()) {
        $steps++;
        echo "  [applied] $label\n";
    } else {
        echo "  [skipped] $label\n";
    }
}

echo "Smart Child Hub - child profile migration\n";

run('rename children.school -> children.about_child', static function () use ($db): bool {
    if (hasColumn($db, 'children', 'about_child') || !hasColumn($db, 'children', 'school')) {
        return false;
    }
    $db->exec(
        'ALTER TABLE children
         CHANGE COLUMN school about_child VARCHAR(' . Config::CHILD_ABOUT_MAX_LENGTH . ") NOT NULL DEFAULT ''"
    );
    return true;
});

run('children.photo_url (persistent child profile photo)', static function () use ($db): bool {
    if (hasColumn($db, 'children', 'photo_url')) {
        return false;
    }
    $db->exec("ALTER TABLE children ADD COLUMN photo_url VARCHAR(255) NOT NULL DEFAULT '' AFTER avatar_key");
    // Defensive: never leave a NULL behind, the API treats '' as "no photo".
    $db->exec("UPDATE children SET photo_url = '' WHERE photo_url IS NULL");
    return true;
});

run('children.pin_hash (hashed PINs, legacy pin stays readable)', static function () use ($db): bool {
    if (hasColumn($db, 'children', 'pin_hash')) {
        return false;
    }
    $db->exec('ALTER TABLE children ADD COLUMN pin_hash VARCHAR(255) NULL AFTER pin');
    return true;
});

run('children.recovery_failed_attempts', static function () use ($db): bool {
    if (hasColumn($db, 'children', 'recovery_failed_attempts')) {
        return false;
    }
    $db->exec('ALTER TABLE children ADD COLUMN recovery_failed_attempts TINYINT UNSIGNED NOT NULL DEFAULT 0');
    return true;
});

run('children.recovery_locked_until', static function () use ($db): bool {
    if (hasColumn($db, 'children', 'recovery_locked_until')) {
        return false;
    }
    $db->exec('ALTER TABLE children ADD COLUMN recovery_locked_until DATETIME NULL AFTER recovery_failed_attempts');
    return true;
});

run('table child_security_questions', static function () use ($db): bool {
    if (hasTable($db, 'child_security_questions')) {
        return false;
    }
    $db->exec(
        'CREATE TABLE child_security_questions (
            id CHAR(36) NOT NULL,
            child_id CHAR(36) NOT NULL,
            question_key VARCHAR(64) NOT NULL,
            answer_hash VARCHAR(255) NOT NULL,
            sort_order TINYINT UNSIGNED NOT NULL DEFAULT 0,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            KEY idx_csq_child (child_id),
            CONSTRAINT fk_csq_child FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci'
    );
    return true;
});

run('table child_pin_recovery_tokens', static function () use ($db): bool {
    if (hasTable($db, 'child_pin_recovery_tokens')) {
        return false;
    }
    $db->exec(
        'CREATE TABLE child_pin_recovery_tokens (
            id CHAR(36) NOT NULL,
            child_id CHAR(36) NOT NULL,
            token_hash CHAR(64) NOT NULL,
            used TINYINT(1) NOT NULL DEFAULT 0,
            expires_at DATETIME NOT NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (id),
            UNIQUE KEY idx_cprt_token (token_hash),
            KEY idx_cprt_child (child_id),
            CONSTRAINT fk_cprt_child FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci'
    );
    return true;
});

echo $steps === 0 ? "Nothing to do - schema is already up to date.\n" : "Done ($steps change(s) applied).\n";