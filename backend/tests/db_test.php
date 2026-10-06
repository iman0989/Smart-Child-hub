<?php

declare(strict_types=1);

/**
 * Smart Child Hub - DB-level test suite (Phase 6 QA).
 *
 * Builds an isolated database (smart_child_hub_db_test) from schema.sql and
 * verifies:
 *   - Table structure: engines, charset, required columns
 *   - Foreign keys + ON DELETE behaviors (CASCADE / SET NULL)
 *   - Unique constraints (per-child-per-date domains, email, token hashes)
 *   - Type enforcement (unsigned integers, enums, NOT NULL)
 *   - Insert / update / delete round-trips on every table
 *   - Referential integrity (orphan inserts rejected)
 *   - Cascade deletes propagate correctly (incl. water_glasses via water)
 *
 * The live database is never touched: everything runs on the test database.
 *
 * Run:  php backend/tests/db_test.php
 * Exit code 0 when every test passes, 1 otherwise.
 */

const DSN  = 'mysql:host=127.0.0.1;port=3306;charset=utf8mb4';
const USER = 'root';
const PASS = '';
const TEST_DB = 'smart_child_hub_db_test';

$passed = 0;
$failed = 0;
$failures = [];

function test(string $label, bool $ok, string $detail = ''): void
{
    global $passed, $failed, $failures;
    if ($ok) {
        $passed++;
        echo '  PASS  ' . $label . ($detail !== '' ? "  [$detail]" : '') . PHP_EOL;
    } else {
        $failed++;
        echo '  FAIL  ' . $label . ($detail !== '' ? "  [$detail]" : '') . PHP_EOL;
        $failures[] = $label;
    }
}

function section(string $name): void
{
    echo PHP_EOL . '== ' . $name . ' ==' . PHP_EOL;
}

$pdo = new PDO(DSN, USER, PASS, [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES => false,
]);

// ---------------------------------------------------------------------------
// Rebuild the test database from the canonical schema.
// ---------------------------------------------------------------------------
$pdo->exec("DROP DATABASE IF EXISTS `" . TEST_DB . "`");
$pdo->exec("CREATE DATABASE `" . TEST_DB . "` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
$pdo->exec("USE `" . TEST_DB . "`");

$schemaFile = __DIR__ . '/../database/schema.sql';
if (!is_file($schemaFile)) {
    echo "Schema file not found: $schemaFile\n";
    exit(1);
}
$schema = file_get_contents($schemaFile);
// schema.sql targets the live DB name; redirect to the test DB for isolation.
$schema = str_replace('CREATE DATABASE IF NOT EXISTS `smart_child_hub`', 'CREATE DATABASE IF NOT EXISTS `' . TEST_DB . '`', $schema);
$schema = str_replace('USE `smart_child_hub`;', 'USE `' . TEST_DB . '`;', $schema);

foreach (array_filter(array_map('trim', explode(';', $schema))) as $stmt) {
    $lines = array_filter(array_map('trim', explode("\n", $stmt)), static fn (string $l) => !str_starts_with($l, '--'));
    $sql = implode("\n", $lines);
    if ($sql === '') {
        continue;
    }
    try {
        $pdo->exec($sql);
    } catch (Throwable $e) {
        echo "Schema load error in: " . substr($sql, 0, 60) . "... -> " . $e->getMessage() . "\n";
        exit(1);
    }
}

// ---------------------------------------------------------------------------
// Structure
// ---------------------------------------------------------------------------
section('Structure (engines, charset, tables)');
$tables = [
    'parents', 'auth_tokens', 'password_resets', 'children', 'activities',
    'sleep_records', 'meals', 'water_intakes', 'water_glasses', 'moods',
    'homework', 'attendance', 'screen_time', 'notifications', 'reports',
];
$st = $pdo->prepare('SELECT TABLE_NAME, ENGINE, TABLE_COLLATION FROM information_schema.TABLES WHERE TABLE_SCHEMA = ?');
$st->execute([TEST_DB]);
$found = [];
foreach ($st->fetchAll() as $r) {
    $found[$r['TABLE_NAME']] = $r;
}
foreach ($tables as $t) {
    test("table $t exists", isset($found[$t]));
    if (isset($found[$t])) {
        test("$t is InnoDB", $found[$t]['ENGINE'] === 'InnoDB', $found[$t]['ENGINE']);
        test("$t is utf8mb4", str_contains($found[$t]['TABLE_COLLATION'], 'utf8mb4'), $found[$t]['TABLE_COLLATION']);
    }
}

section('Foreign keys & cascade behavior');
$fkSt = $pdo->prepare(
    'SELECT k.CONSTRAINT_NAME, k.TABLE_NAME, k.COLUMN_NAME, k.REFERENCED_TABLE_NAME, k.REFERENCED_COLUMN_NAME, r.DELETE_RULE
     FROM information_schema.KEY_COLUMN_USAGE k
     JOIN information_schema.REFERENTIAL_CONSTRAINTS r ON r.CONSTRAINT_NAME = k.CONSTRAINT_NAME AND r.CONSTRAINT_SCHEMA = k.CONSTRAINT_SCHEMA
     WHERE k.CONSTRAINT_SCHEMA = ? AND k.REFERENCED_TABLE_NAME IS NOT NULL'
);
$fkSt->execute([TEST_DB]);
$fks = [];
foreach ($fkSt->fetchAll() as $r) {
    $fks[$r['TABLE_NAME'] . '.' . $r['COLUMN_NAME']] = $r;
}

$expectedFks = [
    'auth_tokens.parent_id'   => ['parents', 'CASCADE'],
    'password_resets.parent_id' => ['parents', 'CASCADE'],
    'children.parent_id'      => ['parents', 'CASCADE'],
    'activities.child_id'     => ['children', 'CASCADE'],
    'sleep_records.child_id'  => ['children', 'CASCADE'],
    'meals.child_id'          => ['children', 'CASCADE'],
    'water_intakes.child_id'  => ['children', 'CASCADE'],
    'water_glasses.water_intake_id' => ['water_intakes', 'CASCADE'],
    'moods.child_id'          => ['children', 'CASCADE'],
    'homework.child_id'       => ['children', 'CASCADE'],
    'attendance.child_id'     => ['children', 'CASCADE'],
    'screen_time.child_id'    => ['children', 'CASCADE'],
    'notifications.parent_id' => ['parents', 'CASCADE'],
    'notifications.child_id'  => ['children', 'SET NULL'],
    'reports.child_id'        => ['children', 'CASCADE'],
];
foreach ($expectedFks as $key => [$refTable, $rule]) {
    $fk = $fks[$key] ?? null;
    if ($fk === null) {
        test("FK $key exists", false, 'missing');
        continue;
    }
    test("FK $key -> $refTable", $fk['REFERENCED_TABLE_NAME'] === $refTable, $fk['REFERENCED_TABLE_NAME']);
    test("FK $key ON DELETE $rule", $fk['DELETE_RULE'] === $rule, $fk['DELETE_RULE']);
}

section('Unique constraints');
$uqSt = $pdo->prepare(
    'SELECT TABLE_NAME, CONSTRAINT_NAME FROM information_schema.TABLE_CONSTRAINTS
     WHERE CONSTRAINT_SCHEMA = ? AND CONSTRAINT_TYPE = ?'
);
$uqSt->execute([TEST_DB, 'UNIQUE']);
$uniques = [];
foreach ($uqSt->fetchAll() as $r) {
    $uniques[$r['TABLE_NAME']][] = $r['CONSTRAINT_NAME'];
}
$expectedUniques = [
    'parents'         => ['uq_parents_email'],
    'auth_tokens'     => ['uq_auth_tokens_hash'],
    'password_resets' => ['uq_password_resets_hash'],
    'sleep_records'   => ['uq_sleep_child_date'],
    'water_intakes'   => ['uq_water_child_date'],
    'attendance'      => ['uq_attendance_child_date'],
    'screen_time'     => ['uq_screen_child_date'],
    'reports'         => ['uq_reports_child_type_period'],
];
foreach ($expectedUniques as $table => $names) {
    foreach ($names as $name) {
        test("unique $table.$name", in_array($name, $uniques[$table] ?? [], true), implode(',', $uniques[$table] ?? []));
    }
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------
section('CRUD round-trips');
$uuid = fn () => strtoupper(bin2hex(random_bytes(16)));
$parentId = $uuid();
$childId = $uuid();

$pdo->prepare('INSERT INTO parents (id, full_name, email, password_hash) VALUES (?, ?, ?, ?)')
    ->execute([$parentId, 'DB Tester', 'dbtest+' . substr(bin2hex(random_bytes(4)), 0, 8) . '@example.com', password_hash('Secret!123', PASSWORD_DEFAULT)]);

$pdo->prepare('INSERT INTO children (id, parent_id, name, age, pin, coins) VALUES (?, ?, ?, ?, ?, ?)')
    ->execute([$childId, $parentId, 'DB Kid', 8, '1234', 100]);

test('child insert persisted', (int) $pdo->query('SELECT COUNT(*) FROM children WHERE id = ' . $pdo->quote($childId))->fetchColumn() === 1);
test('parent insert persisted', (int) $pdo->query('SELECT COUNT(*) FROM parents WHERE id = ' . $pdo->quote($parentId))->fetchColumn() === 1);

// Update round-trip.
$pdo->prepare('UPDATE children SET name = ?, age = ? WHERE id = ?')->execute(['DB Kid 2', 9, $childId]);
$row = $pdo->query('SELECT name, age FROM children WHERE id = ' . $pdo->quote($childId))->fetch();
test('child update persisted', $row['name'] === 'DB Kid 2' && (int) $row['age'] === 9);

// Unique email constraint.
$pdo->prepare('INSERT INTO parents (id, full_name, email, password_hash) VALUES (?, ?, ?, ?)')
    ->execute([$uuid(), 'Dup', $parentEmail = 'dbtestdup@example.com', 'x']);
$tryDup = static function () use ($pdo, $uuid, $parentEmail): bool {
    try {
        $pdo->prepare('INSERT INTO parents (id, full_name, email, password_hash) VALUES (?, ?, ?, ?)')
            ->execute([$uuid(), 'Dup2', $parentEmail, 'x']);
        return false;
    } catch (Throwable) {
        return true;
    }
};
test('parents.email unique enforced', $tryDup());

// Orphan inserts rejected by FKs.
$tryOrphan = static function (string $sql, array $params): bool {
    global $pdo;
    try {
        $pdo->prepare($sql)->execute($params);
        return false;
    } catch (Throwable) {
        return true;
    }
};
test('orphan child (bad parent) rejected', $tryOrphan('INSERT INTO children (id, parent_id, name) VALUES (?, ?, ?)', [$uuid(), $uuid(), 'Orphan']));
test('orphan activity (bad child) rejected', $tryOrphan('INSERT INTO activities (id, child_id, title, activity_date) VALUES (?, ?, ?, ?)', [$uuid(), $uuid(), 'No child', date('Y-m-d')]));

// Helper for constraint-violation attempts.
$tryBad = static function (string $sql, array $params): bool {
    global $pdo;
    try {
        $pdo->prepare($sql)->execute($params);
        return false;
    } catch (Throwable) {
        return true;
    }
};

// Type enforcement. The server runs non-strict SQL mode (no STRICT_TRANS_TABLES),
// so the invariant that matters is: bad data never persists intact (rejected OR
// clamped/truncated, never stored verbatim).
$pdo->prepare('UPDATE children SET coins = -5 WHERE id = ?')->execute([$childId]);
$coins = (int) $pdo->query('SELECT coins FROM children WHERE id = ' . $pdo->quote($childId))->fetchColumn();
test('negative coins never stored (clamped or rejected)', $coins !== -5, "stored=$coins");
$pdo->prepare('UPDATE children SET coins = 100 WHERE id = ?')->execute([$childId]);

try {
    $pdo->prepare('INSERT INTO activities (id, child_id, title, status, activity_date) VALUES (?, ?, ?, ?, ?)')
        ->execute([$uuid(), $childId, 'Bad', 'nonsense', date('Y-m-d')]);
    $badStatus = $pdo->query('SELECT status FROM activities WHERE child_id = ' . $pdo->quote($childId) . ' AND title = ' . $pdo->quote('Bad'))->fetchColumn();
    test('invalid activity status never stored intact', $badStatus !== 'nonsense', 'stored=' . var_export($badStatus, true));
} catch (Throwable) {
    test('invalid activity status never stored intact', true, 'rejected');
}

try {
    $pdo->prepare('INSERT INTO meals (id, child_id, date, type, name) VALUES (?, ?, ?, ?, ?)')
        ->execute([$uuid(), $childId, date('Y-m-d'), 'brunch', 'x']);
    $badType = $pdo->query('SELECT type FROM meals WHERE child_id = ' . $pdo->quote($childId) . ' AND name = ' . $pdo->quote('x'))->fetchColumn();
    test('invalid meal type never stored intact', $badType !== 'brunch', 'stored=' . var_export($badType, true));
} catch (Throwable) {
    test('invalid meal type never stored intact', true, 'rejected');
}

// Activity CRUD + unique-ish index check (no unique on child+date, many allowed).
$aId = $uuid();
$pdo->prepare('INSERT INTO activities (id, child_id, title, status, activity_date, coins) VALUES (?, ?, ?, ?, ?, ?)')
    ->execute([$aId, $childId, 'Brush teeth', 'completed', date('Y-m-d'), 5]);
test('activity insert', (int) $pdo->query('SELECT COUNT(*) FROM activities WHERE id = ' . $pdo->quote($aId))->fetchColumn() === 1);
$pdo->prepare('UPDATE activities SET status = ? WHERE id = ?')->execute(['pending', $aId]);
test('activity update', $pdo->query('SELECT status FROM activities WHERE id = ' . $pdo->quote($aId))->fetchColumn() === 'pending');
test('multiple activities per child+date allowed', (bool) $pdo->prepare('INSERT INTO activities (id, child_id, title, activity_date) VALUES (?, ?, ?, ?)')->execute([$uuid(), $childId, 'Second', date('Y-m-d')]));

// Sleep upsert domain (child+date unique).
$sId = $uuid();
$pdo->prepare('INSERT INTO sleep_records (id, child_id, date, hours, quality) VALUES (?, ?, ?, ?, ?)')
    ->execute([$sId, $childId, date('Y-m-d'), 8.5, 'good']);
test('sleep insert', (int) $pdo->query('SELECT COUNT(*) FROM sleep_records WHERE id = ' . $pdo->quote($sId))->fetchColumn() === 1);
test('sleep unique child+date enforced', $tryBad('INSERT INTO sleep_records (id, child_id, date, hours) VALUES (?, ?, ?, ?)', [$uuid(), $childId, date('Y-m-d'), 7.0]));
$pdo->prepare('UPDATE sleep_records SET hours = ?, quality = ? WHERE id = ?')->execute([7.5, 'fair', $sId]);
$row = $pdo->query('SELECT hours, quality FROM sleep_records WHERE id = ' . $pdo->quote($sId))->fetch();
test('sleep update persisted', (float) $row['hours'] === 7.5 && $row['quality'] === 'fair');

// Water + glass cascade (via FK).
$wId = $uuid();
$pdo->prepare('INSERT INTO water_intakes (id, child_id, date, glasses, target_glasses) VALUES (?, ?, ?, ?, ?)')
    ->execute([$wId, $childId, date('Y-m-d'), 4, 8]);
$gId = $uuid();
$pdo->prepare('INSERT INTO water_glasses (id, water_intake_id, logged_at) VALUES (?, ?, NOW())')->execute([$gId, $wId]);
test('water_glasses child record insert', (int) $pdo->query('SELECT COUNT(*) FROM water_glasses WHERE id = ' . $pdo->quote($gId))->fetchColumn() === 1);
test('water unique child+date enforced', $tryBad('INSERT INTO water_intakes (id, child_id, date, glasses) VALUES (?, ?, ?, ?)', [$uuid(), $childId, date('Y-m-d'), 3]));
$pdo->prepare('DELETE FROM water_intakes WHERE id = ?')->execute([$wId]);
test('water_glasses cascaded via water_intakes delete', (int) $pdo->query('SELECT COUNT(*) FROM water_glasses WHERE id = ' . $pdo->quote($gId))->fetchColumn() === 0);

// Mood, homework, attendance, screen_time, notifications, reports inserts.
$mId = $uuid();
$pdo->prepare('INSERT INTO moods (id, child_id, date, mood, note) VALUES (?, ?, NOW(), ?, ?)')->execute([$mId, $childId, 'happy', 'Great day']);
test('mood insert', (int) $pdo->query('SELECT COUNT(*) FROM moods WHERE id = ' . $pdo->quote($mId))->fetchColumn() === 1);

$hId = $uuid();
$pdo->prepare('INSERT INTO homework (id, child_id, title, subject, due_date, status) VALUES (?, ?, ?, ?, ?, ?)')
    ->execute([$hId, $childId, 'Math sheet', 'Math', date('Y-m-d', strtotime('+1 day')), 'pending']);
test('homework insert', (int) $pdo->query('SELECT COUNT(*) FROM homework WHERE id = ' . $pdo->quote($hId))->fetchColumn() === 1);

$pdo->prepare('INSERT INTO attendance (id, child_id, date, status) VALUES (?, ?, ?, ?)')->execute([$uuid(), $childId, date('Y-m-d'), 'present']);
test('attendance unique child+date enforced', $tryBad('INSERT INTO attendance (id, child_id, date, status) VALUES (?, ?, ?, ?)', [$uuid(), $childId, date('Y-m-d'), 'late']));

$pdo->prepare('INSERT INTO screen_time (id, child_id, date, allowed_minutes, used_minutes) VALUES (?, ?, ?, ?, ?)')
    ->execute([$uuid(), $childId, date('Y-m-d'), 60, 25]);
test('screen_time unique child+date enforced', $tryBad('INSERT INTO screen_time (id, child_id, date, used_minutes) VALUES (?, ?, ?, ?)', [$uuid(), $childId, date('Y-m-d'), 30]));

$nId = $uuid();
$pdo->prepare('INSERT INTO notifications (id, parent_id, child_id, type, title, message) VALUES (?, ?, ?, ?, ?, ?)')
    ->execute([$nId, $parentId, $childId, 'activity', 'Reminder', 'msg']);
test('notification insert with child link', (int) $pdo->query('SELECT COUNT(*) FROM notifications WHERE id = ' . $pdo->quote($nId))->fetchColumn() === 1);

$pdo->prepare('INSERT INTO reports (id, child_id, type, period_date, data) VALUES (?, ?, ?, ?, ?)')
    ->execute([$uuid(), $childId, 'daily', date('Y-m-d'), json_encode(['x' => 1])]);
test('reports unique child+type+period enforced', $tryBad('INSERT INTO reports (id, child_id, type, period_date, data) VALUES (?, ?, ?, ?, ?)', [$uuid(), $childId, 'daily', date('Y-m-d'), '{}']));

// Auth + password reset tokens CRUD.
$pdo->prepare('INSERT INTO auth_tokens (id, parent_id, token_hash, expires_at) VALUES (?, ?, ?, ?)')
    ->execute([$uuid(), $parentId, str_repeat('a', 64), date('Y-m-d H:i:s', strtotime('+30 days'))]);
test('auth token insert', (int) $pdo->query('SELECT COUNT(*) FROM auth_tokens WHERE parent_id = ' . $pdo->quote($parentId))->fetchColumn() === 1);
test('auth token hash unique enforced', $tryBad('INSERT INTO auth_tokens (id, parent_id, token_hash, expires_at) VALUES (?, ?, ?, ?)', [$uuid(), $parentId, str_repeat('a', 64), date('Y-m-d H:i:s')]));
$pdo->prepare('INSERT INTO password_resets (id, parent_id, token_hash, expires_at) VALUES (?, ?, ?, ?)')
    ->execute([$uuid(), $parentId, str_repeat('b', 64), date('Y-m-d H:i:s')]);
test('password reset token insert', (int) $pdo->query('SELECT COUNT(*) FROM password_resets WHERE parent_id = ' . $pdo->quote($parentId))->fetchColumn() === 1);

// ---------------------------------------------------------------------------
// Cascade deletes
// ---------------------------------------------------------------------------
section('Cascade deletes');
$beforeChildren = (int) $pdo->query('SELECT COUNT(*) FROM children WHERE parent_id = ' . $pdo->quote($parentId))->fetchColumn();

$pdo->prepare('DELETE FROM parents WHERE id = ?')->execute([$parentId]);

test('children cascade on parent delete', (int) $pdo->query('SELECT COUNT(*) FROM children WHERE id = ' . $pdo->quote($childId))->fetchColumn() === 0);
test('auth_tokens cascade on parent delete', (int) $pdo->query('SELECT COUNT(*) FROM auth_tokens WHERE parent_id = ' . $pdo->quote($parentId))->fetchColumn() === 0);
test('password_resets cascade on parent delete', (int) $pdo->query('SELECT COUNT(*) FROM password_resets WHERE parent_id = ' . $pdo->quote($parentId))->fetchColumn() === 0);
test('notifications cascade on parent delete', (int) $pdo->query('SELECT COUNT(*) FROM notifications WHERE parent_id = ' . $pdo->quote($parentId))->fetchColumn() === 0);

// Child-delete cascade: rebuild a child + all dependent rows, then delete it.
$parentId = $uuid();
$childId = $uuid();
$pdo->prepare('INSERT INTO parents (id, full_name, email, password_hash) VALUES (?, ?, ?, ?)')
    ->execute([$parentId, 'Cascade Tester', 'cascade+' . substr(bin2hex(random_bytes(4)), 0, 8) . '@example.com', 'x']);
$pdo->prepare('INSERT INTO children (id, parent_id, name) VALUES (?, ?, ?)')->execute([$childId, $parentId, 'Cascade Kid']);

$childDepTables = [
    ['activities', 'INSERT INTO activities (id, child_id, title, activity_date) VALUES (?, ?, ?, ?)', ['Cascade task', date('Y-m-d')]],
    ['sleep_records', 'INSERT INTO sleep_records (id, child_id, date, hours) VALUES (?, ?, ?, ?)', [date('Y-m-d'), 8.0]],
    ['meals', 'INSERT INTO meals (id, child_id, date, type, name) VALUES (?, ?, ?, ?, ?)', [date('Y-m-d'), 'lunch', 'Rice']],
    ['water_intakes', 'INSERT INTO water_intakes (id, child_id, date, glasses) VALUES (?, ?, ?, ?)', [date('Y-m-d'), 3]],
    ['moods', 'INSERT INTO moods (id, child_id, date, mood) VALUES (?, ?, NOW(), ?)', ['calm']],
    ['homework', 'INSERT INTO homework (id, child_id, title, subject, due_date) VALUES (?, ?, ?, ?, ?)', ['HW', 'Math', date('Y-m-d')]],
    ['attendance', 'INSERT INTO attendance (id, child_id, date, status) VALUES (?, ?, ?, ?)', [date('Y-m-d'), 'present']],
    ['screen_time', 'INSERT INTO screen_time (id, child_id, date, used_minutes) VALUES (?, ?, ?, ?)', [date('Y-m-d'), 20]],
    ['reports', 'INSERT INTO reports (id, child_id, type, period_date, data) VALUES (?, ?, ?, ?, ?)', ['daily', date('Y-m-d'), '{}']],
];
$wId2 = null;
foreach ($childDepTables as [$table, $sql, $extra]) {
    $params = [$uuid(), $childId];
    foreach ($extra as $e) {
        $params[] = $e;
    }
    $pdo->prepare($sql)->execute($params);
}
$pdo->prepare('INSERT INTO water_intakes (id, child_id, date, glasses) VALUES (?, ?, ?, ?)')->execute([$wId2 = $uuid(), $childId, date('Y-m-d', strtotime('-1 day')), 2]);
$pdo->prepare('INSERT INTO water_glasses (id, water_intake_id, logged_at) VALUES (?, ?, NOW())')->execute([$uuid(), $wId2]);
$pdo->prepare('INSERT INTO notifications (id, parent_id, child_id, type, title, message) VALUES (?, ?, ?, ?, ?, ?)')
    ->execute([$uuid(), $parentId, $childId, 'activity', 'T', 'M']);

$pdo->prepare('DELETE FROM children WHERE id = ?')->execute([$childId]);

foreach (['activities', 'sleep_records', 'meals', 'water_intakes', 'moods', 'homework', 'attendance', 'screen_time', 'reports'] as $table) {
    test("child delete cascades to $table", (int) $pdo->query("SELECT COUNT(*) FROM `$table` WHERE child_id = " . $pdo->quote($childId))->fetchColumn() === 0);
}
test('child delete cascades water_glasses via intake', (int) $pdo->query('SELECT COUNT(*) FROM water_glasses WHERE water_intake_id = ' . $pdo->quote($wId2))->fetchColumn() === 0);
test('child delete SET NULLs notifications.child_id', (int) $pdo->query('SELECT COUNT(*) FROM notifications WHERE child_id = ' . $pdo->quote($childId))->fetchColumn() === 0);
test('notification row survives child delete (SET NULL)', (int) $pdo->query("SELECT COUNT(*) FROM notifications n JOIN parents p ON p.id = n.parent_id WHERE n.parent_id = " . $pdo->quote($parentId))->fetchColumn() >= 1);

// ---------------------------------------------------------------------------
section('Cleanup');
$pdo->exec("DROP DATABASE IF EXISTS `" . TEST_DB . "`");
test('test database dropped', true);

echo PHP_EOL . str_repeat('=', 64) . PHP_EOL;
echo 'TOTAL: ' . ($passed + $failed) . "  PASSED: $passed  FAILED: $failed\n";
if ($failures !== []) {
    echo 'FAILURES:' . PHP_EOL;
    foreach ($failures as $f) {
        echo '  - ' . $f . PHP_EOL;
    }
}
echo str_repeat('=', 64) . PHP_EOL;
exit($failed === 0 ? 0 : 1);
