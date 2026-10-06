<?php

declare(strict_types=1);

namespace SmartChildHub\Models;

/**
 * Daily activity (routine task) model mapper. Matches Flutter TaskModel.
 */
final class ActivityModel
{
    public static function fromRow(array $r): array
    {
        return [
            'id'     => $r['id'],
            'childId' => $r['child_id'],
            'title'  => $r['title'],
            'icon'   => $r['icon'],
            'category' => $r['category'],
            'time'   => $r['time'],
            'coins'  => (int) $r['coins'],
            'status' => $r['status'],
            'date'   => $r['activity_date'],
        ];
    }

    public static function toColumns(array $d): array
    {
        return [
            'title'         => trim((string) ($d['title'] ?? '')),
            'icon'          => trim((string) ($d['icon'] ?? 'sparkle')),
            'category'      => trim((string) ($d['category'] ?? 'Routine')),
            'time'          => trim((string) ($d['time'] ?? '')),
            'coins'         => (int) ($d['coins'] ?? 5),
            'status'        => (string) ($d['status'] ?? 'pending'),
            'activity_date' => (string) ($d['date'] ?? date('Y-m-d')),
        ];
    }
}
