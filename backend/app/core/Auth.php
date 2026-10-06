<?php

declare(strict_types=1);

namespace SmartChildHub\Core;

use PDO;
use SmartChildHub\Config\Config;

/**
 * Bearer-token authentication and authorization helpers.
 *
 * Raw tokens are returned to the client once; only SHA-256 hashes are stored,
 * so a database leak cannot be replayed as valid sessions.
 *
 * Sessions have a subject type: `parent` (a logged-in parent) or `child`
 * (a PIN-authenticated child session bound to one child). Parent-only
 * management endpoints always reject child tokens (403); child data endpoints
 * accept either the owning parent's token or the child's own token.
 */
final class Auth
{
    public static function issueToken(string $parentId, string $deviceName = 'mobile'): string
    {
        return self::issueSession($parentId, null, $deviceName);
    }

    /**
     * Issue a child-scoped session token bound to one child profile.
     */
    public static function issueChildToken(string $parentId, string $childId, string $deviceName = 'child-app'): string
    {
        return self::issueSession($parentId, $childId, $deviceName);
    }

    private static function issueSession(string $parentId, ?string $childId, string $deviceName): string
    {
        $raw = bin2hex(random_bytes(32));
        $hash = hash('sha256', $raw);

        $stmt = Database::pdo()->prepare(
            'INSERT INTO auth_tokens (id, parent_id, subject_type, child_id, token_hash, device_name, expires_at)
             VALUES (?, ?, ?, ?, ?, ?, ?)'
        );
        $stmt->execute([
            self::uuid(),
            $parentId,
            $childId === null ? 'parent' : 'child',
            $childId,
            $hash,
            $deviceName,
            (new \DateTimeImmutable("+ " . Config::TOKEN_TTL_HOURS . " hours"))->format('Y-m-d H:i:s'),
        ]);

        return $raw;
    }

    /**
     * Resolve any valid, non-expired, non-revoked session to a principal row.
     *
     * Returns the parent columns (via `p.*`) plus `subject_type`,
     * `subject_child_id`, `token_id` and `token_expires_at`. Returns null when
     * no bearer token is present or the token is invalid/expired.
     */
    public static function principal(Request $request): ?array
    {
        $raw = $request->bearerToken();
        if ($raw === null) {
            return null;
        }

        $stmt = Database::pdo()->prepare(
            'SELECT p.*, t.id AS token_id, t.subject_type,
                    t.child_id AS subject_child_id, t.expires_at AS token_expires_at
             FROM auth_tokens t
             INNER JOIN parents p ON p.id = t.parent_id
             WHERE t.token_hash = ? AND t.revoked = 0
             LIMIT 1'
        );
        $stmt->execute([hash('sha256', $raw)]);
        $row = $stmt->fetch();

        if ($row === false) {
            return null;
        }

        if (strtotime($row['token_expires_at']) < time()) {
            return null;
        }

        // Soft touch so session activity is trackable without hitting the DB often.
        Database::pdo()->prepare('UPDATE auth_tokens SET last_used_at = NOW() WHERE id = ?')
            ->execute([$row['token_id']]);

        return $row;
    }

    /**
     * Resolve the authenticated parent from the request, or throw.
     * Child tokens are explicitly rejected (403) on parent-only routes.
     */
    public static function parent(Request $request): array
    {
        $principal = self::requirePrincipal($request);

        if (($principal['subject_type'] ?? '') !== 'parent') {
            throw new AppException('Forbidden. This action requires parent authentication.', 403);
        }

        return $principal;
    }

    /**
     * Resolve a child-authenticated session from the request, or throw.
     *
     * Returns the child row (all children columns) plus `parent_id` of the
     * owning parent. Parent tokens are not accepted here.
     */
    public static function child(Request $request): array
    {
        $principal = self::requirePrincipal($request);

        if (($principal['subject_type'] ?? '') !== 'child' || empty($principal['subject_child_id'])) {
            throw new AppException('This action requires a child session.', 401);
        }

        $stmt = Database::pdo()->prepare('SELECT * FROM children WHERE id = ? LIMIT 1');
        $stmt->execute([$principal['subject_child_id']]);
        $child = $stmt->fetch();
        if ($child === false) {
            throw new AppException('Invalid or expired token.', 401);
        }

        return [
            'parent_id' => (string) $principal['id'],
            'child'     => $child,
        ];
    }

    /**
     * True when the request carries a child session token for the given child.
     */
    public static function isChildSession(Request $request, string $childId): bool
    {
        $principal = self::principal($request);
        return $principal !== null
            && ($principal['subject_type'] ?? '') === 'child'
            && ($principal['subject_child_id'] ?? '') === $childId;
    }

    private static function requirePrincipal(Request $request): array
    {
        $raw = $request->bearerToken();
        if ($raw === null) {
            throw new AppException('Authentication required. Provide a Bearer token.', 401);
        }

        $principal = self::principal($request);
        if ($principal === null) {
            throw new AppException('Invalid or expired token.', 401);
        }

        return $principal;
    }

    /**
     * Revoke the current session (logout).
     */
    public static function revoke(Request $request): void
    {
        $raw = $request->bearerToken();
        if ($raw === null) {
            return;
        }
        Database::pdo()->prepare(
            'UPDATE auth_tokens SET revoked = 1 WHERE token_hash = ?'
        )->execute([hash('sha256', $raw)]);
    }

    /**
     * Revoke every session for a parent (used after password changes).
     * Child tokens are stored under the owning parent id, so they are
     * invalidated too (the PIN session cannot outlive its family account).
     */
    public static function revokeAll(string $parentId): void
    {
        Database::pdo()->prepare('UPDATE auth_tokens SET revoked = 1 WHERE parent_id = ?')
            ->execute([$parentId]);
    }

    /**
     * RFC-4122 v4 UUID string used for every primary key.
     */
    public static function uuid(): string
    {
        $data = random_bytes(16);
        $data[6] = chr((ord($data[6]) & 0x0f) | 0x40);
        $data[8] = chr((ord($data[8]) & 0x3f) | 0x80);
        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
    }
}