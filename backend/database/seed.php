<?php

declare(strict_types=1);

/**
 * Smart Child Hub – database seeder.
 *
 * Run from CLI:
 *   php database/seed.php
 *
 * Creates the demo parent account (dana@example.com / 123456), three children
 * and realistic sample records matching the Flutter front-end demo data.
 */

require __DIR__ . '/../app/config/config.php';

use SmartChildHub\Config\Config;

function uuid(): string
{
    $data = random_bytes(16);
    $data[6] = chr((ord($data[6]) & 0x0f) | 0x40);
    $data[8] = chr((ord($data[8]) & 0x3f) | 0x80);
    return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
}

function dateAgo(int $days): string
{
    return (new DateTimeImmutable())->modify("-$days days")->format('Y-m-d');
}

function isoAgo(int $days): string
{
    return (new DateTimeImmutable())->modify("-$days days")->format('Y-m-d\TH:i:s');
}

try {
    Config::load();
    $db = new PDO(
        'mysql:host=' . Config::$DB_HOST . ';dbname=' . Config::$DB_NAME . ';charset=utf8mb4',
        Config::$DB_USER,
        Config::$DB_PASS,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );

    echo "Seeding {$db->query('SELECT DATABASE()')->fetchColumn()} ...\n";

    // Clear existing rows so the seed is idempotent.
    foreach ([
        'reports', 'notifications', 'screen_time', 'attendance', 'homework',
        'moods', 'water_glasses', 'water_intakes', 'meals', 'sleep_records',
        'activities', 'children', 'password_resets', 'auth_tokens', 'parents',
    ] as $table) {
        $db->exec("DELETE FROM `$table`");
    }

    $now = date('Y-m-d H:i:s');

    // --- Parent -------------------------------------------------------------
    $parentId = uuid();
    $db->prepare(
        'INSERT INTO parents (id, full_name, email, phone, password_hash, avatar_key) VALUES (?, ?, ?, ?, ?, ?)'
    )->execute([
        $parentId,
        'Dana Smith',
        'dana@example.com',
        '+1 555 010 2030',
        password_hash('123456', PASSWORD_DEFAULT),
        'grape',
    ]);

    // --- Children -----------------------------------------------------------
    // Grades are "Grade 1".."Grade 9" and ages are 4-14, matching the API rules.
    $children = [
        ['id' => uuid(), 'name' => 'Mia', 'age' => 7, 'grade' => 'Grade 2', 'about' => 'Loves drawing and story time',  'avatar_key' => 'sunshine', 'coins' => 240, 'streak' => 5],
        ['id' => uuid(), 'name' => 'Leo', 'age' => 5, 'grade' => 'Grade 1', 'about' => 'Loves building with blocks',     'avatar_key' => 'sky',      'coins' => 180, 'streak' => 3],
        ['id' => uuid(), 'name' => 'Ava', 'age' => 9, 'grade' => 'Grade 4', 'about' => 'Loves soccer and playing piano', 'avatar_key' => 'mint',     'coins' => 95,  'streak' => 1],
    ];

    $insChild = $db->prepare(
        'INSERT INTO children (id, parent_id, name, age, grade, about_child, avatar_key, coins, streak_days, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
    );
    $createdAt = date('Y-m-d H:i:s', strtotime('-30 minutes'));
    foreach ($children as $idx => $c) {
        $insChild->execute([
            $c['id'], $parentId, $c['name'], $c['age'], $c['grade'], $c['about'],
            $c['avatar_key'], $c['coins'], $c['streak'],
            date('Y-m-d H:i:s', strtotime($createdAt . ' +' . $idx . ' minutes')),
        ]);
    }

    $mia = $children[0]['id'];

    // --- Activities (today's routine for Mia) -------------------------------
    $tasks = [
        ['Brush teeth',    'sparkle',   'Morning routine', '7:00 AM',  5,  'completed'],
        ['Make the bed',   'bed',       'Morning routine', '7:20 AM',  5,  'completed'],
        ['Breakfast',      'food',      'Morning routine', '7:45 AM',  5,  'completed'],
        ['Reading time',   'book',      'Learning & fun',  '4:00 PM',  10, 'pending'],
        ['Outdoor play',   'run',       'Learning & fun',  '5:00 PM',  10, 'pending'],
        ['Homework',       'homework',  'Learning & fun',  '6:00 PM',  15, 'pending'],
        ['Evening shower', 'water',     'Evening routine', '8:00 PM',  5,  'locked'],
    ];
    $insTask = $db->prepare(
        'INSERT INTO activities (id, child_id, title, icon, category, time, coins, status, activity_date)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'
    );
    foreach ($tasks as $t) {
        $insTask->execute([uuid(), $mia, $t[0], $t[1], $t[2], $t[3], $t[4], $t[5], date('Y-m-d')]);
    }

    // --- Sleep records (last 7 nights for Mia) ------------------------------
    $sleepData = [
        [0, 20, 30, 6, 30, 9.5, 'restful', 'Fell asleep quickly'],
        [1, 21, 0, 6, 45, 9.0, 'good',    ''],
        [2, 20, 45, 6, 15, 9.0, 'good',    ''],
        [3, 21, 30, 6, 30, 8.5, 'fair',    ''],
        [4, 20, 15, 6, 0, 9.0,  'good',    ''],
        [5, 20, 45, 7, 0, 9.5,  'restful', 'Weekend sleep-in'],
        [6, 21, 15, 6, 30, 8.5, 'fair',    ''],
    ];
    $insSleep = $db->prepare(
        'INSERT INTO sleep_records (id, child_id, date, bedtime_hour, bedtime_minute, wake_hour, wake_minute, hours, quality, notes)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
    );
    foreach ($sleepData as $s) {
        $insSleep->execute([uuid(), $mia, dateAgo($s[0]), $s[1], $s[2], $s[3], $s[4], $s[5], $s[6], $s[7]]);
    }

    // --- Meals (today for Mia) ----------------------------------------------
    $meals = [
        ['breakfast', 'Oatmeal with berries',    'sun',   '7:45 AM',  260, 9, 42, 4,  1],
        ['snack',     'Apple slices',            'heart', '10:30 AM', 80,  0, 20, 0,  1],
        ['lunch',     'Chicken sandwich & salad', 'food', '12:30 PM', 410, 28, 34, 14, 1],
        ['dinner',    'Spaghetti with meatballs', 'moon', '6:30 PM',  520, 24, 62, 16, 0],
    ];
    $insMeal = $db->prepare(
        'INSERT INTO meals (id, child_id, date, type, name, icon, time, calories, protein, carbs, fat, eaten)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
    );
    foreach ($meals as $m) {
        $insMeal->execute([uuid(), $mia, date('Y-m-d'), $m[0], $m[1], $m[2], $m[3], $m[4], $m[5], $m[6], $m[7], $m[8]]);
    }

    // --- Water intake (today for Mia) with glass log ------------------------
    $waterId = uuid();
    $db->prepare(
        'INSERT INTO water_intakes (id, child_id, date, glasses, target_glasses) VALUES (?, ?, ?, ?, ?)'
    )->execute([$waterId, $mia, date('Y-m-d'), 6, 8]);
    $insGlass = $db->prepare('INSERT INTO water_glasses (id, water_intake_id, logged_at) VALUES (?, ?, ?)');
    foreach (['7:50', '9:15', '10:40', '12:30', '15:00', '17:20'] as $t) {
        $insGlass->execute([uuid(), $waterId, date('Y-m-d') . ' ' . $t . ':00']);
    }

    // --- Moods (last 5 days for Mia) ----------------------------------------
    $moods = [
        [0, 'happy',   'Loved the drawing class today!'],
        [1, 'calm',    'Quiet afternoon with books.'],
        [2, 'excited', 'Play date with Ava!'],
        [3, 'tired',   'Long day at school.'],
        [4, 'sad',     'Lost my favourite sticker.'],
    ];
    $insMood = $db->prepare(
        'INSERT INTO moods (id, child_id, date, mood, note) VALUES (?, ?, ?, ?, ?)'
    );
    foreach ($moods as $m) {
        $insMood->execute([uuid(), $mia, isoAgo($m[0]), $m[1], $m[2]]);
    }

    // --- Homework for Mia ---------------------------------------------------
    $homework = [
        ['Math worksheet - page 12', 'Math',     'book',   0, 'completed', 10, 1.00],
        ['Read 20 minutes',          'English',  'book',   0, 'completed', 10, 1.00],
        ['Spelling practice',        'English',  'edit',   0, 'completed', 5,  1.00],
        ['Draw your family',         'Art',      'paint',  -1, 'inProgress', 5, 0.50],
        ['Science: collect leaves',  'Science',  'plants', -2, 'pending',  10, 0.00],
    ];
    $insHw = $db->prepare(
        'INSERT INTO homework (id, child_id, title, subject, icon, due_date, status, coins, progress)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'
    );
    foreach ($homework as $h) {
        $insHw->execute([uuid(), $mia, $h[0], $h[1], $h[2], dateAgo($h[3]), $h[4], $h[5], $h[6]]);
    }

    // --- Attendance (last ~20 school days for Mia) --------------------------
    $insAtt = $db->prepare(
        'INSERT INTO attendance (id, child_id, date, status, class_name) VALUES (?, ?, ?, ?, ?)'
    );
    $weekday = 0;
    for ($i = 0; $i < 31 && $weekday < 20; $i++) {
        $d = new DateTimeImmutable();
        $d = $d->modify("-$i days");
        if ((int) $d->format('N') >= 6) { // skip weekends
            continue;
        }
        $weekday++;
        $status = ($i === 12) ? 'absent' : (($i === 4) ? 'late' : 'present');
        $insAtt->execute([uuid(), $mia, $d->format('Y-m-d'), $status, 'Grade 2 - Room 4']);
    }

    // --- Screen time (last 4 days for Mia) ----------------------------------
    $insSt = $db->prepare(
        'INSERT INTO screen_time (id, child_id, date, allowed_minutes, used_minutes, category)
         VALUES (?, ?, ?, ?, ?, ?)'
    );
    foreach ([0 => 35, 1 => 52, 2 => 40, 3 => 65] as $ago => $used) {
        $insSt->execute([uuid(), $mia, dateAgo($ago), 60, $used, 'Total']);
    }

    // --- Notifications for Dana ---------------------------------------------
    $notifs = [
        ['homework',     'Homework reminder',      'Mia has 2 homework tasks due today. Help her finish them!',               'homework', 30],
        ['meal',         'Dinner time',            'It is dinner time. Mia still needs to eat her spaghetti.',                 'food',     75],
        ['activity',     'Evening routine',        'Bedtime is in 30 minutes. Start the evening wind-down.',                   'moon',     150],
        ['announcement', 'Parent announcement',    'Parent-teacher meeting on Friday at 4 PM. Please confirm attendance.',     'bell',     360],
        ['activity',     'Screen time alert',      'Mia used 65 minutes of screen time yesterday, 5 over the limit.',          'target',   1440],
        ['meal',         'Hydration goal',         'Mia reached 6 of 8 glasses today. Keep it going!',                         'water',    1800],
    ];
    $insNotif = $db->prepare(
        'INSERT INTO notifications (id, parent_id, child_id, type, title, message, icon, is_read, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)'
    );
    foreach ($notifs as $idx => $n) {
        $read = $idx >= 3 ? 1 : 0;
        $created = (new DateTimeImmutable())->modify("-{$n[4]} minutes")->format('Y-m-d H:i:s');
        $insNotif->execute([uuid(), $parentId, $mia, $n[0], $n[1], $n[2], $n[3], $read, $created]);
    }

    echo "Seeded " . count($children) . " children and sample records for " . $children[0]['name'] . ".\n";
    echo "Demo login: dana@example.com / 123456\n";
} catch (Throwable $e) {
    fwrite(STDERR, 'Seed failed: ' . $e->getMessage() . "\n");
    exit(1);
}
