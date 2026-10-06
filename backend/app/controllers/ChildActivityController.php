<?php

declare(strict_types=1);

namespace SmartChildHub\Controllers;

use SmartChildHub\Core\AppException;
use SmartChildHub\Core\Auth;
use SmartChildHub\Core\Controller;
use SmartChildHub\Core\Request;
use SmartChildHub\Core\Response;
use SmartChildHub\Core\Validator;
use SmartChildHub\Models\ActivityModel;
use SmartChildHub\Models\AttendanceModel;
use SmartChildHub\Models\HomeworkModel;
use SmartChildHub\Models\MealModel;
use SmartChildHub\Models\MoodModel;
use SmartChildHub\Models\ScreenTimeModel;
use SmartChildHub\Models\SleepRecordModel;
use SmartChildHub\Models\WaterIntakeModel;

/**
 * Full CRUD for every per-child tracking domain:
 * activities, sleep, meals, water, moods, homework, attendance, screen time.
 */
final class ChildActivityController extends Controller
{
    // -------------------------------------------------------------------------
    // Activities (daily routine tasks)
    // -------------------------------------------------------------------------

    public function activities(Request $request): never
    {
        $child = $this->childIdFromPath($request);
        $childId = (string) $child['id'];
        $date = $request->query('date');

        $sql = 'SELECT * FROM activities WHERE child_id = ?';
        $params = [$childId];
        if ($date) {
            $sql .= ' AND activity_date = ?';
            $params[] = $date;
        }
        $sql .= ' ORDER BY activity_date DESC, created_at ASC';

        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        Response::success(array_map([ActivityModel::class, 'fromRow'], $stmt->fetchAll()), 200, 'Activities retrieved.');
    }

    public function storeActivity(Request $request): never
    {
        $child = $this->childIdFromPath($request);
        $childId = (string) $child['id'];
        $data = $request->all();

        (new Validator($data))
            ->has('title')->string('title', 1, 160)
            ->string('icon', 0, 40)
            ->string('category', 0, 80)
            ->string('time', 0, 16)
            ->int('coins', 0, 999)
            ->in('status', ['pending', 'completed', 'inProgress', 'locked'])
            ->date('date', 'Y-m-d')
            ->validate();

        $cols = ActivityModel::toColumns($data);
        $cols['id'] = Auth::uuid();
        $cols['child_id'] = $childId;

        $this->db->prepare(
            'INSERT INTO activities (id, child_id, title, icon, category, time, coins, status, activity_date)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'
        )->execute([
            $cols['id'], $cols['child_id'], $cols['title'], $cols['icon'], $cols['category'],
            $cols['time'], $cols['coins'], $cols['status'], $cols['activity_date'],
        ]);

        if ($cols['status'] === 'completed') {
            $this->awardCoins($childId, $cols['coins']);
        }

        Response::created(ActivityModel::fromRow($this->fetchRow('activities', $cols['id'])), 'Activity created.');
    }

    public function showActivity(Request $request): never
    {
        $row = $this->fetchOwnedRecord($request, 'activities', 'activity', 4);
        Response::success(ActivityModel::fromRow($row), 200, 'Activity retrieved.');
    }

    public function updateActivity(Request $request): never
    {
        $row = $this->fetchOwnedRecord($request, 'activities', 'activity', 4);
        $data = $request->all();

        $v = new Validator($data);
        if (isset($data['title'])) $v->string('title', 1, 160);
        if (isset($data['icon'])) $v->string('icon', 0, 40);
        if (isset($data['category'])) $v->string('category', 0, 80);
        if (isset($data['time'])) $v->string('time', 0, 16);
        if (isset($data['coins'])) $v->int('coins', 0, 999);
        if (isset($data['status'])) $v->in('status', ['pending', 'completed', 'inProgress', 'locked']);
        if (isset($data['date'])) $v->date('date', 'Y-m-d');
        $v->validate();

        $merged = $row;
        foreach (['title', 'icon', 'category', 'time', 'coins', 'status'] as $field) {
            if (array_key_exists($field, $data)) {
                $merged[$field] = $data[$field];
            }
        }
        if (isset($data['date'])) {
            $merged['activity_date'] = $data['date'];
        }

        $this->db->prepare(
            'UPDATE activities SET title = ?, icon = ?, category = ?, time = ?, coins = ?, status = ?, activity_date = ?
             WHERE id = ?'
        )->execute([
            $merged['title'], $merged['icon'], $merged['category'], $merged['time'],
            (int) $merged['coins'], $merged['status'], $merged['activity_date'], $row['id'],
        ]);

        $newlyCompleted = $row['status'] !== 'completed' && $merged['status'] === 'completed';
        if ($newlyCompleted) {
            $this->awardCoins($row['child_id'], (int) $merged['coins']);
        }

        Response::success(ActivityModel::fromRow($this->fetchRow('activities', $row['id'])), 200, 'Activity updated.');
    }

    public function destroyActivity(Request $request): never
    {
        $row = $this->fetchOwnedRecord($request, 'activities', 'activity', 4);
        $this->db->prepare('DELETE FROM activities WHERE id = ?')->execute([$row['id']]);
        Response::noContent('Activity deleted.');
    }

    // -------------------------------------------------------------------------
    // Sleep tracking
    // -------------------------------------------------------------------------

    public function sleep(Request $request): never
    {
        $this->listSimple($request, 'sleep_records', 'date', [SleepRecordModel::class, 'fromRow'], 'sleep records');
    }

    public function storeSleep(Request $request): never
    {
        $this->storeSimple(
            $request,
            'sleep_records',
            [SleepRecordModel::class, 'toColumns'],
            [SleepRecordModel::class, 'fromRow'],
            function (Validator $v, array $data) {
                $v->date('date', 'Y-m-d')
                  ->int('bedtimeHour', 0, 23)->int('bedtimeMinute', 0, 59)
                  ->int('wakeHour', 0, 23)->int('wakeMinute', 0, 59)
                  ->number('hours', 0, 24)
                  ->in('quality', ['restful', 'good', 'fair', 'poor'])
                  ->string('notes', 0, 1000);
            },
            'sleep record',
            'child_id,date'
        );
    }

    public function showSleep(Request $request): never
    {
        $this->showSimple($request, 'sleep_records', [SleepRecordModel::class, 'fromRow'], 'sleep record');
    }

    public function updateSleep(Request $request): never
    {
        $this->updateSimple(
            $request,
            'sleep_records',
            [SleepRecordModel::class, 'toColumns'],
            [SleepRecordModel::class, 'fromRow'],
            function (Validator $v, array $data) {
                $v->date('date', 'Y-m-d')
                  ->int('bedtimeHour', 0, 23)->int('bedtimeMinute', 0, 59)
                  ->int('wakeHour', 0, 23)->int('wakeMinute', 0, 59)
                  ->number('hours', 0, 24)
                  ->in('quality', ['restful', 'good', 'fair', 'poor'])
                  ->string('notes', 0, 1000);
            },
            'sleep record'
        );
    }

    public function destroySleep(Request $request): never
    {
        $this->deleteRecord($request, 'sleep_records', 'sleep record');
    }

    // -------------------------------------------------------------------------
    // Meal tracking
    // -------------------------------------------------------------------------

    public function meals(Request $request): never
    {
        $this->listSimple($request, 'meals', 'date', [MealModel::class, 'fromRow'], 'meals');
    }

    public function storeMeal(Request $request): never
    {
        $this->storeSimple(
            $request,
            'meals',
            [MealModel::class, 'toColumns'],
            [MealModel::class, 'fromRow'],
            function (Validator $v, array $data) {
                $v->date('date', 'Y-m-d')
                  ->in('type', ['breakfast', 'lunch', 'dinner', 'snack'])
                  ->has('name')->string('name', 1, 160)
                  ->string('icon', 0, 40)
                  ->string('time', 0, 16)
                  ->int('calories', 0, 3000)->int('protein', 0, 500)
                  ->int('carbs', 0, 1000)->int('fat', 0, 500)
                  ->bool('eaten');
            },
            'meal',
            null
        );
    }

    public function showMeal(Request $request): never
    {
        $this->showSimple($request, 'meals', [MealModel::class, 'fromRow'], 'meal');
    }

    public function updateMeal(Request $request): never
    {
        $this->updateSimple(
            $request,
            'meals',
            [MealModel::class, 'toColumns'],
            [MealModel::class, 'fromRow'],
            function (Validator $v, array $data) {
                $v->date('date', 'Y-m-d')
                  ->in('type', ['breakfast', 'lunch', 'dinner', 'snack'])
                  ->string('name', 1, 160)
                  ->string('icon', 0, 40)
                  ->string('time', 0, 16)
                  ->int('calories', 0, 3000)->int('protein', 0, 500)
                  ->int('carbs', 0, 1000)->int('fat', 0, 500)
                  ->bool('eaten');
            },
            'meal'
        );
    }

    public function destroyMeal(Request $request): never
    {
        $this->deleteRecord($request, 'meals', 'meal');
    }

    // -------------------------------------------------------------------------
    // Water intake
    // -------------------------------------------------------------------------

    public function water(Request $request): never
    {
        $child = $this->childIdFromPath($request);
        $childId = (string) $child['id'];
        $date = $request->query('date');

        $sql = 'SELECT * FROM water_intakes WHERE child_id = ?';
        $params = [$childId];
        if ($date) {
            $sql .= ' AND date = ?';
            $params[] = $date;
        }
        $sql .= ' ORDER BY date DESC';

        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        $rows = $stmt->fetchAll();

        $result = [];
        foreach ($rows as $row) {
            $result[] = WaterIntakeModel::fromRow($row, $this->glassTimes((string) $row['id']));
        }
        Response::success($result, 200, 'Water intake retrieved.');
    }

    public function storeWater(Request $request): never
    {
        $child = $this->childIdFromPath($request);
        $childId = (string) $child['id'];
        $data = $request->all();

        (new Validator($data))
            ->date('date', 'Y-m-d')
            ->int('glasses', 0, 50)
            ->int('targetGlasses', 1, 50)
            ->validate();

        $cols = WaterIntakeModel::toColumns($data, $childId);

        $existing = $this->findByChildDate('water_intakes', $childId, $cols['date']);
        if ($existing !== false) {
            $this->db->prepare('UPDATE water_intakes SET glasses = ?, target_glasses = ? WHERE id = ?')
                ->execute([$cols['glasses'], $cols['target_glasses'], $existing['id']]);
            $this->syncGlassTimes($existing['id'], $data['glassTimes'] ?? []);
            $id = $existing['id'];
            $status = 200;
        } else {
            $id = Auth::uuid();
            $this->db->prepare(
                'INSERT INTO water_intakes (id, child_id, date, glasses, target_glasses) VALUES (?, ?, ?, ?, ?)'
            )->execute([$id, $childId, $cols['date'], $cols['glasses'], $cols['target_glasses']]);
            $this->syncGlassTimes($id, $data['glassTimes'] ?? []);
            $status = 201;
        }

        $row = $this->fetchRow('water_intakes', $id);
        Response::success(WaterIntakeModel::fromRow($row, $this->glassTimes($id)), $status, 'Water intake saved.');
    }

    public function showWater(Request $request): never
    {
        $row = $this->fetchOwnedRecord($request, 'water_intakes', 'water intake');
        Response::success(WaterIntakeModel::fromRow($row, $this->glassTimes((string) $row['id'])), 200, 'Water intake retrieved.');
    }

    public function updateWater(Request $request): never
    {
        $row = $this->fetchOwnedRecord($request, 'water_intakes', 'water intake');
        $data = $request->all();

        (new Validator($data))
            ->date('date', 'Y-m-d')
            ->int('glasses', 0, 50)
            ->int('targetGlasses', 1, 50)
            ->validate();

        $cols = WaterIntakeModel::toColumns(array_merge($row, $data), (string) $row['child_id']);
        $this->db->prepare('UPDATE water_intakes SET date = ?, glasses = ?, target_glasses = ? WHERE id = ?')
            ->execute([$cols['date'], $cols['glasses'], $cols['target_glasses'], $row['id']]);

        if (isset($data['glassTimes'])) {
            $this->syncGlassTimes((string) $row['id'], $data['glassTimes']);
        }

        Response::success(
            WaterIntakeModel::fromRow($this->fetchRow('water_intakes', $row['id']), $this->glassTimes((string) $row['id'])),
            200,
            'Water intake updated.'
        );
    }

    public function destroyWater(Request $request): never
    {
        $this->deleteRecord($request, 'water_intakes', 'water intake');
    }

    // -------------------------------------------------------------------------
    // Mood tracking
    // -------------------------------------------------------------------------

    public function moods(Request $request): never
    {
        $this->listSimple($request, 'moods', 'date', [MoodModel::class, 'fromRow'], 'moods');
    }

    public function storeMood(Request $request): never
    {
        $this->storeSimple(
            $request,
            'moods',
            [MoodModel::class, 'toColumns'],
            [MoodModel::class, 'fromRow'],
            function (Validator $v, array $data) {
                $v->in('mood', ['happy', 'excited', 'calm', 'tired', 'sad', 'angry'])
                  ->string('note', 0, 1000);
            },
            'mood',
            null
        );
    }

    public function showMood(Request $request): never
    {
        $this->showSimple($request, 'moods', [MoodModel::class, 'fromRow'], 'mood');
    }

    public function updateMood(Request $request): never
    {
        $this->updateSimple(
            $request,
            'moods',
            [MoodModel::class, 'toColumns'],
            [MoodModel::class, 'fromRow'],
            function (Validator $v, array $data) {
                $v->in('mood', ['happy', 'excited', 'calm', 'tired', 'sad', 'angry'])
                  ->string('note', 0, 1000);
            },
            'mood'
        );
    }

    public function destroyMood(Request $request): never
    {
        $this->deleteRecord($request, 'moods', 'mood');
    }

    // -------------------------------------------------------------------------
    // Homework
    // -------------------------------------------------------------------------

    public function homework(Request $request): never
    {
        $this->listSimple($request, 'homework', 'due_date', [HomeworkModel::class, 'fromRow'], 'homework');
    }

    public function storeHomework(Request $request): never
    {
        $this->storeSimple(
            $request,
            'homework',
            [HomeworkModel::class, 'toColumns'],
            [HomeworkModel::class, 'fromRow'],
            function (Validator $v, array $data) {
                $v->has('title')->string('title', 1, 160)
                  ->has('subject')->string('subject', 1, 80)
                  ->string('icon', 0, 40)
                  ->date('dueDate', 'Y-m-d')
                  ->in('status', ['pending', 'inProgress', 'completed'])
                  ->int('coins', 0, 999)
                  ->number('progress', 0, 1);
            },
            'homework',
            null
        );
    }

    public function showHomework(Request $request): never
    {
        $this->showSimple($request, 'homework', [HomeworkModel::class, 'fromRow'], 'homework');
    }

    public function updateHomework(Request $request): never
    {
        $this->updateSimple(
            $request,
            'homework',
            [HomeworkModel::class, 'toColumns'],
            [HomeworkModel::class, 'fromRow'],
            function (Validator $v, array $data) {
                $v->string('title', 1, 160)
                  ->string('subject', 1, 80)
                  ->string('icon', 0, 40)
                  ->date('dueDate', 'Y-m-d')
                  ->in('status', ['pending', 'inProgress', 'completed'])
                  ->int('coins', 0, 999)
                  ->number('progress', 0, 1);
            },
            'homework'
        );
    }

    public function destroyHomework(Request $request): never
    {
        $this->deleteRecord($request, 'homework', 'homework');
    }

    // -------------------------------------------------------------------------
    // Attendance
    // -------------------------------------------------------------------------

    public function attendance(Request $request): never
    {
        $this->listSimple($request, 'attendance', 'date', [AttendanceModel::class, 'fromRow'], 'attendance records');
    }

    public function storeAttendance(Request $request): never
    {
        $this->storeSimple(
            $request,
            'attendance',
            [AttendanceModel::class, 'toColumns'],
            [AttendanceModel::class, 'fromRow'],
            function (Validator $v, array $data) {
                $v->date('date', 'Y-m-d')
                  ->in('status', ['present', 'absent', 'late'])
                  ->string('className', 0, 120);
            },
            'attendance record',
            'child_id,date'
        );
    }

    public function showAttendance(Request $request): never
    {
        $this->showSimple($request, 'attendance', [AttendanceModel::class, 'fromRow'], 'attendance record');
    }

    public function updateAttendance(Request $request): never
    {
        $this->updateSimple(
            $request,
            'attendance',
            [AttendanceModel::class, 'toColumns'],
            [AttendanceModel::class, 'fromRow'],
            function (Validator $v, array $data) {
                $v->date('date', 'Y-m-d')
                  ->in('status', ['present', 'absent', 'late'])
                  ->string('className', 0, 120);
            },
            'attendance record'
        );
    }

    public function destroyAttendance(Request $request): never
    {
        $this->deleteRecord($request, 'attendance', 'attendance record');
    }

    // -------------------------------------------------------------------------
    // Screen time
    // -------------------------------------------------------------------------

    public function screenTime(Request $request): never
    {
        $this->listSimple($request, 'screen_time', 'date', [ScreenTimeModel::class, 'fromRow'], 'screen time records');
    }

    public function storeScreenTime(Request $request): never
    {
        $this->storeSimple(
            $request,
            'screen_time',
            [ScreenTimeModel::class, 'toColumns'],
            [ScreenTimeModel::class, 'fromRow'],
            function (Validator $v, array $data) {
                $v->date('date', 'Y-m-d')
                  ->int('allowedMinutes', 0, 1440)
                  ->int('usedMinutes', 0, 1440)
                  ->string('category', 0, 60);
            },
            'screen time record',
            'child_id,date'
        );
    }

    public function showScreenTime(Request $request): never
    {
        $this->showSimple($request, 'screen_time', [ScreenTimeModel::class, 'fromRow'], 'screen time record');
    }

    public function updateScreenTime(Request $request): never
    {
        $this->updateSimple(
            $request,
            'screen_time',
            [ScreenTimeModel::class, 'toColumns'],
            [ScreenTimeModel::class, 'fromRow'],
            function (Validator $v, array $data) {
                $v->date('date', 'Y-m-d')
                  ->int('allowedMinutes', 0, 1440)
                  ->int('usedMinutes', 0, 1440)
                  ->string('category', 0, 60);
            },
            'screen time record'
        );
    }

    public function destroyScreenTime(Request $request): never
    {
        $this->deleteRecord($request, 'screen_time', 'screen time record');
    }

    // -------------------------------------------------------------------------
    // Generic helpers
    // -------------------------------------------------------------------------

    /**
     * List a simple per-child resource with an optional ?date= filter.
     *
     * @param array{class-string, string} $mapper [Model::class, 'fromRow']
     */
    private function listSimple(Request $request, string $table, string $dateColumn, array $mapper, string $label): never
    {
        $child = $this->childIdFromPath($request);
        $childId = (string) $child['id'];
        $date = $request->query('date');

        $sql = "SELECT * FROM `$table` WHERE child_id = ?";
        $params = [$childId];
        if ($date) {
            $sql .= " AND `$dateColumn` = ?";
            $params[] = $date;
        }
        $sql .= " ORDER BY `$dateColumn` DESC, created_at ASC";

        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        Response::success(array_map($mapper, $stmt->fetchAll()), 200, ucfirst($label) . ' retrieved.');
    }

    /**
     * @param array{class-string, string} $toColumns
     * @param array{class-string, string} $fromRow
     * @param callable(Validator, array): void $rules
     */
    private function storeSimple(Request $request, string $table, array $toColumns, array $fromRow, callable $rules, string $label, ?string $unique): never
    {
        $child = $this->childIdFromPath($request);
        $childId = (string) $child['id'];
        $data = $request->all();

        $validator = new Validator($data);
        $rules($validator, $data);
        $validator->validate();

        $cols = $toColumns($data, $childId);

        if ($unique !== null) {
            [$a, $b] = explode(',', $unique);
            // $a is always 'child_id'; $b is the secondary unique column (e.g. date).
            $existing = $this->findByPair($table, $childId, (string) $cols[trim($b)], trim($b));
            if ($existing !== false) {
                $this->updateRow($table, $cols, $existing['id']);
                Response::success($fromRow($this->fetchRow($table, $existing['id'])), 200, ucfirst($label) . ' updated.');
            }
        }

        $cols['id'] = Auth::uuid();
        $cols['child_id'] = $childId;
        $this->insertRow($table, $cols);

        Response::created($fromRow($this->fetchRow($table, $cols['id'])), ucfirst($label) . ' created.');
    }

    /**
     * @param array{class-string, string} $fromRow
     */
    private function showSimple(Request $request, string $table, array $fromRow, string $label): never
    {
        $row = $this->fetchOwnedRecord($request, $table, $label);
        Response::success($fromRow($row), 200, ucfirst($label) . ' retrieved.');
    }

    /**
     * @param array{class-string, string} $toColumns
     * @param array{class-string, string} $fromRow
     * @param callable(Validator, array): void $rules
     */
    private function updateSimple(Request $request, string $table, array $toColumns, array $fromRow, callable $rules, string $label): never
    {
        $row = $this->fetchOwnedRecord($request, $table, $label);
        $data = $request->all();

        $validator = new Validator($data);
        $rules($validator, $data);
        $validator->validate();

        $cols = $toColumns(array_merge($row, $data), (string) $row['child_id']);
        $this->updateRow($table, $cols, (string) $row['id']);

        $this->handleCompletionAward($table, $row, $cols);

        Response::success($fromRow($this->fetchRow($table, $row['id'])), 200, ucfirst($label) . ' updated.');
    }

    private function deleteRecord(Request $request, string $table, string $label): never
    {
        $row = $this->fetchOwnedRecord($request, $table, $label);
        $this->db->prepare("DELETE FROM `$table` WHERE id = ?")->execute([$row['id']]);
        Response::noContent(ucfirst($label) . ' deleted.');
    }

    /**
     * Fetch a record by its id and verify the requester (owning parent or the
     * rightful child session) may access its child.
     *
     * @param int $recordParamIndex Path segment holding the record id
     *                              (2 for /api/{resource}/{id}, 4 for /api/children/{id}/activities/{aId}).
     */
    private function fetchOwnedRecord(Request $request, string $table, string $label, int $recordParamIndex = 2): array
    {
        $id = $request->param($recordParamIndex);
        if ($id === null || $id === '' || $id === 'null') {
            throw new AppException('Record id is required.', 400);
        }

        $stmt = $this->db->prepare("SELECT * FROM `$table` WHERE id = ?");
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        if ($row === false) {
            throw new AppException(ucfirst($label) . ' not found.', 404);
        }

        $this->requireChildAccess($request, (string) $row['child_id']);
        return $row;
    }

    private function fetchRow(string $table, string $id): array
    {
        $stmt = $this->db->prepare("SELECT * FROM `$table` WHERE id = ?");
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        if ($row === false) {
            throw new AppException('Record not found.', 404);
        }
        return $row;
    }

    private function insertRow(string $table, array $cols): void
    {
        $keys = array_keys($cols);
        $set = implode(', ', array_map(fn ($k) => "`$k`", $keys));
        $placeholders = implode(', ', array_fill(0, count($keys), '?'));
        $this->db->prepare("INSERT INTO `$table` ($set) VALUES ($placeholders)")
            ->execute(array_values($cols));
    }

    private function updateRow(string $table, array $cols, string $id): void
    {
        unset($cols['id'], $cols['child_id']);
        $set = implode(', ', array_map(fn ($k) => "`$k` = ?", array_keys($cols)));
        $values = array_values($cols);
        $values[] = $id;
        $this->db->prepare("UPDATE `$table` SET $set WHERE id = ?")->execute($values);
    }

    private function findByPair(string $table, string $childId, string $first, string $second): array|false
    {
        $stmt = $this->db->prepare("SELECT * FROM `$table` WHERE child_id = ? AND `$second` = ?");
        $stmt->execute([$childId, $first]);
        return $stmt->fetch();
    }

    private function findByChildDate(string $table, string $childId, string $date): array|false
    {
        $stmt = $this->db->prepare("SELECT * FROM `$table` WHERE child_id = ? AND date = ?");
        $stmt->execute([$childId, $date]);
        return $stmt->fetch();
    }

    /**
     * @return string[] glass logged datetimes (ISO).
     */
    private function glassTimes(string $intakeId): array
    {
        $stmt = $this->db->prepare(
            'SELECT logged_at FROM water_glasses WHERE water_intake_id = ? ORDER BY logged_at ASC'
        );
        $stmt->execute([$intakeId]);
        return array_map(
            fn ($r) => (new \DateTimeImmutable($r['logged_at']))->format('Y-m-d\TH:i:s'),
            $stmt->fetchAll()
        );
    }

    /**
     * @param array<int, mixed> $glassTimes
     */
    private function syncGlassTimes(string $intakeId, array $glassTimes): void
    {
        $this->db->prepare('DELETE FROM water_glasses WHERE water_intake_id = ?')->execute([$intakeId]);
        $ins = $this->db->prepare('INSERT INTO water_glasses (id, water_intake_id, logged_at) VALUES (?, ?, ?)');
        foreach ($glassTimes as $time) {
            $ins->execute([Auth::uuid(), $intakeId, $this->normalizeDateTime((string) $time)]);
        }
        // Keep glasses count in sync with the actual log when provided.
        if (is_array($glassTimes) && $glassTimes !== []) {
            $this->db->prepare('UPDATE water_intakes SET glasses = ? WHERE id = ?')
                ->execute([count($glassTimes), $intakeId]);
        }
    }

    private function normalizeDateTime(string $value): string
    {
        $value = trim($value);
        try {
            $dt = new \DateTimeImmutable($value);
            return $dt->format('Y-m-d H:i:s');
        } catch (\Throwable) {
            return date('Y-m-d H:i:s');
        }
    }

    /**
     * Reward coins when an activity/homework transitions to completed.
     */
    private function handleCompletionAward(string $table, array $row, array $cols): void
    {
        $newStatus = $cols['status'] ?? null;
        $oldStatus = $row['status'] ?? null;
        if ($newStatus === 'completed' && $oldStatus !== 'completed') {
            $this->awardCoins((string) $row['child_id'], (int) ($cols['coins'] ?? $row['coins'] ?? 0));
        }
    }

    private function awardCoins(string $childId, int $coins): void
    {
        if ($coins <= 0) {
            return;
        }
        $this->db->prepare('UPDATE children SET coins = coins + ? WHERE id = ?')
            ->execute([$coins, $childId]);
    }
}
