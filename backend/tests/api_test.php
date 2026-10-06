<?php

declare(strict_types=1);

/**
 * Smart Child Hub – API test runner (Phase 6 QA).
 *
 * Hits the live API (default http://localhost:8080) and verifies:
 *   - Authentication (register, login, logout, me, password flows)
 *   - Parent profile + children CRUD + dashboard
 *   - Every child-activity resource CRUD (incl. upserts + coin awards)
 *   - Notifications + pagination + read/unread
 *   - Reports (daily/weekly/monthly/history)
 *   - Validation (422), auth (401), not-found (404), conflict (409)
 *   - Security (SQLi, XSS, ownership, password/token hashing)
 *   - Performance (per-request timing, slow-endpoint report)
 *
 * Run:  php backend/tests/api_test.php   [base_url]
 * Exit code 0 when every test passes, 1 otherwise.
 */

const PASS = 'PASS';
const FAIL = 'FAIL';

final class ApiTester
{
    private int $passed = 0;
    private int $failed = 0;
    private int $slow = 0;
    private float $slowThresholdMs = 300.0;
    private array $slowEndpoints = [];
    private array $failures = [];

    public function __construct(private string $base)
    {
    }

    /** @return array{status:int, body:mixed, headers:array<string,string>, ms:float} */
    public function request(string $method, string $path, ?array $json = null, ?string $token = null, array $query = []): array
    {
        $url = $this->base . $path;
        if ($query !== []) {
            $url .= '?' . http_build_query($query);
        }

        $headers = ['Accept: application/json'];
        if ($json !== null) {
            $headers[] = 'Content-Type: application/json';
        }
        if ($token !== null) {
            $headers[] = 'Authorization: Bearer ' . $token;
        }

        $context = stream_context_create([
            'http' => [
                'method'  => $method,
                'header'  => implode("\r\n", $headers),
                'content' => $json !== null ? json_encode($json) : null,
                'ignore_errors' => true,
                'timeout' => 15,
            ],
        ]);

        $start = microtime(true);
        $raw = @file_get_contents($url, false, $context);
        $ms = (microtime(true) - $start) * 1000;
        $status = 0;
        foreach ($http_response_header ?? [] as $line) {
            if (preg_match('#^HTTP/\S+\s+(\d+)#', $line, $m)) {
                $status = (int) $m[1];
            }
        }
        $headers = $this->parseHeaders($http_response_header ?? []);

        if ($ms >= $this->slowThresholdMs) {
            $this->slow++;
            $this->slowEndpoints[] = sprintf('%.0fms  %s %s', $ms, $method, $path);
        }

        $body = $raw === false || trim($raw) === '' ? null : json_decode($raw, true);
        return ['status' => $status, 'body' => $body, 'headers' => $headers, 'ms' => $ms];
    }

    private function parseHeaders(array $lines): array
    {
        $headers = [];
        foreach ($lines as $i => $line) {
            if ($i === 0 || !str_contains($line, ':')) {
                continue;
            }
            [$k, $v] = explode(':', $line, 2);
            $headers[strtolower(trim($k))] = trim($v);
        }
        return $headers;
    }

    /**
     * Multipart/form-data request used for the child photo endpoints.
     *
     * `$fileName` and `$contentType` are what a client *declares*; the API must
     * decide what the bytes really are, so tests deliberately mismatch them.
     *
     * @return array{status:int, body:mixed, headers:array<string,string>, ms:float}
     */
    public function uploadPhoto(
        string $path,
        string $fileName,
        string $content,
        string $declaredType = 'image/png',
        ?string $token = null,
        string $field = 'photo'
    ): array {
        $boundary = '----ApiTest' . bin2hex(random_bytes(12));
        $parts = '--' . $boundary . "\r\n"
            . 'Content-Disposition: form-data; name="' . $field . '"; filename="' . $fileName . '"' . "\r\n"
            . 'Content-Type: ' . $declaredType . "\r\n\r\n"
            . $content . "\r\n"
            . '--' . $boundary . "--\r\n";

        $headers = [
            'Accept: application/json',
            'Content-Type: multipart/form-data; boundary=' . $boundary,
        ];
        if ($token !== null) {
            $headers[] = 'Authorization: Bearer ' . $token;
        }

        $context = stream_context_create([
            'http' => [
                'method'  => 'POST',
                'header'  => implode("\r\n", $headers),
                'content' => $parts,
                'ignore_errors' => true,
                'timeout' => 20,
            ],
        ]);

        $start = microtime(true);
        $raw = @file_get_contents($this->base . $path, false, $context);
        $ms = (microtime(true) - $start) * 1000;

        $status = 0;
        foreach ($http_response_header ?? [] as $line) {
            if (preg_match('#^HTTP/\S+\s+(\d+)#', $line, $m)) {
                $status = (int) $m[1];
            }
        }
        if ($ms >= $this->slowThresholdMs) {
            $this->slow++;
            $this->slowEndpoints[] = sprintf('%.0fms  %s %s', $ms, 'POST', $path);
        }

        $body = $raw === false || trim($raw) === '' ? null : json_decode($raw, true);
        return ['status' => $status, 'body' => $body, 'headers' => $this->parseHeaders($http_response_header ?? []), 'ms' => $ms];
    }

    /** Fetches a raw (non-JSON) URL such as a stored child photo. */
    public function fetchRaw(string $url): array
    {
        $context = stream_context_create(['http' => ['ignore_errors' => true, 'timeout' => 20]]);
        $raw = @file_get_contents($url, false, $context);
        $status = 0;
        $headers = [];
        foreach ($http_response_header ?? [] as $line) {
            if (preg_match('#^HTTP/\S+\s+(\d+)#', $line, $m)) {
                $status = (int) $m[1];
            }
        }
        foreach ($http_response_header ?? [] as $line) {
            if (str_contains($line, ':')) {
                [$k, $v] = explode(':', $line, 2);
                $headers[strtolower(trim($k))] = trim($v);
            }
        }

        return ['status' => $status, 'body' => $raw === false ? null : $raw, 'headers' => $headers, 'ms' => 0.0];
    }

    public function check(string $label, bool $ok, string $detail = ''): void
    {
        if ($ok) {
            $this->passed++;
            echo '  ' . PASS . '  ' . $label . ($detail !== '' ? "  [$detail]" : '') . PHP_EOL;
        } else {
            $this->failed++;
            echo '  ' . FAIL . '  ' . $label . ($detail !== '' ? "  [$detail]" : '') . PHP_EOL;
            $this->failures[] = $label;
        }
    }

    public function section(string $name): void
    {
        echo PHP_EOL . '== ' . $name . ' ==' . PHP_EOL;
    }

    /** Assertion helpers --------------------------------------------------- */

    public function assertStatus(string $label, array $r, int $expected): void
    {
        $this->check($label, $r['status'] === $expected, 'expected ' . $expected . ', got ' . $r['status']);
    }

    public function assertSuccess(string $label, array $r): void
    {
        $this->check($label . ' (success=true)', ($r['body']['success'] ?? false) === true);
    }

    public function assertHas(string $label, array $r, string $key): void
    {
        $this->check($label . ' (data.' . $key . ')', isset($r['body']['data'][$key]) || array_key_exists($key, $r['body']['data'] ?? []));
    }

    public function assertBodyHas(string $label, array $r, string $key): void
    {
        $this->check($label . ' (body.' . $key . ')', isset($r['body'][$key]) || array_key_exists($key, $r['body'] ?? []));
    }

    public function assertEqual(string $label, mixed $expected, mixed $actual): void
    {
        $this->check($label, $expected === $actual, 'expected ' . var_export($expected, true) . ', got ' . var_export($actual, true));
    }

    public function report(): int
    {
        echo PHP_EOL . str_repeat('=', 64) . PHP_EOL;
        echo 'TOTAL: ' . ($this->passed + $this->failed) . "  PASSED: $this->passed  FAILED: $this->failed\n";
        if ($this->slow > 0) {
            echo "SLOW ENDPOINTS (>={$this->slowThresholdMs}ms): $this->slow\n";
            foreach ($this->slowEndpoints as $e) {
                echo '  ' . $e . PHP_EOL;
            }
        } else {
            echo "SLOW ENDPOINTS: none\n";
        }
        if ($this->failures !== []) {
            echo 'FAILURES:' . PHP_EOL;
            foreach ($this->failures as $f) {
                echo '  - ' . $f . PHP_EOL;
            }
        }
        echo str_repeat('=', 64) . PHP_EOL;
        return $this->failed === 0 ? 0 : 1;
    }
}

// ---------------------------------------------------------------------------

$base = rtrim($argv[1] ?? 'http://localhost:8080', '/');
echo "Testing $base ...\n";
$t = new ApiTester($base);

// Unique test account so repeated runs never collide.
$email = 'qa+' . substr(bin2hex(random_bytes(5)), 0, 10) . '@example.com';
$password = 'Secret!123';
$token = null;

/**
 * Image fixtures for the child photo tests.
 *
 * GD is not available in this PHP build, so real images are embedded. The PNG
 * and JPEG below are valid 1x1 files; `oversizedPng()` builds a structurally
 * valid PNG header that claims a huge canvas without needing an encoder.
 */
function pngFixture(): string
{
    return (string) base64_decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
        true
    );
}

function jpegFixture(): string
{
    return (string) base64_decode(
        '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0a'
        . 'HBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/wAALCAABAAEBAREA/8QAFAABAAAAAAAA'
        . 'AAAAAAAAAAAACf/EABQQAQAAAAAAAAAAAAAAAAAAAAD/2gAIAQEAAD8AKp//2Q==',
        true
    );
}

/** A PNG whose IHDR claims $width x $height - used to trip the dimension cap. */
function oversizedPng(int $width, int $height): string
{
    $chunk = static function (string $type, string $data): string {
        return pack('N', strlen($data)) . $type . $data . pack('N', crc32($type . $data));
    };

    // 8-bit RGB
    $ihdr = pack('NN', $width, $height) . chr(8) . chr(2) . chr(0) . chr(0) . chr(0);

    return "\x89PNG\r\n\x1a\n" . $chunk('IHDR', $ihdr) . $chunk('IEND', '');
}

/**
 * PHP caches stat results, so a file deleted by a *separate* HTTP request would
 * still look present. Always clear the cache before asserting on disk state.
 */
function uploadExists(string $uploadsRoot, string $name): bool
{
    $path = $uploadsRoot . '/' . $name;
    clearstatcache(true, $path);

    return is_file($path);
}

// ---------------------------------------------------------------------------
// Health
// ---------------------------------------------------------------------------
$t->section('Health');
$r = $t->request('GET', '/api/health');
$t->assertStatus('GET /api/health', $r, 200);
$t->assertSuccess('GET /api/health', $r);

// ---------------------------------------------------------------------------
// Auth
// ---------------------------------------------------------------------------
$t->section('Authentication');

$r = $t->request('POST', '/api/auth/register', [
    'fullName' => 'QA Tester', 'email' => $email, 'phone' => '+1 555 000 111',
    'password' => $password, 'password_confirmation' => $password,
]);
$t->assertStatus('register valid -> 201', $r, 201);
$t->assertHas('register returns token', $r, 'token');
$t->assertHas('register returns user', $r, 'user');
$token = $r['body']['data']['token'] ?? null;
$t->check('register user email matches', ($r['body']['data']['user']['email'] ?? '') === $email);

$r = $t->request('POST', '/api/auth/register', [
    'fullName' => 'QA Tester', 'email' => $email,
    'password' => $password, 'password_confirmation' => $password,
]);
$t->assertStatus('register duplicate email -> 409', $r, 409);

$r = $t->request('POST', '/api/auth/register', [
    'fullName' => '', 'email' => 'not-an-email', 'password' => '123', 'password_confirmation' => '456',
]);
$t->assertStatus('register validation -> 422', $r, 422);
$t->assertBodyHas('validation errors object', $r, 'errors');

$r = $t->request('POST', '/api/auth/login', ['email' => $email, 'password' => $password]);
$t->assertStatus('login valid -> 200', $r, 200);
$t->assertHas('login returns token', $r, 'token');

$r = $t->request('POST', '/api/auth/login', ['email' => $email, 'password' => 'wrong-password']);
$t->assertStatus('login wrong password -> 401', $r, 401);
$r2 = $t->request('POST', '/api/auth/login', ['email' => 'nobody@example.com', 'password' => 'wrong-password']);
$t->assertStatus('login unknown email -> 401', $r2, 401);
$t->check('login error does not leak account existence', ($r['body']['message'] ?? '') === ($r2['body']['message'] ?? ''));

$r = $t->request('GET', '/api/auth/me', token: $token);
$t->assertStatus('me with token -> 200', $r, 200);
$t->check('me returns full name', ($r['body']['data']['fullName'] ?? '') === 'QA Tester');

$r = $t->request('GET', '/api/auth/me');
$t->assertStatus('me without token -> 401', $r, 401);
$r = $t->request('GET', '/api/auth/me', token: 'invalid-token-value');
$t->assertStatus('me with invalid token -> 401', $r, 401);

$r = $t->request('POST', '/api/auth/logout', token: $token);
$t->assertStatus('logout -> 200', $r, 200);
$r = $t->request('GET', '/api/auth/me', token: $token);
$t->assertStatus('me after logout -> 401', $r, 401);

// Re-login so subsequent tests have a live token.
$r = $t->request('POST', '/api/auth/login', ['email' => $email, 'password' => $password]);
$token = $r['body']['data']['token'] ?? null;

// ---------------------------------------------------------------------------
// Parent + children CRUD
// ---------------------------------------------------------------------------
$t->section('Parent / children');

$r = $t->request('GET', '/api/parent/profile', token: $token);
$t->assertStatus('GET profile -> 200', $r, 200);

$r = $t->request('PUT', '/api/parent/profile', ['fullName' => 'QA Tester Updated', 'phone' => '+1 555 999 888'], $token);
$t->assertStatus('PUT profile -> 200', $r, 200);
$t->check('profile updated name persisted', ($r['body']['data']['fullName'] ?? '') === 'QA Tester Updated');

$r = $t->request('GET', '/api/parent/children', token: $token);
$t->assertStatus('GET children -> 200', $r, 200);
$t->assertHas('children returns items', $r, 'items');

$r = $t->request('POST', '/api/parent/children', [
    'name' => 'Test Kid', 'age' => 8, 'grade' => 'Grade 3', 'school' => 'QA Elementary',
    'avatarKey' => 'sunshine', 'pin' => '1234', 'coins' => 0, 'streakDays' => 0,
], $token);
$t->assertStatus('create child -> 201', $r, 201);
$childId = $r['body']['data']['id'] ?? null;
$t->check('child id returned', $childId !== null && $childId !== '');

$r = $t->request('POST', '/api/parent/children', ['name' => '', 'age' => 300, 'pin' => 'ab'], $token);
$t->assertStatus('create child invalid -> 422', $r, 422);

$r = $t->request('GET', '/api/parent/children/' . $childId, token: $token);
$t->assertStatus('GET child -> 200', $r, 200);

$r = $t->request('PUT', '/api/parent/children/' . $childId, ['name' => 'Test Kid 2', 'age' => 9], $token);
$t->assertStatus('update child -> 200', $r, 200);
$t->check('child name updated', ($r['body']['data']['name'] ?? '') === 'Test Kid 2');

// ---------------------------------------------------------------------------
$t->section('Child profile rules (age 4-14, Grade 1-9, About child)');

$newKid = static function (array $payload) use ($t, $token) {
    return $t->request(
        'POST',
        '/api/parent/children',
        $payload + ['name' => 'Rules Kid', 'pin' => '1234'],
        $token
    );
};

// --- Age must be 4-14 -----------------------------------------------------
foreach ([3 => false, 4 => true, 10 => true, 14 => true, 15 => false, 0 => false] as $age => $allowed) {
    $r = $newKid(['age' => $age, 'grade' => 'Grade 2']);
    $t->assertStatus(
        'create child with age ' . $age . ($allowed ? ' accepted' : ' rejected'),
        $r,
        $allowed ? 201 : 422
    );
}

$r = $newKid(['age' => 7, 'grade' => 'Grade 2', 'aboutChild' => 'Loves painting']);
$t->assertStatus('create child with about child -> 201', $r, 201);
$t->assertEqual('about child round-trips', 'Loves painting', $r['body']['data']['aboutChild'] ?? null);
$t->check('school is no longer part of the child payload', !array_key_exists('school', $r['body']['data'] ?? []));

// --- Grade must be Grade 1-9 ---------------------------------------------
foreach (['Grade 1', 'Grade 5', 'Grade 9'] as $grade) {
    $r = $newKid(['age' => 8, 'grade' => $grade]);
    $t->assertStatus('create child with ' . $grade . ' -> 201', $r, 201);
}

foreach (['Grade 0', 'Grade 10', 'Grade 99', 'Kindergarten', 'grade 0', '0', ''] as $grade) {
    $r = $newKid(['age' => 8, 'grade' => $grade]);
    $t->assertStatus(
        'create child with grade "' . $grade . '" rejected',
        $r,
        422
    );
}

// Shorthand a parent is likely to type is normalized to the canonical label.
foreach ([['grade 3', 'Grade 3'], ['3', 'Grade 3'], ['g4', 'Grade 4'], [' 7 ', 'Grade 7'], ['GRADE 9', 'Grade 9']] as [$input, $expected]) {
    $r = $newKid(['age' => 8, 'grade' => $input]);
    $t->assertStatus('create child with shorthand grade "' . trim($input) . '" -> 201', $r, 201);
    $t->assertEqual('grade "' . trim($input) . '" normalized', $expected, $r['body']['data']['grade'] ?? null);
}

// Grade is required.
$r = $newKid(['age' => 8]);
$t->assertStatus('create child without grade -> 422', $r, 422);

// --- Update validation ---------------------------------------------------
$r = $t->request('PUT', '/api/parent/children/' . $childId, ['age' => 15], $token);
$t->assertStatus('update age to 15 -> 422', $r, 422);
$r = $t->request('PUT', '/api/parent/children/' . $childId, ['age' => 3], $token);
$t->assertStatus('update age to 3 -> 422', $r, 422);
$r = $t->request('PUT', '/api/parent/children/' . $childId, ['age' => 9], $token);
$t->assertStatus('update age to 9 -> 200', $r, 200);

$r = $t->request('PUT', '/api/parent/children/' . $childId, ['grade' => 'Grade 10'], $token);
$t->assertStatus('update grade to Grade 10 -> 422', $r, 422);
$r = $t->request('PUT', '/api/parent/children/' . $childId, ['grade' => 'Grade 0'], $token);
$t->assertStatus('update grade to Grade 0 -> 422', $r, 422);
$r = $t->request('PUT', '/api/parent/children/' . $childId, ['grade' => 'Kindergarten'], $token);
$t->assertStatus('update grade to Kindergarten -> 422', $r, 422);
$r = $t->request('PUT', '/api/parent/children/' . $childId, ['grade' => 'Grade 6'], $token);
$t->assertStatus('update grade to Grade 6 -> 200', $r, 200);
$t->assertEqual('grade updated', 'Grade 6', $r['body']['data']['grade'] ?? null);

// A partial update must not silently reset the fields it does not mention.
// Uses its own child so the shared fixture keeps its coin balance.
$partial = $newKid(['age' => 8, 'grade' => 'Grade 3', 'coins' => 0]);
$partialId = $partial['body']['data']['id'] ?? null;
$r = $t->request('PUT', '/api/parent/children/' . $partialId, ['coins' => 42, 'streakDays' => 7], $token);
$t->assertStatus('partial update -> 200', $r, 200);
$t->assertEqual('partial update keeps grade', 'Grade 3', $r['body']['data']['grade'] ?? null);
$t->assertEqual('partial update keeps age', 8, $r['body']['data']['age'] ?? null);
$t->assertEqual('partial update keeps coins', 42, $r['body']['data']['coins'] ?? null);
$t->assertEqual('partial update keeps streak', 7, $r['body']['data']['streakDays'] ?? null);
$t->assertEqual('partial update keeps avatar', 'sunshine', $r['body']['data']['avatarKey'] ?? null);
$t->request('DELETE', '/api/parent/children/' . $partialId, token: $token);

// ---------------------------------------------------------------------------
$t->section('Child PIN login + hashing');

$pinKid = $newKid([
    'age' => 8, 'grade' => 'Grade 2', 'pin' => '2468',
    'securityQuestions' => [['questionKey' => 'favorite_color', 'answer' => 'Green']],
]);
$pinKidId = $pinKid['body']['data']['id'] ?? null;
$t->check('hasPin reported for a child with a PIN', ($pinKid['body']['data']['hasPin'] ?? false) === true);
$t->check('pin value never returned', !array_key_exists('pin', $pinKid['body']['data'] ?? []));

$r = $t->request('POST', '/api/auth/child-login', ['childId' => $pinKidId, 'pin' => '1111']);
$t->assertStatus('child login wrong PIN -> 401', $r, 401);
$r = $t->request('POST', '/api/auth/child-login', ['childId' => $pinKidId, 'pin' => '2468']);
$t->assertStatus('child login correct PIN -> 200', $r, 200);
$childToken = $r['body']['data']['token'] ?? null;
$t->check('child login issues a session token', is_string($childToken) && $childToken !== '');

// A profile with no PIN at all must not be reachable by guessing.
$noPinKid = $t->request(
    'POST',
    '/api/parent/children',
    ['name' => 'No Pin Kid', 'age' => 7, 'grade' => 'Grade 1', 'pin' => '9999'],
    $token
);
$t->assertStatus('setup child for no-PIN check -> 201', $noPinKid, 201);
$noPinId = $noPinKid['body']['data']['id'] ?? null;
if (!isset($pdo) || $pdo === null) {
    $pdo = new PDO('mysql:host=127.0.0.1;dbname=smart_child_hub;charset=utf8mb4', 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
}
$stmt = $pdo->prepare('UPDATE children SET pin = \'\', pin_hash = NULL WHERE id = ?');
$stmt->execute([$noPinId]);
$r = $t->request('POST', '/api/auth/child-login', ['childId' => $noPinId, 'pin' => '0000']);
$t->assertStatus('child login for a child without a PIN -> 403', $r, 403);

// ---------------------------------------------------------------------------
$t->section('Child security questions (parent setup)');

$questionsPayload = [
    'name' => 'Recovery Kid',
    'age' => 9,
    'grade' => 'Grade 4',
    'aboutChild' => 'Loves soccer',
    'pin' => '1357',
    'securityQuestions' => [
        ['questionKey' => 'favorite_animal', 'answer' => 'Blue the parrot'],
        ['questionKey' => 'favorite_food', 'answer' => 'Pancakes'],
    ],
];
$r = $t->request('POST', '/api/parent/children', $questionsPayload, $token);
$t->assertStatus('create child with security questions -> 201', $r, 201);
$recoverKidId = $r['body']['data']['id'] ?? null;
$t->assertEqual(
    'question keys returned on create',
    ['favorite_animal', 'favorite_food'],
    $r['body']['data']['securityQuestions'] ?? null
);
$t->check('answers never returned', !str_contains(json_encode($r['body']['data'] ?? []), 'Blue the parrot'));

$r = $t->request('GET', '/api/parent/children/' . $recoverKidId . '/security-questions', token: $token);
$t->assertStatus('read security questions -> 200', $r, 200);
$t->assertEqual('question keys readable by parent', 2, $r['body']['data']['count'] ?? null);
$t->check('question text returned', str_contains(json_encode($r['body']['data'] ?? []), 'favorite animal'));
$t->check('answer hash never returned', !str_contains(json_encode($r['body']['data'] ?? []), '$2y$'));

// Rejects unusable configurations.
$r = $t->request('POST', '/api/parent/children', [
    'name' => 'Bad Q', 'age' => 8, 'grade' => 'Grade 1', 'pin' => '1234',
    'securityQuestions' => [['questionKey' => 'not_a_question', 'answer' => 'x']],
], $token);
$t->assertStatus('unknown security question -> 422', $r, 422);
$r = $t->request('POST', '/api/parent/children', [
    'name' => 'Bad Q', 'age' => 8, 'grade' => 'Grade 1', 'pin' => '1234',
    'securityQuestions' => [
        ['questionKey' => 'favorite_food', 'answer' => 'Pancakes'],
        ['questionKey' => 'favorite_food', 'answer' => 'Waffles'],
    ],
], $token);
$t->assertStatus('duplicate security question -> 422', $r, 422);
$r = $t->request('POST', '/api/parent/children', [
    'name' => 'Bad Q', 'age' => 8, 'grade' => 'Grade 1', 'pin' => '1234',
    'securityQuestions' => [['questionKey' => 'favorite_food', 'answer' => 'a']],
], $token);
$t->assertStatus('one-character answer -> 422', $r, 422);
$r = $t->request('POST', '/api/parent/children', [
    'name' => 'Bad Q', 'age' => 8, 'grade' => 'Grade 1', 'pin' => '1234',
    'securityQuestions' => [
        ['questionKey' => 'favorite_food', 'answer' => 'a'],
        ['questionKey' => 'pet_name', 'answer' => 'b'],
        ['questionKey' => 'birth_city', 'answer' => 'c'],
    ],
], $token);
$t->assertStatus('more than two security questions -> 422', $r, 422);

// ---------------------------------------------------------------------------
$t->section('Child PIN recovery (security questions)');

// A second child proves recovery can never spill across profiles.
$sibling = $newKid(['age' => 6, 'grade' => 'Grade 1', 'pin' => '5678', 'name' => 'Sibling Kid']);
$siblingId = $sibling['body']['data']['id'] ?? null;

// Identifying information must match.
$r = $t->request('POST', '/api/auth/child-recovery/questions', ['childId' => $recoverKidId, 'name' => 'Someone Else']);
$t->assertStatus('recovery questions with wrong name -> 404', $r, 404);
$r = $t->request('POST', '/api/auth/child-recovery/questions', ['childId' => $recoverKidId]);
$t->assertStatus('recovery questions without a name -> 400', $r, 400);

$r = $t->request('POST', '/api/auth/child-recovery/questions', ['childId' => $recoverKidId, 'name' => 'recovery kid']);
$t->assertStatus('recovery questions for known child -> 200', $r, 200);
$t->assertEqual('both questions offered', 2, count($r['body']['data']['questions'] ?? []));

// A child with no questions configured cannot recover.
$r = $t->request('POST', '/api/auth/child-recovery/questions', ['childId' => $siblingId, 'name' => 'Sibling Kid']);
$t->assertStatus('recovery questions for a child without any -> 400', $r, 400);

// A child session may only recover itself.
$r = $t->request('POST', '/api/auth/child-recovery/questions', ['childId' => $siblingId, 'name' => 'Sibling Kid'], $childToken);
$t->assertStatus('child session cannot recover a sibling -> 404', $r, 404);
$r = $t->request('POST', '/api/auth/child-recovery/questions', ['childId' => $childId, 'name' => 'Test Kid 2'], $childToken);
$t->assertStatus('child session cannot recover another child -> 404', $r, 404);
$r = $t->request('POST', '/api/auth/child-recovery/questions', ['childId' => $pinKidId, 'name' => 'Rules Kid'], $childToken);
$t->assertStatus('child session can start recovery for itself -> 200', $r, 200);

// Wrong answers are rejected and never echo the stored answer.
$r = $t->request('POST', '/api/auth/child-recovery/verify', [
    'childId' => $recoverKidId,
    'name'    => 'Recovery Kid',
    'answers' => [
        ['questionKey' => 'favorite_animal', 'answer' => 'Wrong guess'],
        ['questionKey' => 'favorite_food', 'answer' => 'Pancakes'],
    ],
]);
$t->assertStatus('recovery verify wrong answer -> 400', $r, 400);
$t->check('wrong answer gives no token', !isset($r['body']['data']['recoveryToken']));

// A partial answer set is rejected.
$r = $t->request('POST', '/api/auth/child-recovery/verify', [
    'childId' => $recoverKidId,
    'name'    => 'Recovery Kid',
    'answers' => [['questionKey' => 'favorite_animal', 'answer' => 'Blue the parrot']],
]);
$t->assertStatus('recovery verify missing one answer -> 400', $r, 400);

// Correct answers (case/whitespace insensitive) hand back a recovery token.
$r = $t->request('POST', '/api/auth/child-recovery/verify', [
    'childId' => $recoverKidId,
    'name'    => 'Recovery Kid',
    'answers' => [
        ['questionKey' => 'favorite_animal', 'answer' => '  blue THE parrot '],
        ['questionKey' => 'favorite_food', 'answer' => 'pancakes'],
    ],
]);
$t->assertStatus('recovery verify correct answers -> 200', $r, 200);
$recoveryToken = $r['body']['data']['recoveryToken'] ?? null;
$t->check('recovery token issued', is_string($recoveryToken) && $recoveryToken !== '');
$t->assertEqual('recovery token is bound to the child', $recoverKidId, $r['body']['data']['childId'] ?? null);

// The new PIN must be confirmed.
$r = $t->request('POST', '/api/auth/child-recovery/reset', [
    'recoveryToken' => $recoveryToken, 'newPin' => '7788', 'newPinConfirmation' => '9999',
]);
$t->assertStatus('recovery reset mismatched confirmation -> 400', $r, 400);
$r = $t->request('POST', '/api/auth/child-recovery/reset', [
    'recoveryToken' => $recoveryToken, 'newPin' => '77', 'newPinConfirmation' => '77',
]);
$t->assertStatus('recovery reset non 4-digit PIN -> 422', $r, 422);
$r = $t->request('POST', '/api/auth/child-recovery/reset', [
    'recoveryToken' => 'a-token-that-was-never-issued', 'newPin' => '7788', 'newPinConfirmation' => '7788',
]);
$t->assertStatus('recovery reset with a bogus token -> 400', $r, 400);

// Capture the sibling PIN hash so we can prove it is untouched afterwards.
$stmt = $pdo->prepare('SELECT pin_hash FROM children WHERE id = ?');
$stmt->execute([$siblingId]);
$siblingHashBefore = (string) ($stmt->fetch()['pin_hash'] ?? '');

$r = $t->request('POST', '/api/auth/child-recovery/reset', [
    'recoveryToken' => $recoveryToken, 'newPin' => '7788', 'newPinConfirmation' => '7788',
]);
$t->assertStatus('recovery reset valid token -> 200', $r, 200);

$r = $t->request('POST', '/api/auth/child-login', ['childId' => $recoverKidId, 'pin' => '1357']);
$t->assertStatus('old PIN rejected after recovery -> 401', $r, 401);
$r = $t->request('POST', '/api/auth/child-login', ['childId' => $recoverKidId, 'pin' => '7788']);
$t->assertStatus('new PIN accepted after recovery -> 200', $r, 200);

// The recovery token is single use.
$r = $t->request('POST', '/api/auth/child-recovery/reset', [
    'recoveryToken' => $recoveryToken, 'newPin' => '6644', 'newPinConfirmation' => '6644',
]);
$t->assertStatus('recovery token cannot be reused -> 400', $r, 400);

// Only the recovered child's credential changed.
$stmt = $pdo->prepare('SELECT pin_hash FROM children WHERE id = ?');
$stmt->execute([$siblingId]);
$siblingHashAfter = (string) ($stmt->fetch()['pin_hash'] ?? '');
$t->check('sibling PIN untouched by another child recovery', $siblingHashBefore === $siblingHashAfter);
$r = $t->request('POST', '/api/auth/child-login', ['childId' => $siblingId, 'pin' => '5678']);
$t->assertStatus('sibling still logs in with its own PIN -> 200', $r, 200);

// Another parent cannot reach into this family's recovery flow.
$outsider = $t->request('POST', '/api/auth/register', [
    'fullName' => 'Recovery Outsider',
    'email'    => 'outsider+' . substr(bin2hex(random_bytes(5)), 0, 10) . '@example.com',
    'password' => 'Outsider!123', 'password_confirmation' => 'Outsider!123',
]);
$outsiderToken = $outsider['body']['data']['token'] ?? null;
$r = $t->request('POST', '/api/auth/child-recovery/questions', ['childId' => $recoverKidId, 'name' => 'Recovery Kid'], $outsiderToken);
$t->assertStatus('other parent cannot start recovery for this child -> 404', $r, 404);

// Without any token the same request is refused for lack of identifying info.
$r = $t->request('POST', '/api/auth/child-recovery/questions', ['childId' => $recoverKidId]);
$t->assertStatus('anonymous recovery without a name -> 400', $r, 400);

// ---------------------------------------------------------------------------
$t->section('Child recovery hashing + lockout (DB assertions)');

$stmt = $pdo->prepare('SELECT question_key, answer_hash FROM child_security_questions WHERE child_id = ? ORDER BY sort_order');
$stmt->execute([$recoverKidId]);
$questionRows = $stmt->fetchAll();
$t->assertEqual('questions stored', 2, count($questionRows));
foreach ($questionRows as $row) {
    $t->check(
        'answer for ' . $row['question_key'] . ' stored as a bcrypt hash',
        str_starts_with((string) $row['answer_hash'], '$2y$')
    );
    $t->check('answer hash for ' . $row['question_key'] . ' is not reversible', !str_contains((string) $row['answer_hash'], 'arrot'));
}

$stmt = $pdo->prepare('SELECT pin, pin_hash FROM children WHERE id = ?');
$stmt->execute([$recoverKidId]);
$storedPin = $stmt->fetch() ?: [];
$t->check('PIN no longer stored in plain text after recovery', (string) ($storedPin['pin'] ?? 'x') === '');
$t->check('PIN stored as a bcrypt hash', str_starts_with((string) ($storedPin['pin_hash'] ?? ''), '$2y$'));

$stmt = $pdo->prepare('SELECT token_hash FROM child_pin_recovery_tokens WHERE child_id = ?');
$stmt->execute([$recoverKidId]);
$tokenHashes = array_column($stmt->fetchAll(), 'token_hash');
$t->check('recovery token stored hashed (64 hex chars)', $tokenHashes !== [] && strlen((string) $tokenHashes[0]) === 64);
$t->check('raw recovery token never stored', !in_array($recoveryToken, $tokenHashes, true));

// Brute-force protection: a fresh child locks out after 5 wrong answers.
$lockKid = $t->request('POST', '/api/parent/children', [
    'name' => 'Lock Kid', 'age' => 8, 'grade' => 'Grade 3', 'pin' => '2468',
    'securityQuestions' => [['questionKey' => 'pet_name', 'answer' => 'Rex']],
], $token);
$lockKidId = $lockKid['body']['data']['id'] ?? null;

$lockedStatus = 400;
$maxAttempts = 5; // Config::CHILD_RECOVERY_MAX_ATTEMPTS
for ($attempt = 1; $attempt <= $maxAttempts; $attempt++) {
    $r = $t->request('POST', '/api/auth/child-recovery/verify', [
        'childId' => $lockKidId,
        'name'    => 'Lock Kid',
        'answers' => [['questionKey' => 'pet_name', 'answer' => 'Wrong ' . $attempt]],
    ]);
    $lockedStatus = $r['status'];
}
$t->check(
    'wrong answers rejected while under the attempt limit',
    $lockedStatus === 400,
    'got ' . $lockedStatus
);

// The next attempt - correct or not - is locked out.
$r = $t->request('POST', '/api/auth/child-recovery/verify', [
    'childId' => $lockKidId,
    'name'    => 'Lock Kid',
    'answers' => [['questionKey' => 'pet_name', 'answer' => 'Rex']],
]);
$t->assertStatus('correct answer blocked while locked out -> 429', $r, 429);

$stmt = $pdo->prepare('UPDATE children SET recovery_failed_attempts = 0, recovery_locked_until = NULL WHERE id = ?');
$stmt->execute([$lockKidId]);
$r = $t->request('POST', '/api/auth/child-recovery/verify', [
    'childId' => $lockKidId,
    'name'    => 'Lock Kid',
    'answers' => [['questionKey' => 'pet_name', 'answer' => 'Rex']],
]);
$t->assertStatus('correct answer works once the lockout clears -> 200', $r, 200);

// ---------------------------------------------------------------------------
$t->section('Child PIN change (parent)');

$r = $t->request('PUT', '/api/parent/children/' . $siblingId . '/pin', [
    'currentPin' => '0000', 'newPin' => '8642', 'newPinConfirmation' => '8642',
], $token);
$t->assertStatus('change PIN with wrong current PIN -> 400', $r, 400);
$r = $t->request('PUT', '/api/parent/children/' . $siblingId . '/pin', [
    'currentPin' => '5678', 'newPin' => '8642', 'newPinConfirmation' => '1234',
], $token);
$t->assertStatus('change PIN with mismatched confirmation -> 400', $r, 400);
$r = $t->request('PUT', '/api/parent/children/' . $siblingId . '/pin', [
    'currentPin' => '5678', 'newPin' => '8642', 'newPinConfirmation' => '8642',
], $token);
$t->assertStatus('change PIN valid -> 200', $r, 200);
$r = $t->request('POST', '/api/auth/child-login', ['childId' => $siblingId, 'pin' => '8642']);
$t->assertStatus('login with the parent-changed PIN -> 200', $r, 200);

// ---------------------------------------------------------------------------
// Activities CRUD + coin awards
// ---------------------------------------------------------------------------
$t->section('Activities (with coin awards)');

$r = $t->request('GET', '/api/children/' . $childId . '/activities', token: $token);
$t->assertStatus('GET activities -> 200', $r, 200);

$coinsBefore = 0;
$r = $t->request('POST', '/api/children/' . $childId . '/activities', [
    'title' => 'Brush teeth', 'icon' => 'sparkle', 'category' => 'Routine',
    'time' => '7:00 AM', 'coins' => 5, 'status' => 'completed', 'date' => date('Y-m-d'),
], $token);
$t->assertStatus('create activity -> 201', $r, 201);
$activityId = $r['body']['data']['id'] ?? null;

$r = $t->request('GET', '/api/parent/children/' . $childId, token: $token);
$coinsAfter = (int) ($r['body']['data']['coins'] ?? 0);
$t->check('coins awarded on completed activity creation', $coinsAfter - $coinsBefore === 5, "delta=" . ($coinsAfter - $coinsBefore));

$r = $t->request('POST', '/api/children/' . $childId . '/activities', [
    'title' => 'Pending task', 'coins' => 10, 'status' => 'pending', 'date' => date('Y-m-d'),
], $token);
$pendingId = $r['body']['data']['id'] ?? null;
$t->assertStatus('create pending activity -> 201', $r, 201);

$r = $t->request('PUT', '/api/children/' . $childId . '/activities/' . $pendingId, ['status' => 'completed'], $token);
$t->assertStatus('update activity to completed -> 200', $r, 200);
$r = $t->request('GET', '/api/parent/children/' . $childId, token: $token);
$coinsAfter2 = (int) ($r['body']['data']['coins'] ?? 0);
$t->check('coins awarded on transition to completed', $coinsAfter2 - $coinsAfter === 10, "delta=" . ($coinsAfter2 - $coinsAfter));

$r = $t->request('PUT', '/api/children/' . $childId . '/activities/' . $pendingId, ['status' => 'completed'], $token);
$r = $t->request('GET', '/api/parent/children/' . $childId, token: $token);
$coinsAfter3 = (int) ($r['body']['data']['coins'] ?? 0);
$t->check('no double coin award on repeated completion', $coinsAfter3 === $coinsAfter2, "delta=" . ($coinsAfter3 - $coinsAfter2));

$r = $t->request('GET', '/api/children/' . $childId . '/activities?date=' . date('Y-m-d'), token: $token);
$t->assertStatus('GET activities filtered by date -> 200', $r, 200);

$r = $t->request('GET', '/api/children/' . $childId . '/activities/' . $activityId, token: $token);
$t->assertStatus('GET activity by id -> 200', $r, 200);

$r = $t->request('POST', '/api/children/' . $childId . '/activities', [
    'title' => str_repeat('x', 161), 'coins' => -1, 'status' => 'bogus', 'date' => 'not-a-date',
], $token);
$t->assertStatus('create activity invalid -> 422', $r, 422);

$r = $t->request('DELETE', '/api/children/' . $childId . '/activities/' . $activityId, token: $token);
$t->assertStatus('delete activity -> 204', $r, 204);
$r = $t->request('GET', '/api/children/' . $childId . '/activities/' . $activityId, token: $token);
$t->assertStatus('GET deleted activity -> 404', $r, 404);

// ---------------------------------------------------------------------------
// Sleep (upsert)
// ---------------------------------------------------------------------------
$t->section('Sleep (upsert)');
$r = $t->request('POST', '/api/children/' . $childId . '/sleep', [
    'date' => date('Y-m-d'), 'bedtimeHour' => 21, 'bedtimeMinute' => 0,
    'wakeHour' => 7, 'wakeMinute' => 30, 'hours' => 9.5, 'quality' => 'restful', 'notes' => 'Test',
], $token);
$t->assertStatus('create sleep -> 201', $r, 201);
$sleepId = $r['body']['data']['id'] ?? null;

$r = $t->request('POST', '/api/children/' . $childId . '/sleep', [
    'date' => date('Y-m-d'), 'bedtimeHour' => 21, 'bedtimeMinute' => 15,
    'wakeHour' => 7, 'wakeMinute' => 15, 'hours' => 9.0, 'quality' => 'good',
], $token);
$t->assertStatus('sleep upsert same date -> 200', $r, 200);
$t->check('sleep upsert updates same row', ($r['body']['data']['id'] ?? '') === $sleepId);
$t->check('sleep upsert updates hours', ($r['body']['data']['hours'] ?? 0) == 9.0);

$r = $t->request('POST', '/api/children/' . $childId . '/sleep', [
    'date' => date('Y-m-d'), 'bedtimeHour' => 25, 'quality' => 'alien', 'hours' => 30,
], $token);
$t->assertStatus('create sleep invalid -> 422', $r, 422);

$r = $t->request('GET', '/api/children/' . $childId . '/sleep', token: $token);
$t->assertStatus('GET sleep -> 200', $r, 200);

$r = $t->request('PUT', '/api/sleep/' . $sleepId, ['hours' => 10.5, 'quality' => 'poor'], $token);
$t->assertStatus('update sleep -> 200', $r, 200);
$t->check('sleep update persisted', ($r['body']['data']['hours'] ?? 0) == 10.5);

$r = $t->request('DELETE', '/api/sleep/' . $sleepId, token: $token);
$t->assertStatus('delete sleep -> 204', $r, 204);

// ---------------------------------------------------------------------------
// Meals
// ---------------------------------------------------------------------------
$t->section('Meals');
$r = $t->request('POST', '/api/children/' . $childId . '/meals', [
    'date' => date('Y-m-d'), 'type' => 'breakfast', 'name' => 'Oatmeal', 'icon' => 'sun',
    'time' => '7:45 AM', 'calories' => 260, 'protein' => 9, 'carbs' => 42, 'fat' => 4, 'eaten' => true,
], $token);
$t->assertStatus('create meal -> 201', $r, 201);
$mealId = $r['body']['data']['id'] ?? null;

$r = $t->request('POST', '/api/children/' . $childId . '/meals', ['date' => date('Y-m-d'), 'type' => 'midnight-snack'], $token);
$t->assertStatus('create meal invalid -> 422', $r, 422);

$r = $t->request('GET', '/api/children/' . $childId . '/meals', token: $token);
$t->assertStatus('GET meals -> 200', $r, 200);

$r = $t->request('PUT', '/api/meals/' . $mealId, ['eaten' => false], $token);
$t->assertStatus('update meal -> 200', $r, 200);
$t->check('meal eaten updated', ($r['body']['data']['eaten'] ?? null) === false);

$r = $t->request('DELETE', '/api/meals/' . $mealId, token: $token);
$t->assertStatus('delete meal -> 204', $r, 204);

// ---------------------------------------------------------------------------
// Water intake (glass log)
// ---------------------------------------------------------------------------
$t->section('Water intake');
$times = [date('Y-m-d') . 'T08:00:00', date('Y-m-d') . 'T09:30:00', date('Y-m-d') . 'T11:00:00'];
$r = $t->request('POST', '/api/children/' . $childId . '/water', [
    'date' => date('Y-m-d'), 'glasses' => 8, 'targetGlasses' => 8, 'glassTimes' => $times,
], $token);
$t->assertStatus('create water -> 201', $r, 201);
$waterId = $r['body']['data']['id'] ?? null;
$t->check('glass count synced to log', count($r['body']['data']['glassTimes'] ?? []) === 3);

$r = $t->request('GET', '/api/children/' . $childId . '/water?date=' . date('Y-m-d'), token: $token);
$t->assertStatus('GET water by date -> 200', $r, 200);
$t->check('glassTimes returned in list', count($r['body']['data'][0]['glassTimes'] ?? []) === 3);

$r = $t->request('PUT', '/api/water/' . $waterId, ['glasses' => 5, 'targetGlasses' => 10], $token);
$t->assertStatus('update water -> 200', $r, 200);
$t->check('water target updated', ($r['body']['data']['targetGlasses'] ?? 0) === 10);

$r = $t->request('DELETE', '/api/water/' . $waterId, token: $token);
$t->assertStatus('delete water -> 204', $r, 204);
$r = $t->request('GET', '/api/children/' . $childId . '/water?date=' . date('Y-m-d'), token: $token);
$t->check('water_glasses cascaded on delete', count($r['body']['data'] ?? []) === 0);

// ---------------------------------------------------------------------------
// Moods
// ---------------------------------------------------------------------------
$t->section('Moods');
$r = $t->request('POST', '/api/children/' . $childId . '/moods', [
    'date' => date('Y-m-d') . ' 09:00:00', 'mood' => 'happy', 'note' => 'Test mood',
], $token);
$t->assertStatus('create mood -> 201', $r, 201);
$moodId = $r['body']['data']['id'] ?? null;

$r = $t->request('POST', '/api/children/' . $childId . '/moods', ['date' => date('Y-m-d'), 'mood' => 'euphoric'], $token);
$t->assertStatus('create mood invalid -> 422', $r, 422);

$r = $t->request('GET', '/api/children/' . $childId . '/moods', token: $token);
$t->assertStatus('GET moods -> 200', $r, 200);

$r = $t->request('PUT', '/api/moods/' . $moodId, ['mood' => 'calm'], $token);
$t->assertStatus('update mood -> 200', $r, 200);
$t->check('mood updated', ($r['body']['data']['mood'] ?? '') === 'calm');

$r = $t->request('DELETE', '/api/moods/' . $moodId, token: $token);
$t->assertStatus('delete mood -> 204', $r, 204);

// ---------------------------------------------------------------------------
// Homework
// ---------------------------------------------------------------------------
$t->section('Homework');
$r = $t->request('POST', '/api/children/' . $childId . '/homework', [
    'title' => 'Math sheet', 'subject' => 'Math', 'icon' => 'book',
    'dueDate' => date('Y-m-d'), 'status' => 'pending', 'coins' => 10, 'progress' => 0.0,
], $token);
$t->assertStatus('create homework -> 201', $r, 201);
$hwId = $r['body']['data']['id'] ?? null;

$r = $t->request('POST', '/api/children/' . $childId . '/homework', ['title' => 'No subject'], $token);
$t->assertStatus('create homework missing subject -> 422', $r, 422);

$r = $t->request('GET', '/api/children/' . $childId . '/homework', token: $token);
$t->assertStatus('GET homework -> 200', $r, 200);

$r = $t->request('PUT', '/api/homework/' . $hwId, ['status' => 'completed', 'progress' => 1.0], $token);
$t->assertStatus('update homework -> 200', $r, 200);
$t->check('homework progress updated', ($r['body']['data']['progress'] ?? 0) == 1.0);

$r = $t->request('DELETE', '/api/homework/' . $hwId, token: $token);
$t->assertStatus('delete homework -> 204', $r, 204);

// ---------------------------------------------------------------------------
// Attendance (upsert)
// ---------------------------------------------------------------------------
$t->section('Attendance');
$r = $t->request('POST', '/api/children/' . $childId . '/attendance', [
    'date' => date('Y-m-d'), 'status' => 'present', 'className' => 'QA Class',
], $token);
$t->assertStatus('create attendance -> 201', $r, 201);
$attId = $r['body']['data']['id'] ?? null;

$r = $t->request('POST', '/api/children/' . $childId . '/attendance', [
    'date' => date('Y-m-d'), 'status' => 'late', 'className' => 'QA Class',
], $token);
$t->assertStatus('attendance upsert same date -> 200', $r, 200);
$t->check('attendance upsert updates status', ($r['body']['data']['status'] ?? '') === 'late');

$r = $t->request('DELETE', '/api/attendance/' . $attId, token: $token);
$t->assertStatus('delete attendance -> 204', $r, 204);

// ---------------------------------------------------------------------------
// Screen time (upsert)
// ---------------------------------------------------------------------------
$t->section('Screen time');
$r = $t->request('POST', '/api/children/' . $childId . '/screen-time', [
    'date' => date('Y-m-d'), 'allowedMinutes' => 60, 'usedMinutes' => 45, 'category' => 'Total',
], $token);
$t->assertStatus('create screen time -> 201', $r, 201);
$stId = $r['body']['data']['id'] ?? null;

$r = $t->request('POST', '/api/children/' . $childId . '/screen-time', [
    'date' => date('Y-m-d'), 'allowedMinutes' => 60, 'usedMinutes' => 55, 'category' => 'Total',
], $token);
$t->assertStatus('screen time upsert -> 200', $r, 200);
$t->check('screen time upsert updates used', ($r['body']['data']['usedMinutes'] ?? 0) === 55);

$r = $t->request('POST', '/api/children/' . $childId . '/screen-time', ['date' => date('Y-m-d'), 'usedMinutes' => 99999], $token);
$t->assertStatus('create screen time invalid -> 422', $r, 422);

$r = $t->request('DELETE', '/api/screen-time/' . $stId, token: $token);
$t->assertStatus('delete screen time -> 204', $r, 204);

// ---------------------------------------------------------------------------
// Notifications
// ---------------------------------------------------------------------------
$t->section('Notifications');
$r = $t->request('GET', '/api/notifications', token: $token, query: ['page' => 1, 'per_page' => 20]);
$t->assertStatus('GET notifications -> 200', $r, 200);
$t->assertHas('notifications items', $r, 'items');

$r = $t->request('GET', '/api/notifications/unread-count', token: $token);
$t->assertStatus('GET unread-count -> 200', $r, 200);
$t->assertHas('unread-count has unread', $r, 'unread');

$r = $t->request('POST', '/api/notifications', [
    'type' => 'activity', 'title' => 'QA notif', 'message' => 'Test message', 'read' => false,
], $token);
$t->assertStatus('create notification -> 201', $r, 201);
$notifId = $r['body']['data']['id'] ?? null;

$r = $t->request('POST', '/api/notifications', [
    'type' => 'activity', 'title' => 'QA notif 2', 'message' => 'Test message 2', 'childId' => '00000000-0000-0000-0000-000000000000',
], $token);
$t->assertStatus('create notification foreign child -> 404', $r, 404);

$r = $t->request('GET', '/api/notifications/' . $notifId, token: $token);
$t->assertStatus('GET notification by id -> 200', $r, 200);

$r = $t->request('PUT', '/api/notifications/' . $notifId, ['title' => 'QA notif updated'], $token);
$t->assertStatus('update notification -> 200', $r, 200);
$t->check('notification title updated', ($r['body']['data']['title'] ?? '') === 'QA notif updated');

$r = $t->request('PUT', '/api/notifications/' . $notifId . '/read', token: $token);
$t->assertStatus('mark notification read -> 200', $r, 200);
$t->check('notification read flag set', ($r['body']['data']['read'] ?? null) === true);

$r = $t->request('PUT', '/api/notifications/read-all', token: $token);
$t->assertStatus('mark all read -> 200', $r, 200);
$r = $t->request('GET', '/api/notifications/unread-count', token: $token);
$t->check('unread-count zero after read-all', ($r['body']['data']['unread'] ?? -1) === 0);

$r = $t->request('DELETE', '/api/notifications/' . $notifId, token: $token);
$t->assertStatus('delete notification -> 204', $r, 204);
$r = $t->request('GET', '/api/notifications/' . $notifId, token: $token);
$t->assertStatus('GET deleted notification -> 404', $r, 404);

// ---------------------------------------------------------------------------
// Reports
// ---------------------------------------------------------------------------
$t->section('Reports');
foreach (['daily', 'weekly', 'monthly'] as $type) {
    $r = $t->request('GET', "/api/children/$childId/reports/$type", token: $token);
    $t->assertStatus("GET $type report -> 200", $r, 200);
    $t->assertHas("$type report stats", $r, 'stats');
    $t->assertHas("$type report stats.tasksDone", $r, 'stats');
}
$r = $t->request('GET', '/api/children/' . $childId . '/reports/bogus', token: $token);
$t->assertStatus('GET invalid report type -> 422', $r, 422);

$r = $t->request('GET', '/api/children/' . $childId . '/reports/history', token: $token);
$t->assertStatus('GET report history -> 200', $r, 200);
$r = $t->request('GET', '/api/children/' . $childId . '/reports/history?type=weekly', token: $token);
$t->assertStatus('GET weekly history -> 200', $r, 200);

// ---------------------------------------------------------------------------
// Ownership / authorization
// ---------------------------------------------------------------------------
$t->section('Ownership & authorization');

// Second account to prove cross-tenant isolation.
$r = $t->request('POST', '/api/auth/register', [
    'fullName' => 'Other Parent', 'email' => 'other+' . substr(bin2hex(random_bytes(5)), 0, 10) . '@example.com',
    'password' => $password, 'password_confirmation' => $password,
]);
$otherToken = $r['body']['data']['token'] ?? null;
$r = $t->request('GET', '/api/parent/children', token: $otherToken);
$otherChildId = $r['body']['data']['items'][0]['id'] ?? null;
if ($otherChildId === null) {
    $r = $t->request('POST', '/api/parent/children', [
        'name' => 'Other Kid', 'age' => 6, 'grade' => 'Grade 1', 'pin' => '4321',
    ], $otherToken);
    $otherChildId = $r['body']['data']['id'] ?? null;
}

$r = $t->request('GET', '/api/parent/children/' . $otherChildId, token: $token);
$t->assertStatus('cross-parent child read -> 404', $r, 404);
$r = $t->request('PUT', '/api/parent/children/' . $otherChildId, ['name' => 'Hacked'], $token);
$t->assertStatus('cross-parent child update -> 404', $r, 404);
$r = $t->request('DELETE', '/api/parent/children/' . $otherChildId, token: $token);
$t->assertStatus('cross-parent child delete -> 404', $r, 404);
$r = $t->request('GET', '/api/children/' . $otherChildId . '/activities', token: $token);
$t->assertStatus('cross-parent activities list -> 404', $r, 404);
$r = $t->request('POST', '/api/children/' . $otherChildId . '/activities', ['title' => 'x'], $token);
$t->assertStatus('cross-parent activity create -> 404', $r, 404);
$r = $t->request('GET', '/api/children/' . $otherChildId . '/reports/daily', token: $token);
$t->assertStatus('cross-parent report -> 404', $r, 404);

// ---------------------------------------------------------------------------
// Child photos (upload / replace / remove)
// ---------------------------------------------------------------------------
$t->section('Child photos (upload / replace / remove)');

$photoPath = '/api/parent/children/' . $childId . '/photo';
$uploadsRoot = dirname(__DIR__) . '/public/uploads';
$pngBytes = pngFixture();

$r = $t->request('GET', '/api/parent/children/' . $childId, token: $token);
$t->assertEqual('child starts with an empty photoUrl', '', $r['body']['data']['photoUrl'] ?? null);

// --- happy path -------------------------------------------------------------
$r = $t->uploadPhoto($photoPath, 'avatar.png', $pngBytes, 'image/png', $token);
$t->assertStatus('upload photo -> 200', $r, 200);
$t->assertSuccess('upload photo', $r);
$photoUrl = (string) ($r['body']['data']['photoUrl'] ?? '');
$t->check('upload returns an absolute http(s) URL', str_starts_with($photoUrl, 'http://') || str_starts_with($photoUrl, 'https://'));
// A Windows or POSIX filesystem path must never reach the client.
$t->check(
    'upload URL never leaks a local path',
    !preg_match('#^[a-z]:[\\\\/]#i', $photoUrl) && !str_contains($photoUrl, '\\') && !str_starts_with($photoUrl, '/'),
    $photoUrl
);
$t->check('stored photo uses the verified .png extension', str_ends_with(strtolower($photoUrl), '.png'));

// The file must actually exist on disk and the URL must serve it back.
$storedName = basename((string) parse_url($photoUrl, PHP_URL_PATH));
$t->check('photo file written to the uploads directory', uploadExists($uploadsRoot, $storedName));
$fetched = $t->fetchRaw($photoUrl);
$t->assertStatus('uploaded photo is downloadable', $fetched, 200);
$t->assertEqual('served Content-Type matches the image', 'image/png', $fetched['headers']['content-type'] ?? '');
$t->check('served bytes are identical to the upload', $fetched['body'] === $pngBytes);
$t->check('served with X-Content-Type-Options: nosniff', ($fetched['headers']['x-content-type-options'] ?? '') === 'nosniff');

// --- persistence ------------------------------------------------------------
$r = $t->request('GET', '/api/parent/children/' . $childId, token: $token);
$t->assertEqual('photo persists across a fresh read', $photoUrl, $r['body']['data']['photoUrl'] ?? null);

// A normal profile edit must not disturb the stored photo.
$r = $t->request('PUT', '/api/parent/children/' . $childId, ['name' => 'Test Kid 2', 'age' => 9], $token);
$t->assertStatus('profile edit while a photo exists -> 200', $r, 200);
$t->assertEqual('profile edit preserves the photo', $photoUrl, $r['body']['data']['photoUrl'] ?? null);

// ...and it must not be possible to inject a URL through the update endpoint.
$r = $t->request('PUT', '/api/parent/children/' . $childId, [
    'name' => 'Test Kid 2', 'age' => 9, 'photoUrl' => 'https://evil.example.com/x.png',
], $token);
$t->assertStatus('update with an injected photoUrl -> 200', $r, 200);
$t->assertEqual('update cannot repoint the photo', $photoUrl, $r['body']['data']['photoUrl'] ?? null);
$r = $t->request('PUT', '/api/parent/children/' . $childId, [
    'name' => 'Test Kid 2', 'age' => 9, 'photoUrl' => '',
], $token);
$t->assertEqual('update cannot clear the photo', $photoUrl, $r['body']['data']['photoUrl'] ?? null);

// --- replacement ------------------------------------------------------------
$firstName = $storedName;
$jpegBytes = jpegFixture();
$r = $t->uploadPhoto($photoPath, 'avatar.jpg', $jpegBytes, 'image/jpeg', $token);
$t->assertStatus('replace photo -> 200', $r, 200);
$secondUrl = (string) ($r['body']['data']['photoUrl'] ?? '');
$t->check('replacement returns a different URL', $secondUrl !== '' && $secondUrl !== $photoUrl);
$t->check('replacement extension follows the real content type', str_ends_with(strtolower($secondUrl), '.jpg'));
$t->check('replaced file is stored', uploadExists($uploadsRoot, basename((string) parse_url($secondUrl, PHP_URL_PATH))));
$t->check('previous file is cleaned up on replace', !uploadExists($uploadsRoot, $firstName));
$t->check('old URL is no longer served', $t->fetchRaw($photoUrl)['status'] === 404);

// --- content validation -----------------------------------------------------
$r = $t->uploadPhoto($photoPath, 'avatar.png', 'this is definitely not an image', 'image/png', $token);
$t->assertStatus('text file disguised as .png -> 400', $r, 400);
$t->assertBodyHas('disguised file reports a photo error', $r, 'errors');

$r = $t->uploadPhoto($photoPath, 'payload.php', "<?php echo 'pwned'; ?>\n", 'image/png', $token);
$t->assertStatus('php script disguised as .png -> 400', $r, 400);
$t->check('php upload stores nothing', !str_contains((string) ($r['body']['data']['photoUrl'] ?? ''), 'payload.php'));

$r = $t->uploadPhoto($photoPath, 'script.svg', '<svg xmlns="http://www.w3.org/2000/svg"><script>alert(1)</script></svg>', 'image/svg+xml', $token);
$t->assertStatus('svg rejected -> 400', $r, 400);

$r = $t->uploadPhoto($photoPath, 'anim.gif', "GIF89a\x01\x00\x01\x00\x00\xff\x00,\x00\x00\x00\x00\x01\x00\x01\x00\x00\x02\x00;", 'image/gif', $token);
$t->assertStatus('gif rejected -> 400', $r, 400);

// A valid JPEG named .png must be stored with the extension derived from its
// real content, never from the client-supplied name.
$r = $t->uploadPhoto($photoPath, 'lies.png', $jpegBytes, 'image/png', $token);
$t->assertStatus('jpeg named .png still accepted -> 200', $r, 200);
$t->check('stored extension follows content, not the filename', str_ends_with(strtolower((string) ($r['body']['data']['photoUrl'] ?? '')), '.jpg'));
$mismatchUrl = (string) ($r['body']['data']['photoUrl'] ?? '');

// --- size limits ------------------------------------------------------------
$before = count(glob($uploadsRoot . '/*') ?: []);
$r = $t->uploadPhoto($photoPath, 'huge.png', str_repeat('x', 5 * 1024 * 1024 + 1024), 'image/png', $token);
$t->assertStatus('file over 5 MB -> 400', $r, 400);
$t->assertEqual('rejected oversized upload writes no file', $before, count(glob($uploadsRoot . '/*') ?: []));

$r = $t->uploadPhoto($photoPath, 'huge-dimensions.png', oversizedPng(9000, 9000), 'image/png', $token);
$t->assertStatus('image with an excessive canvas -> 400', $r, 400);

// --- authorization ----------------------------------------------------------
$r = $t->uploadPhoto('/api/parent/children/' . $otherChildId . '/photo', 'x.png', $pngBytes, 'image/png', $token);
$t->assertStatus('cross-parent photo upload -> 404', $r, 404);
$r = $t->request('DELETE', '/api/parent/children/' . $otherChildId . '/photo', token: $token);
$t->assertStatus('cross-parent photo delete -> 404', $r, 404);

$r = $t->uploadPhoto($photoPath, 'x.png', $pngBytes, 'image/png', $childToken);
$t->assertStatus('child session cannot upload a photo -> 403', $r, 403);
$r = $t->request('DELETE', $photoPath, token: $childToken);
$t->assertStatus('child session cannot remove a photo -> 403', $r, 403);

$r = $t->uploadPhoto($photoPath, 'x.png', $pngBytes, 'image/png');
$t->assertStatus('anonymous photo upload -> 401', $r, 401);
$r = $t->request('DELETE', $photoPath);
$t->assertStatus('anonymous photo delete -> 401', $r, 401);

$r = $t->uploadPhoto($photoPath, 'x.png', $pngBytes, 'image/png', 'not-a-real-token');
$t->assertStatus('invalid token photo upload -> 401', $r, 401);

$r = $t->uploadPhoto('/api/parent/children/not-a-uuid/photo', 'x.png', $pngBytes, 'image/png', $token);
$t->check('photo upload for an unknown child -> 404/400', in_array($r['status'], [400, 404], true), 'got ' . $r['status']);

// The photo must have survived every rejected request above.
$r = $t->request('GET', '/api/parent/children/' . $childId, token: $token);
$t->assertEqual('photo unchanged after all rejected requests', $mismatchUrl, $r['body']['data']['photoUrl'] ?? null);

// --- removal ----------------------------------------------------------------
$t->check('photo present before removal', uploadExists($uploadsRoot, basename((string) parse_url($mismatchUrl, PHP_URL_PATH))));

$r = $t->request('DELETE', $photoPath, token: $token);
$t->assertStatus('remove photo -> 200', $r, 200);
$t->assertEqual('photoUrl cleared after removal', '', $r['body']['data']['photoUrl'] ?? null);
$t->check('file deleted from disk', !uploadExists($uploadsRoot, basename((string) parse_url($mismatchUrl, PHP_URL_PATH))));
$t->assertStatus('removed photo URL is no longer served', $t->fetchRaw($mismatchUrl), 404);

$r = $t->request('GET', '/api/parent/children/' . $childId, token: $token);
$t->assertEqual('removal persists', '', $r['body']['data']['photoUrl'] ?? null);

// Removal must be idempotent so the UI can offer it unconditionally.
$r = $t->request('DELETE', $photoPath, token: $token);
$t->assertStatus('removing a photo that is already gone -> 200', $r, 200);
$t->assertEqual('still no photo', '', $r['body']['data']['photoUrl'] ?? null);

// The avatar falls back to the monogram, so photoUrl must be empty not null.
$r = $t->uploadPhoto($photoPath, 'avatar.png', $pngBytes, 'image/png', $token);
$t->assertStatus('re-upload after removal -> 200', $r, 200);
$reuploadUrl = (string) ($r['body']['data']['photoUrl'] ?? '');
$t->check('re-upload after removal stores a fresh file', $reuploadUrl !== '' && uploadExists($uploadsRoot, basename((string) parse_url($reuploadUrl, PHP_URL_PATH))));

// Deleting the child must not leave the photo file behind.
$r = $t->request('POST', '/api/parent/children', [
    'name' => 'Photo Cleanup Kid', 'age' => 7, 'grade' => 'Grade 2', 'pin' => '5555',
], $token);
$cleanupId = (string) ($r['body']['data']['id'] ?? '');
$r = $t->uploadPhoto('/api/parent/children/' . $cleanupId . '/photo', 'a.png', $pngBytes, 'image/png', $token);
$t->assertStatus('photo upload for a throwaway child -> 200', $r, 200);
$cleanupName = basename((string) parse_url((string) ($r['body']['data']['photoUrl'] ?? ''), PHP_URL_PATH));
$t->check('throwaway child photo stored', uploadExists($uploadsRoot, $cleanupName));

$r = $t->request('DELETE', '/api/parent/children/' . $cleanupId, token: $token);
$t->assertStatus('delete child with a photo -> 204', $r, 204);
$t->check('child deletion removes the photo file', !uploadExists($uploadsRoot, $cleanupName));

// Leave the shared test child without a photo for the Cleanup section.
$t->request('DELETE', $photoPath, token: $token);

// ---------------------------------------------------------------------------
// Security
// ---------------------------------------------------------------------------
$t->section('Security (SQLi / XSS / headers / hashing)');

// SQL injection attempts must NOT cause 500s or leak data.
$r = $t->request('GET', '/api/children/' . $childId . "/activities?date=" . urlencode("2026-08-06' OR '1'='1"), token: $token);
$t->check('SQLi in query param safe (200)', in_array($r['status'], [200, 404], true), 'got ' . $r['status']);
$r = $t->request('GET', '/api/children/' . rawurlencode($childId . "' OR '1'='1") . '/activities', token: $token);
$t->check('SQLi in path safe (404/400)', in_array($r['status'], [400, 404], true), 'got ' . $r['status']);
$r = $t->request('POST', '/api/children/' . $childId . '/activities', [
    'title' => "'; DROP TABLE activities; --", 'status' => 'pending', 'date' => date('Y-m-d'),
], $token);
$t->assertStatus('SQLi in body stored literally (201)', $r, 201);
$dropId = $r['body']['data']['id'] ?? null;
$t->request('DELETE', '/api/children/' . $childId . '/activities/' . $dropId, token: $token);

// XSS payload round-trips as inert JSON text.
$xss = '<script>alert(1)</script><img src=x onerror=alert(1)>';
$r = $t->request('POST', '/api/children/' . $childId . '/activities', [
    'title' => $xss, 'status' => 'pending', 'date' => date('Y-m-d'),
], $token);
$t->assertStatus('XSS payload accepted (201)', $r, 201);
$xssId = $r['body']['data']['id'] ?? null;
$r = $t->request('GET', '/api/children/' . $childId . '/activities/' . $xssId, token: $token);
$t->check('XSS payload not HTML-unescaped/executable', ($r['body']['data']['title'] ?? '') === $xss);
$t->request('DELETE', '/api/children/' . $childId . '/activities/' . $xssId, token: $token);

// Security headers on responses.
$r = $t->request('GET', '/api/health');
$t->check('Content-Type is application/json', str_contains($r['headers']['content-type'] ?? '', 'application/json'));
$t->check('X-Content-Type-Options: nosniff', ($r['headers']['x-content-type-options'] ?? '') === 'nosniff');
$t->check('X-Frame-Options: DENY', ($r['headers']['x-frame-options'] ?? '') === 'DENY');
$t->check('Referrer-Policy: no-referrer', ($r['headers']['referrer-policy'] ?? '') === 'no-referrer');

// Enum / overflow validation.
$r = $t->request('POST', '/api/children/' . $childId . '/activities', [
    'title' => 'enum attack', 'status' => "completed; DROP TABLE activities;--", 'coins' => 99999999, 'date' => date('Y-m-d'),
], $token);
$t->assertStatus('enum + overflow validation -> 422', $r, 422);

// Oversized strings.
$r = $t->request('POST', '/api/notifications', ['type' => 'activity', 'title' => str_repeat('x', 161), 'message' => 'ok'], $token);
$t->assertStatus('oversized title -> 422', $r, 422);

// ---------------------------------------------------------------------------
// Password & token hashing (DB assertions)
// ---------------------------------------------------------------------------
$t->section('Password & token hashing');

$pdo = null;
try {
    $pdo = new PDO('mysql:host=127.0.0.1;dbname=smart_child_hub;charset=utf8mb4', 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
} catch (Throwable $e) {
    $t->check('DB reachable for hashing assertions', false, $e->getMessage());
}

if ($pdo !== null) {
    $stmt = $pdo->prepare('SELECT password_hash FROM parents WHERE email = ?');
    $stmt->execute([$email]);
    $hash = $stmt->fetch()['password_hash'] ?? '';
    $t->check('password stored as bcrypt hash', str_starts_with($hash, '$2y$'), $hash !== '' ? 'got ' . substr($hash, 0, 4) . '...' : 'missing');

    $stmt = $pdo->prepare('SELECT COUNT(*) AS c FROM auth_tokens WHERE parent_id IN (SELECT id FROM parents WHERE email = ?)');
    $stmt->execute([$email]);
    $tokens = (int) $stmt->fetch()['c'];
    $stmt = $pdo->prepare('SELECT COUNT(*) AS c FROM auth_tokens t INNER JOIN parents p ON p.id = t.parent_id WHERE p.email = ? AND CHAR_LENGTH(t.token_hash) = 64');
    $stmt->execute([$email]);
    $hashedTokens = (int) $stmt->fetch()['c'];
    $t->check('auth tokens stored as sha256 hex (64 chars)', $hashedTokens === $tokens, "$hashedTokens/$tokens");

    // Raw tokens must never be persisted.
    $stmt = $pdo->prepare('SELECT COUNT(*) AS c FROM auth_tokens t INNER JOIN parents p ON p.id = t.parent_id WHERE p.email = ? AND t.token_hash = ?');
    $stmt->execute([$email, '']);
    $t->check('no empty/raw token hashes', (int) $stmt->fetch()['c'] === 0);
}

// ---------------------------------------------------------------------------
// Password reset + change (fresh flows)
// ---------------------------------------------------------------------------
$t->section('Password reset & change');

$r = $t->request('POST', '/api/auth/forgot-password', ['email' => $email]);
$t->assertStatus('forgot-password known email -> 200', $r, 200);
$resetToken = $r['body']['data']['resetToken'] ?? null;
$t->check('dev reset token returned', $resetToken !== null);

$r = $t->request('POST', '/api/auth/forgot-password', ['email' => 'ghost@example.com']);
$t->assertStatus('forgot-password unknown email -> 200 (no enumeration)', $r, 200);
$t->check('unknown email returns no reset token', !isset($r['body']['data']['resetToken']));
$t->check('same message for known/unknown', ($r['body']['message'] ?? '') === 'If an account exists for that email, a reset link has been sent.');

$newPassword = 'NewPass!456';
$r = $t->request('POST', '/api/auth/reset-password', [
    'token' => $resetToken, 'email' => $email, 'password' => $newPassword, 'password_confirmation' => $newPassword,
]);
$t->assertStatus('reset-password valid token -> 200', $r, 200);

$r = $t->request('POST', '/api/auth/login', ['email' => $email, 'password' => $password]);
$t->assertStatus('old password rejected after reset -> 401', $r, 401);
$r = $t->request('POST', '/api/auth/login', ['email' => $email, 'password' => $newPassword]);
$t->assertStatus('new password accepted -> 200', $r, 200);
$token = $r['body']['data']['token'] ?? null;

$r = $t->request('POST', '/api/auth/reset-password', [
    'token' => $resetToken, 'email' => $email, 'password' => 'Another!789', 'password_confirmation' => 'Another!789',
]);
$t->assertStatus('reset-password reused token -> 400', $r, 400);

$r = $t->request('POST', '/api/auth/change-password', ['currentPassword' => 'wrong', 'newPassword' => 'Changed!123', 'newPasswordConfirmation' => 'Changed!123'], $token);
$t->assertStatus('change-password wrong current -> 400', $r, 400);

$r = $t->request('POST', '/api/auth/change-password', ['currentPassword' => $newPassword, 'newPassword' => 'Changed!123', 'newPasswordConfirmation' => 'Changed!123'], $token);
$t->assertStatus('change-password correct -> 200', $r, 200);
$newToken = $r['body']['data']['token'] ?? null;
$r = $t->request('GET', '/api/auth/me', token: $token);
$t->assertStatus('old session revoked after password change -> 401', $r, 401);
$r = $t->request('GET', '/api/auth/me', token: $newToken);
$t->assertStatus('new session works after change -> 200', $r, 200);
$token = $newToken;

// ---------------------------------------------------------------------------
// Route / method handling
// ---------------------------------------------------------------------------
$t->section('Routing & HTTP methods');
$r = $t->request('GET', '/api/nonexistent-route', token: $token);
$t->assertStatus('unknown route -> 404', $r, 404);
$r = $t->request('PATCH', '/api/parent/profile', [], $token);
$t->assertStatus('unregistered method -> 404', $r, 404);
$r = $t->request('GET', '/api/parent/children//', token: $token);
$t->check('malformed path does not 500', $r['status'] < 500, 'got ' . $r['status']);

// ---------------------------------------------------------------------------
// Cleanup
// ---------------------------------------------------------------------------
$t->section('Cleanup');
$r = $t->request('DELETE', '/api/parent/children/' . $childId, token: $token);
$t->assertStatus('delete test child -> 204', $r, 204);
$r = $t->request('GET', '/api/parent/children/' . $childId, token: $token);
$t->assertStatus('deleted child gone -> 404', $r, 404);

// Remove the children created by the child profile / recovery sections so a
// rerun starts from the same state.
foreach ([$pinKidId, $noPinId, $recoverKidId, $siblingId, $lockKidId] as $extraChildId) {
    if (is_string($extraChildId) && $extraChildId !== '') {
        $t->request('DELETE', '/api/parent/children/' . $extraChildId, token: $token);
    }
}
$r = $t->request('POST', '/api/auth/logout', token: $token);
$t->assertStatus('logout -> 200', $r, 200);

// ---------------------------------------------------------------------------

exit($t->report());
