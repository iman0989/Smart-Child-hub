<?php

declare(strict_types=1);

namespace SmartChildHub\Models;

/**
 * Notification model mapper. Matches Flutter AppNotificationModel.
 */
final class NotificationModel
{
    public static function fromRow(array $r): array
    {
        return [
            'id'        => $r['id'],
            'type'      => $r['type'],
            'title'     => $r['title'],
            'message'   => $r['message'],
            'timestamp' => $r['created_at'],
            'read'      => (bool) $r['is_read'],
            'icon'      => $r['icon'],
        ];
    }

    public static function toColumns(array $d, string $parentId): array
    {
        return [
            'parent_id' => $parentId,
            'child_id'  => isset($d['childId']) && $d['childId'] !== '' ? $d['childId'] : null,
            'type'      => (string) ($d['type'] ?? 'activity'),
            'title'     => trim((string) ($d['title'] ?? '')),
            'message'   => trim((string) ($d['message'] ?? '')),
            'icon'      => trim((string) ($d['icon'] ?? 'bell')),
            'is_read'   => isset($d['read']) ? (int) (bool) $d['read'] : 0,
        ];
    }
}
