<?php

declare(strict_types=1);

namespace SmartChildHub\Models;

use PDO;

/**
 * Report aggregator. Produces the JSON shape the Flutter ReportStatsModel expects.
 */
final class ReportModel
{
    /**
     * @return array<string, mixed>
     */
    public static function aggregate(PDO $db, string $childId, string $type): array
    {
        [$start, $end] = self::periodRange($type);

        $child = $db->prepare('SELECT * FROM children WHERE id = ?');
        $child->execute([$childId]);
        $childRow = $child->fetch();

        // --- Activity / task completion -------------------------------------
        $stmt = $db->prepare(
            'SELECT
               SUM(CASE WHEN status = "completed" THEN 1 ELSE 0 END) AS done,
               COUNT(*) AS total,
               SUM(CASE WHEN status = "completed" THEN coins ELSE 0 END) AS coins
             FROM activities
             WHERE child_id = ? AND activity_date BETWEEN ? AND ?'
        );
        $stmt->execute([$childId, $start, $end]);
        $activityStats = $stmt->fetch() ?: [];

        $stmt = $db->prepare(
            'SELECT
               SUM(CASE WHEN status = "completed" THEN 1 ELSE 0 END) AS done,
               COUNT(*) AS total,
               SUM(CASE WHEN status = "completed" THEN coins ELSE 0 END) AS coins
             FROM homework
             WHERE child_id = ? AND due_date BETWEEN ? AND ?'
        );
        $stmt->execute([$childId, $start, $end]);
        $hwStats = $stmt->fetch() ?: [];

        $tasksDone = (int) ($activityStats['done'] ?? 0) + (int) ($hwStats['done'] ?? 0);
        $tasksTotal = (int) ($activityStats['total'] ?? 0) + (int) ($hwStats['total'] ?? 0);
        $completionRate = $tasksTotal > 0 ? round(($tasksDone / $tasksTotal) * 100, 1) : 0;
        $coinsEarned = (int) ($activityStats['coins'] ?? 0) + (int) ($hwStats['coins'] ?? 0);

        // --- Sleep average --------------------------------------------------
        $stmt = $db->prepare(
            'SELECT COALESCE(AVG(hours), 0) AS avg_hours FROM sleep_records
             WHERE child_id = ? AND date BETWEEN ? AND ?'
        );
        $stmt->execute([$childId, $start, $end]);
        $sleepHours = round((float) (($stmt->fetch()['avg_hours'] ?? 0)), 1);

        // --- Water ----------------------------------------------------------
        $stmt = $db->prepare(
            'SELECT COALESCE(AVG(glasses), 0) AS avg_glasses FROM water_intakes
             WHERE child_id = ? AND date BETWEEN ? AND ?'
        );
        $stmt->execute([$childId, $start, $end]);
        $waterGlasses = (int) round((float) (($stmt->fetch()['avg_glasses'] ?? 0)));

        // --- Charts ---------------------------------------------------------
        $taskChart = self::taskChart($db, $childId, $type, $start, $end);
        $trendChart = self::trendChart($db, $childId, $type, $start, $end);
        $categoryChart = self::categoryChart($db, $childId, $start, $end);
        $attendance = self::attendance($db, $childId, $start, $end);

        return [
            'tasksDone'       => $tasksDone,
            'completionRate'  => $completionRate,
            'coins'           => $coinsEarned,
            'dayStreak'       => (int) ($childRow['streak_days'] ?? 0),
            'sleepHours'      => $sleepHours,
            'waterGlasses'    => $waterGlasses,
            'taskChart'       => $taskChart,
            'trendChart'      => $trendChart,
            'categoryChart'   => $categoryChart,
            'attendance'      => $attendance,
        ];
    }

    /**
     * @return array{0:string, 1:string} [start, end] inclusive Y-m-d
     */
    private static function periodRange(string $type): array
    {
        $now = new \DateTimeImmutable();
        switch ($type) {
            case 'daily':
                $start = $now->format('Y-m-d');
                return [$start, $start];

            case 'weekly':
                $start = $now->modify('monday this week')->format('Y-m-d');
                $end = $now->modify('sunday this week')->format('Y-m-d');
                return [$start, $end];

            case 'monthly':
            default:
                $start = $now->format('Y-m-01');
                $end = $now->format('Y-m-t');
                return [$start, $end];
        }
    }

    private static function taskChart(PDO $db, string $childId, string $type, string $start, string $end): array
    {
        $stmt = $db->prepare(
            'SELECT activity_date AS day, COUNT(*) AS value
             FROM activities
             WHERE child_id = ? AND status = "completed" AND activity_date BETWEEN ? AND ?
             GROUP BY activity_date'
        );
        $stmt->execute([$childId, $start, $end]);
        $rows = $stmt->fetchAll();
        $map = [];
        foreach ($rows as $row) {
            $map[$row['day']] = (int) $row['value'];
        }

        $labels = $type === 'weekly'
            ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
            : range(1, (int) substr($end, -2));

        $points = [];
        if ($type === 'weekly') {
            $d = new \DateTimeImmutable($start);
            foreach ($labels as $label) {
                $key = $d->format('Y-m-d');
                $points[] = ['label' => $label, 'value' => $map[$key] ?? 0];
                $d = $d->modify('+1 day');
            }
        } else {
            $d = new \DateTimeImmutable($start);
            $month = $d->format('m');
            $year = $d->format('Y');
            foreach ($labels as $dayNum) {
                $key = sprintf('%s-%s-%02d', $year, $month, $dayNum);
                $points[] = ['label' => (string) $dayNum, 'value' => $map[$key] ?? 0];
            }
        }
        return $points;
    }

    private static function trendChart(PDO $db, string $childId, string $type, string $start, string $end): array
    {
        $stmt = $db->prepare(
            'SELECT date, hours FROM sleep_records
             WHERE child_id = ? AND date BETWEEN ? AND ? ORDER BY date'
        );
        $stmt->execute([$childId, $start, $end]);
        $rows = $stmt->fetchAll();
        $map = [];
        foreach ($rows as $row) {
            $map[$row['date']] = (float) $row['hours'];
        }

        if ($type === 'daily') {
            $start = (new \DateTimeImmutable($start))->modify('-6 days')->format('Y-m-d');
        }

        $points = [];
        $d = new \DateTimeImmutable($start);
        $guard = 0;
        while ($d->format('Y-m-d') <= $end && $guard < 62) {
            $label = $type === 'monthly' ? (int) $d->format('d') : $d->format('D');
            $points[] = ['label' => (string) $label, 'value' => $map[$d->format('Y-m-d')] ?? 0];
            $d = $d->modify('+1 day');
            $guard++;
        }
        return $points;
    }

    private static function categoryChart(PDO $db, string $childId, string $start, string $end): array
    {
        $stmt = $db->prepare(
            'SELECT category, COUNT(*) AS value
             FROM activities
             WHERE child_id = ? AND status = "completed" AND activity_date BETWEEN ? AND ?
             GROUP BY category ORDER BY value DESC'
        );
        $stmt->execute([$childId, $start, $end]);
        $rows = $stmt->fetchAll();
        $points = [];
        foreach ($rows as $row) {
            $points[] = ['label' => $row['category'], 'value' => (int) $row['value']];
        }
        return $points;
    }

    private static function attendance(PDO $db, string $childId, string $start, string $end): array
    {
        $stmt = $db->prepare(
            'SELECT status, COUNT(*) AS value
             FROM attendance
             WHERE child_id = ? AND date BETWEEN ? AND ?
             GROUP BY status'
        );
        $stmt->execute([$childId, $start, $end]);
        $rows = $stmt->fetchAll();
        $map = ['present' => 0, 'absent' => 0, 'late' => 0];
        foreach ($rows as $row) {
            $map[$row['status']] = (int) $row['value'];
        }
        return [
            ['label' => 'present', 'value' => $map['present']],
            ['label' => 'absent',  'value' => $map['absent']],
            ['label' => 'late',    'value' => $map['late']],
        ];
    }
}
