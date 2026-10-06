<?php

declare(strict_types=1);

namespace SmartChildHub\Models;

/**
 * Attendance record model mapper. Matches Flutter AttendanceRecord.
 */
final class AttendanceModel
{
    public static function fromRow(array $r): array
    {
        return [
            'id'        => $r['id'],
            'childId'   => $r['child_id'],
            'date'      => $r['date'],
            'status'    => $r['status'],
            'className' => $r['class_name'],
        ];
    }

    public static function toColumns(array $d, string $childId): array
    {
        return [
            'child_id'   => $childId,
            'date'       => (string) ($d['date'] ?? date('Y-m-d')),
            'status'     => (string) ($d['status'] ?? 'present'),
            'class_name' => trim((string) ($d['className'] ?? 'School')),
        ];
    }
}
