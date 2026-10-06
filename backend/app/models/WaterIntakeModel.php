<?php

declare(strict_types=1);

namespace SmartChildHub\Models;

/**
 * Water intake model mapper. Matches Flutter WaterIntakeModel (incl. glass log).
 */
final class WaterIntakeModel
{
    /**
     * @param string[] $glassTimes ISO datetime strings
     */
    public static function fromRow(array $r, array $glassTimes = []): array
    {
        return [
            'id'            => $r['id'],
            'childId'       => $r['child_id'],
            'date'          => $r['date'],
            'glasses'       => (int) $r['glasses'],
            'targetGlasses' => (int) $r['target_glasses'],
            'glassTimes'    => $glassTimes,
        ];
    }

    public static function toColumns(array $d, string $childId): array
    {
        return [
            'child_id'       => $childId,
            'date'           => (string) ($d['date'] ?? date('Y-m-d')),
            'glasses'        => (int) ($d['glasses'] ?? 0),
            'target_glasses' => (int) ($d['targetGlasses'] ?? 8),
        ];
    }
}
