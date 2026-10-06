<?php

declare(strict_types=1);

namespace SmartChildHub\Models;

/**
 * Parent (account) model mapper. DB rows <-> API JSON.
 */
final class ParentModel
{
    /**
     * Convert a parents row to the JSON shape the Flutter UserModel expects.
     */
    public static function fromRow(array $r): array
    {
        return [
            'id'             => $r['id'],
            'fullName'       => $r['full_name'],
            'email'          => $r['email'],
            'phone'          => $r['phone'],
            'avatarKey'      => $r['avatar_key'],
            'primaryAccount' => true,
        ];
    }

    /**
     * Whitelist of parent fields that are safe to expose.
     */
    public static function publicRow(array $r): array
    {
        return self::fromRow($r);
    }

    /**
     * Accepted profile update columns (DB => API field name).
     */
    public static function updatable(): array
    {
        return ['full_name' => 'fullName', 'phone' => 'phone', 'avatar_key' => 'avatarKey'];
    }
}
