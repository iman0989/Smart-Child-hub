<?php

declare(strict_types=1);

namespace SmartChildHub\Models;

/**
 * Mood record model mapper. Matches Flutter MoodRecord.
 */
final class MoodModel
{
    public static function fromRow(array $r): array
    {
        return [
            'id'      => $r['id'],
            'childId' => $r['child_id'],
            'date'    => $r['date'],
            'mood'    => $r['mood'],
            'note'    => (string) $r['note'],
        ];
    }

    public static function toColumns(array $d, string $childId): array
    {
        return [
            'child_id' => $childId,
            'date'     => (string) ($d['date'] ?? date('Y-m-d H:i:s')),
            'mood'     => (string) ($d['mood'] ?? 'happy'),
            'note'     => (string) ($d['note'] ?? ''),
        ];
    }
}
