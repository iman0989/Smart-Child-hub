<?php

declare(strict_types=1);

namespace SmartChildHub\Models;

use PDO;
use SmartChildHub\Config\Config;
use SmartChildHub\Core\Auth;

/**
 * One-time tokens that a child holds after answering their security questions.
 *
 * Only a SHA-256 hash of the token is stored, mirroring `password_resets`, and
 * every token is bound to a single child id so a reset can never touch another
 * profile.
 */
final class ChildPinRecoveryToken
{
    public static function issue(PDO $db, string $childId): string
    {
        // Only the newest unused token per child stays valid.
        $db->prepare('UPDATE child_pin_recovery_tokens SET used = 1 WHERE child_id = ? AND used = 0')
            ->execute([$childId]);

        $raw = bin2hex(random_bytes(Config::CHILD_RECOVERY_TOKEN_CHARS));
        $db->prepare(
            'INSERT INTO child_pin_recovery_tokens (id, child_id, token_hash, expires_at)
             VALUES (?, ?, ?, ?)'
        )->execute([
            Auth::uuid(),
            $childId,
            self::hash($raw),
            (new \DateTimeImmutable('+' . Config::CHILD_RECOVERY_TOKEN_TTL_MINUTES . ' minutes'))->format('Y-m-d H:i:s'),
        ]);

        return $raw;
    }

    /**
     * Resolve an unused, unexpired token to its child row.
     *
     * @return array{child_id: string, token_id: string}|null
     */
    public static function resolve(PDO $db, string $raw): ?array
    {
        $stmt = $db->prepare(
            'SELECT id AS token_id, child_id, expires_at
             FROM child_pin_recovery_tokens
             WHERE token_hash = ? AND used = 0
             ORDER BY created_at DESC LIMIT 1'
        );
        $stmt->execute([self::hash($raw)]);
        $row = $stmt->fetch();

        if ($row === false) {
            return null;
        }
        if (strtotime((string) $row['expires_at']) < time()) {
            return null;
        }

        return ['child_id' => (string) $row['child_id'], 'token_id' => (string) $row['token_id']];
    }

    public static function markUsed(PDO $db, string $tokenId): void
    {
        $db->prepare('UPDATE child_pin_recovery_tokens SET used = 1 WHERE id = ?')->execute([$tokenId]);
    }

    /**
     * Drop expired and spent tokens. Called opportunistically before issuing a
     * new one so the table cannot grow without bound.
     */
    public static function prune(PDO $db): void
    {
        $db->prepare('DELETE FROM child_pin_recovery_tokens WHERE used = 1 OR expires_at < NOW()')->execute();
    }

    private static function hash(string $raw): string
    {
        return hash('sha256', $raw);
    }
}