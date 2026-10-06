<?php

declare(strict_types=1);

namespace SmartChildHub\Models;

/**
 * Screen time model mapper. Matches Flutter ScreenTimeModel.
 */
final class ScreenTimeModel
{
    public static function fromRow(array $r): array
    {
        return [
            'id'             => $r['id'],
            'childId'        => $r['child_id'],
            'date'           => $r['date'],
            'allowedMinutes' => (int) $r['allowed_minutes'],
            'usedMinutes'    => (int) $r['used_minutes'],
            'category'       => $r['category'],
        ];
    }

    public static function toColumns(array $d, string $childId): array
    {
        return [
            'child_id'        => $childId,
            'date'            => (string) ($d['date'] ?? date('Y-m-d')),
            'allowed_minutes' => (int) ($d['allowedMinutes'] ?? 60),
            'used_minutes'    => (int) ($d['usedMinutes'] ?? 0),
            'category'        => trim((string) ($d['category'] ?? 'Total')),
        ];
    }
}
