<?php

declare(strict_types=1);

namespace SmartChildHub\Models;

/**
 * Sleep record model mapper. Matches Flutter SleepRecord.
 */
final class SleepRecordModel
{
    public static function fromRow(array $r): array
    {
        return [
            'id'             => $r['id'],
            'childId'        => $r['child_id'],
            'date'           => $r['date'],
            'bedtimeHour'    => (int) $r['bedtime_hour'],
            'bedtimeMinute'  => (int) $r['bedtime_minute'],
            'wakeHour'       => (int) $r['wake_hour'],
            'wakeMinute'     => (int) $r['wake_minute'],
            'hours'          => (float) $r['hours'],
            'quality'        => $r['quality'],
            'notes'          => (string) $r['notes'],
        ];
    }

    public static function toColumns(array $d, string $childId): array
    {
        return [
            'child_id'       => $childId,
            'date'           => (string) ($d['date'] ?? date('Y-m-d')),
            'bedtime_hour'   => (int) ($d['bedtimeHour'] ?? 0),
            'bedtime_minute' => (int) ($d['bedtimeMinute'] ?? 0),
            'wake_hour'      => (int) ($d['wakeHour'] ?? 0),
            'wake_minute'    => (int) ($d['wakeMinute'] ?? 0),
            'hours'          => (float) ($d['hours'] ?? 0),
            'quality'        => (string) ($d['quality'] ?? 'good'),
            'notes'          => (string) ($d['notes'] ?? ''),
        ];
    }
}
