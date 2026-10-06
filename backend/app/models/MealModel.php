<?php

declare(strict_types=1);

namespace SmartChildHub\Models;

/**
 * Meal record model mapper. Matches Flutter MealModel.
 */
final class MealModel
{
    public static function fromRow(array $r): array
    {
        return [
            'id'       => $r['id'],
            'childId'  => $r['child_id'],
            'date'     => $r['date'],
            'type'     => $r['type'],
            'name'     => $r['name'],
            'icon'     => $r['icon'],
            'time'     => $r['time'],
            'calories' => (int) $r['calories'],
            'protein'  => (int) $r['protein'],
            'carbs'    => (int) $r['carbs'],
            'fat'      => (int) $r['fat'],
            'eaten'    => (bool) $r['eaten'],
        ];
    }

    public static function toColumns(array $d, string $childId): array
    {
        return [
            'child_id' => $childId,
            'date'     => (string) ($d['date'] ?? date('Y-m-d')),
            'type'     => (string) ($d['type'] ?? 'snack'),
            'name'     => trim((string) ($d['name'] ?? '')),
            'icon'     => trim((string) ($d['icon'] ?? '')),
            'time'     => trim((string) ($d['time'] ?? '')),
            'calories' => (int) ($d['calories'] ?? 0),
            'protein'  => (int) ($d['protein'] ?? 0),
            'carbs'    => (int) ($d['carbs'] ?? 0),
            'fat'      => (int) ($d['fat'] ?? 0),
            'eaten'    => isset($d['eaten']) ? (int) (bool) $d['eaten'] : 1,
        ];
    }
}
