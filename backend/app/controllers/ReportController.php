<?php

declare(strict_types=1);

namespace SmartChildHub\Controllers;

use SmartChildHub\Core\AppException;
use SmartChildHub\Core\Auth;
use SmartChildHub\Core\Controller;
use SmartChildHub\Core\Request;
use SmartChildHub\Core\Response;
use SmartChildHub\Models\ReportModel;

/**
 * Reports: daily / weekly / monthly JSON statistics, persisted to the reports
 * table so history is queryable without recomputation.
 */
final class ReportController extends Controller
{
    private const TYPES = ['daily', 'weekly', 'monthly'];

    public function show(Request $request): never
    {
        $child = $this->childIdFromPath($request);
        $type = $request->param(4);

        if (!in_array($type, self::TYPES, true)) {
            throw new AppException('Report type must be one of: ' . implode(', ', self::TYPES) . '.', 422);
        }

        $stats = ReportModel::aggregate($this->db, (string) $child['id'], $type);

        $periodDate = $this->periodDate($type);
        $this->persist((string) $child['id'], $type, $periodDate, $stats);

        Response::success([
            'id'         => Auth::uuid(),
            'childId'    => $child['id'],
            'type'       => $type,
            'periodDate' => $periodDate,
            'generatedAt' => date('Y-m-d\TH:i:s'),
            'stats'      => $stats,
        ], 200, ucfirst($type) . ' report generated.');
    }

    public function history(Request $request): never
    {
        $child = $this->childIdFromPath($request);
        $type = $request->query('type');

        $sql = 'SELECT id, child_id, type, period_date, created_at, data
                FROM reports WHERE child_id = ?';
        $params = [(string) $child['id']];
        if (in_array($type, self::TYPES, true)) {
            $sql .= ' AND type = ?';
            $params[] = $type;
        }
        $sql .= ' ORDER BY period_date DESC, created_at DESC LIMIT 50';

        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);

        $items = [];
        foreach ($stmt->fetchAll() as $row) {
            $items[] = [
                'id'         => $row['id'],
                'childId'    => $row['child_id'],
                'type'       => $row['type'],
                'periodDate' => $row['period_date'],
                'generatedAt' => $row['created_at'],
                'stats'      => json_decode($row['data'], true) ?: [],
            ];
        }

        Response::success(['items' => $items, 'count' => count($items)], 200, 'Report history retrieved.');
    }

    private function periodDate(string $type): string
    {
        $now = new \DateTimeImmutable();
        return match ($type) {
            'weekly' => $now->modify('monday this week')->format('Y-m-d'),
            'monthly' => $now->format('Y-m-01'),
            default => $now->format('Y-m-d'),
        };
    }

    private function persist(string $childId, string $type, string $periodDate, array $stats): void
    {
        $json = json_encode($stats, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
        $this->db->prepare(
            'INSERT INTO reports (id, child_id, type, period_date, data)
             VALUES (?, ?, ?, ?, ?)
             ON DUPLICATE KEY UPDATE data = VALUES(data), created_at = CURRENT_TIMESTAMP'
        )->execute([Auth::uuid(), $childId, $type, $periodDate, $json]);
    }
}
