<?php

declare(strict_types=1);

namespace SmartChildHub\Models;

/**
 * Homework model mapper. Matches Flutter HomeworkModel.
 */
final class HomeworkModel
{
    public static function fromRow(array $r): array
    {
        return [
            'id'       => $r['id'],
            'childId'  => $r['child_id'],
            'title'    => $r['title'],
            'subject'  => $r['subject'],
            'icon'     => $r['icon'],
            'dueDate'  => $r['due_date'],
            'status'   => $r['status'],
            'coins'    => (int) $r['coins'],
            'progress' => (float) $r['progress'],
        ];
    }

    public static function toColumns(array $d, string $childId): array
    {
        return [
            'child_id' => $childId,
            'title'    => trim((string) ($d['title'] ?? '')),
            'subject'  => trim((string) ($d['subject'] ?? '')),
            'icon'     => trim((string) ($d['icon'] ?? 'book')),
            'due_date' => (string) ($d['dueDate'] ?? date('Y-m-d')),
            'status'   => (string) ($d['status'] ?? 'pending'),
            'coins'    => (int) ($d['coins'] ?? 5),
            'progress' => (float) ($d['progress'] ?? 0),
        ];
    }
}
