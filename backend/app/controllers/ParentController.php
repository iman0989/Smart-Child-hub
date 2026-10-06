<?php

declare(strict_types=1);

namespace SmartChildHub\Controllers;

use SmartChildHub\Config\Config;
use SmartChildHub\Core\AppException;
use SmartChildHub\Core\Auth;
use SmartChildHub\Core\Controller;
use SmartChildHub\Core\Request;
use SmartChildHub\Core\Response;
use SmartChildHub\Core\Validator;
use SmartChildHub\Models\ChildModel;
use SmartChildHub\Models\ChildSecurityQuestion;
use SmartChildHub\Models\ParentModel;

/**
 * Parent resources: profile, child management and dashboard statistics.
 */
final class ParentController extends Controller
{
    /** Accepted photo formats, mapped from the verified content type to a safe extension. */
    private const PHOTO_MIME_EXTENSIONS = [
        'image/jpeg' => 'jpg',
        'image/png' => 'png',
        'image/webp' => 'webp',
    ];

    private const PHOTO_MAX_BYTES = 5 * 1024 * 1024;
    private const PHOTO_MAX_DIMENSION = 8000;
    private const PHOTO_MAX_PIXELS = 25000000;

    // --- Profile ------------------------------------------------------------

    public function profile(Request $request): never
    {
        $parent = $this->requireParent($request);
        Response::success(ParentModel::publicRow($parent), 200, 'Profile retrieved.');
    }

    public function updateProfile(Request $request): never
    {
        $parent = $this->requireParent($request);
        $data = $request->all();

        (new Validator($data))
            ->string('fullName', 2, 120)
            ->string('phone', 0, 32)
            ->string('avatarKey', 0, 32)
            ->validate();

        $updates = [];
        foreach (ParentModel::updatable() as $column => $api) {
            if ($request->has($api)) {
                $updates[$column] = $api === 'avatar_key'
                    ? trim((string) $data[$api])
                    : trim((string) $data[$api]);
            }
        }

        if ($updates !== []) {
            $set = implode(', ', array_map(fn ($c) => "$c = ?", array_keys($updates)));
            $values = array_values($updates);
            $values[] = $parent['id'];
            $this->db->prepare("UPDATE parents SET $set WHERE id = ?")->execute($values);
        }

        $stmt = $this->db->prepare('SELECT * FROM parents WHERE id = ?');
        $stmt->execute([$parent['id']]);
        Response::success(ParentModel::publicRow($stmt->fetch()), 200, 'Profile updated.');
    }

    // --- Children -----------------------------------------------------------

    public function children(Request $request): never
    {
        $parent = $this->requireParent($request);

        $stmt = $this->db->prepare(
            'SELECT * FROM children WHERE parent_id = ? ORDER BY created_at ASC'
        );
        $stmt->execute([$parent['id']]);
        $children = array_map([ChildModel::class, 'fromRow'], $stmt->fetchAll());

        Response::success(['items' => $children, 'count' => count($children)], 200, 'Children retrieved.');
    }

    public function showChild(Request $request): never
    {
        $parent = $this->requireParent($request);
        $child = $this->requireChild($request, $parent['id'], $request->param(3));
        Response::success($this->childPayload($child), 200, 'Child retrieved.');
    }

    public function storeChild(Request $request): never
    {
        $parent = $this->requireParent($request);
        $data = $request->all();

        $securityQuestions = ChildSecurityQuestion::prepare($data['securityQuestions'] ?? null);

        (new Validator($data))
            ->has('name')->string('name', 1, 120)
            ->has('age')->int('age', Config::CHILD_AGE_MIN, Config::CHILD_AGE_MAX)
            ->has('grade')->string('grade', 1, 20)
            ->string('aboutChild', 0, Config::CHILD_ABOUT_MAX_LENGTH)
            ->string('avatarKey', 0, 32)
            ->pin('pin')
            ->validate();

        $grade = ChildModel::normalizeGrade((string) $data['grade']);
        if ($grade === null) {
            throw new AppException('Validation failed.', 422, null, ['grade' => self::gradeError()]);
        }

        $pin = trim((string) ($data['pin'] ?? ''));
        if ($pin === '') {
            throw new AppException('A 4-digit PIN is required for the child.', 400, null, ['pin' => 'A 4-digit PIN is required.']);
        }

        $cols = ChildModel::toColumns($data);
        $cols['grade'] = $grade;
        $cols['id'] = Auth::uuid();
        $cols['parent_id'] = $parent['id'];
        $pinColumns = ChildModel::pinColumns($pin);

        $this->db->prepare(
            'INSERT INTO children (id, parent_id, name, age, grade, about_child, avatar_key, photo_url, pin, pin_hash, coins, streak_days)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
        )->execute([
            $cols['id'], $cols['parent_id'], $cols['name'], $cols['age'], $cols['grade'],
            $cols['about_child'], $cols['avatar_key'], '', $pinColumns['pin'],
            $pinColumns['pin_hash'], $cols['coins'], $cols['streak_days'],
        ]);

        ChildSecurityQuestion::replaceForChild($this->db, $cols['id'], $securityQuestions);

        Response::created($this->childPayload($this->fetchChild($cols['id'])), 'Child added.');
    }

    public function updateChild(Request $request): never
    {
        $parent = $this->requireParent($request);
        $child = $this->requireChild($request, $parent['id'], $request->param(3));
        $data = $request->all();

        // The question list is only touched when the client sends the field, so
        // editing a profile without answers keeps the existing questions. A
        // question that is already configured may be resubmitted without an
        // answer, which keeps the stored one.
        $securityQuestions = $request->has('securityQuestions')
            ? ChildSecurityQuestion::prepare(
                $data['securityQuestions'],
                ChildSecurityQuestion::hashesForChild($this->db, (string) $child['id'])
            )
            : null;

        // Age and grade are checked separately from the generic rules because a
        // profile stored before the 4-14 / Grade 1-9 rules may still hold an
        // older value. Such a value survives only while the parent leaves it
        // untouched; any newly supplied value must be inside the range.
        $age = $child['age'];
        $grade = trim((string) $child['grade']);
        $errors = [];

        if ($request->has('age')) {
            if (!is_numeric($data['age']) || (int) $data['age'] != $data['age']) {
                $errors['age'] = 'The age must be a whole number.';
            } elseif ((int) $data['age'] !== (int) $child['age'] && !ChildModel::isValidAge($data['age'])) {
                $errors['age'] = self::ageError();
            } else {
                $age = (int) $data['age'];
            }
        }

        if ($request->has('grade')) {
            $submitted = trim((string) $data['grade']);
            $normalized = ChildModel::normalizeGrade($submitted);
            if ($normalized === null) {
                if ($submitted === trim((string) $child['grade'])) {
                    $grade = $submitted;
                } else {
                    $errors['grade'] = self::gradeError();
                }
            } else {
                $grade = $normalized;
            }
        }

        $remaining = $data;
        unset($remaining['age'], $remaining['grade']);

        (new Validator($remaining))
            ->string('name', 1, 120)
            ->string('aboutChild', 0, Config::CHILD_ABOUT_MAX_LENGTH)
            ->string('avatarKey', 0, 32)
            ->pin('pin')
            ->int('coins', 0, 99999)
            ->int('streakDays', 0, 9999)
            ->validate();

        if ($errors !== []) {
            throw new AppException('Validation failed.', 422, null, $errors);
        }

        $pin = isset($remaining['pin']) ? trim((string) $remaining['pin']) : '';
        if (isset($remaining['pin']) && $pin === '') {
            throw new AppException('A 4-digit PIN is required for the child.', 400, null, ['pin' => 'A 4-digit PIN is required.']);
        }
        if ($pin === '' && !ChildModel::hasPin($child)) {
            throw new AppException('A 4-digit PIN is required for the child.', 400, null, ['pin' => 'A 4-digit PIN is required.']);
        }

        // Merge onto the API shape: several columns use snake_case names, so
        // merging onto the raw row would silently reset them to their defaults.
        $cols = ChildModel::toColumns(array_merge(ChildModel::fromRow($child), $data));
        $cols['age'] = (int) $age;
        $cols['grade'] = (string) $grade;

        // `photo_url` is intentionally not written here: an ordinary profile
        // edit must not be able to clear or repoint the stored photo.
        $sets = ['name = ?', 'age = ?', 'grade = ?', 'about_child = ?', 'avatar_key = ?', 'coins = ?', 'streak_days = ?'];
        $values = [
            $cols['name'], $cols['age'], $cols['grade'], $cols['about_child'],
            $cols['avatar_key'], $cols['coins'], $cols['streak_days'],
        ];

        if ($pin !== '') {
            $pinColumns = ChildModel::pinColumns($pin);
            $sets[] = 'pin = ?';
            $sets[] = 'pin_hash = ?';
            $values[] = $pinColumns['pin'];
            $values[] = $pinColumns['pin_hash'];
        }

        $values[] = $child['id'];
        $this->db->prepare('UPDATE children SET ' . implode(', ', $sets) . ' WHERE id = ?')->execute($values);

        if ($securityQuestions !== null) {
            ChildSecurityQuestion::replaceForChild($this->db, (string) $child['id'], $securityQuestions);
        }

        Response::success($this->childPayload($this->fetchChild((string) $child['id'])), 200, 'Child updated.');
    }

    public function destroyChild(Request $request): never
    {
        $parent = $this->requireParent($request);
        $child = $this->requireChild($request, $parent['id'], $request->param(3));

        // Capture the photo first: once the row is gone the file is orphaned.
        $photoUrl = trim((string) ($child['photo_url'] ?? ''));

        $this->db->prepare('DELETE FROM children WHERE id = ?')->execute([$child['id']]);

        if ($photoUrl !== '') {
            $this->deleteStoredPhoto($photoUrl);
        }

        Response::noContent('Child deleted.');
    }

    /**
     * Question keys configured for one child (answers are never returned).
     */
    public function childSecurityQuestions(Request $request): never
    {
        $parent = $this->requireParent($request);
        $child = $this->requireChild($request, $parent['id'], $request->param(3));

        $keys = ChildSecurityQuestion::keysForChild($this->db, (string) $child['id']);
        $items = array_map(static fn (string $key): array => [
            'questionKey' => $key,
            'question'    => ChildSecurityQuestion::questionText($key),
        ], $keys);

        Response::success(['items' => $items, 'count' => count($items)], 200, 'Security questions retrieved.');
    }

    public function changeChildPin(Request $request): never
    {
        $parent = $this->requireParent($request);
        $child = $this->requireChild($request, $parent['id'], $request->param(3));
        $data = $request->all();

        (new Validator($data))
            ->pin('currentPin')
            ->has('newPin')->pin('newPin')
            ->has('newPinConfirmation')
            ->validate();

        $currentPin = (string) ($data['currentPin'] ?? '');
        $newPin = (string) $data['newPin'];
        $confirmPin = (string) ($data['newPinConfirmation'] ?? '');

        if (ChildModel::hasPin($child) && !ChildModel::verifyPin($child, $currentPin)) {
            throw new AppException('The current PIN is incorrect.', 400, null, ['currentPin' => 'Incorrect current PIN.']);
        }

        if ($newPin !== $confirmPin) {
            throw new AppException('The new PIN and confirmation do not match.', 400, null, ['newPinConfirmation' => 'PINs do not match.']);
        }

        if (!preg_match(Config::CHILD_PIN_REGEX, $newPin)) {
            throw new AppException('The PIN must be exactly 4 digits.', 400);
        }

        $this->db->prepare('UPDATE children SET pin = ?, pin_hash = ? WHERE id = ?')
            ->execute(['', ChildModel::pinColumns($newPin)['pin_hash'], $child['id']]);

        Response::success(ChildModel::fromRow($this->fetchChild((string) $child['id'])), 200, 'PIN updated successfully.');
    }

    public function uploadChildPhoto(Request $request): never
    {
        $parent = $this->requireParent($request);
        $child = $this->requireChild($request, $parent['id'], $request->param(3));

        if (empty($_FILES['photo']) || ($_FILES['photo']['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK) {
            throw new AppException('A photo file is required.', 400, null, ['photo' => 'Please select an image file.']);
        }

        $file = $_FILES['photo'];
        $tmpPath = (string) ($file['tmp_name'] ?? '');
        if (!is_uploaded_file($tmpPath)) {
            throw new AppException('Could not read the uploaded photo.', 400, null, ['photo' => 'Invalid upload.']);
        }

        $maxBytes = self::PHOTO_MAX_BYTES;
        $actualBytes = (int) (@filesize($tmpPath) ?: 0);
        if ($actualBytes <= 0 || $actualBytes > $maxBytes) {
            @unlink($tmpPath);
            throw new AppException('The photo must be 5 MB or smaller.', 400, null, ['photo' => 'Image is too large.']);
        }

        // Never trust the client filename: the stored extension is derived from
        // the real content type so a renamed .php/.svg cannot be published.
        $mime = $this->detectImageMime($tmpPath);
        if ($mime === null) {
            @unlink($tmpPath);
            throw new AppException(
                'Unsupported image type. Use JPG, PNG or WEBP.',
                400,
                null,
                ['photo' => 'Unsupported image type.']
            );
        }

        $info = @getimagesize($tmpPath);
        $width = (int) ($info[0] ?? 0);
        $height = (int) ($info[1] ?? 0);
        if ($width < 1 || $height < 1) {
            @unlink($tmpPath);
            throw new AppException(
                'That file is not a readable image.',
                400,
                null,
                ['photo' => 'Not a valid image.']
            );
        }
        if ($width > self::PHOTO_MAX_DIMENSION || $height > self::PHOTO_MAX_DIMENSION
            || ($width * $height) > self::PHOTO_MAX_PIXELS) {
            @unlink($tmpPath);
            throw new AppException(
                'That image is too large to process. Please choose a smaller photo.',
                400,
                null,
                ['photo' => 'Image dimensions are too large.']
            );
        }

        $uploadsDir = dirname(__DIR__, 2) . '/public/uploads';
        if (!is_dir($uploadsDir) && !mkdir($uploadsDir, 0755, true) && !is_dir($uploadsDir)) {
            @unlink($tmpPath);
            throw new AppException('Could not prepare photo storage.', 500);
        }

        $ext = self::PHOTO_MIME_EXTENSIONS[$mime];
        $filename = $child['id'] . '-' . bin2hex(random_bytes(12)) . '.' . $ext;
        $dest = $uploadsDir . '/' . $filename;

        if (!move_uploaded_file($tmpPath, $dest)) {
            @unlink($tmpPath);
            throw new AppException('Could not save the photo. Please try again.', 500);
        }
        @chmod($dest, 0644);

        $photoUrl = $this->uploadsBaseUrl() . '/' . rawurlencode($filename);
        $previousUrl = trim((string) ($child['photo_url'] ?? ''));

        $updated = $this->db->prepare('UPDATE children SET photo_url = ? WHERE id = ?')
            ->execute([$photoUrl, $child['id']]);
        if ($updated === false) {
            @unlink($dest);
            throw new AppException('Could not save the photo. Please try again.', 500);
        }

        // Only drop the old file once the new one is durably referenced, so a
        // failed upload never leaves the child without a photo.
        if ($previousUrl !== '' && $previousUrl !== $photoUrl) {
            $this->deleteStoredPhoto($previousUrl);
        }

        Response::success(
            $this->childPayload($this->fetchChild((string) $child['id'])),
            200,
            'Photo uploaded successfully.'
        );
    }

    /**
     * Removes a child's stored photo. Safe to call when no photo is set, so the
     * endpoint is idempotent and the UI can offer "remove" unconditionally.
     */
    public function removeChildPhoto(Request $request): never
    {
        $parent = $this->requireParent($request);
        $child = $this->requireChild($request, $parent['id'], $request->param(3));

        $previousUrl = trim((string) ($child['photo_url'] ?? ''));
        if ($previousUrl !== '') {
            $updated = $this->db->prepare('UPDATE children SET photo_url = \'\' WHERE id = ?')
                ->execute([$child['id']]);
            if ($updated === false) {
                throw new AppException('Could not remove the photo. Please try again.', 500);
            }
            $this->deleteStoredPhoto($previousUrl);
        }

        Response::success(
            $this->childPayload($this->fetchChild((string) $child['id'])),
            200,
            $previousUrl === '' ? 'No photo to remove.' : 'Photo removed successfully.'
        );
    }

    /**
     * Confirms the uploaded bytes really are one of the supported image formats.
     * Returns the canonical MIME type, or null when the file is not a valid image.
     */
    private function detectImageMime(string $path): ?string
    {
        $allowed = array_keys(self::PHOTO_MIME_EXTENSIONS);

        if (function_exists('finfo_open')) {
            $finfo = @finfo_open(FILEINFO_MIME_TYPE);
            if ($finfo !== false) {
                $detected = @finfo_file($finfo, $path);
                finfo_close($finfo);
                if (is_string($detected) && in_array($detected, $allowed, true)) {
                    return $detected;
                }
            }
        }

        // Fallback for builds without the fileinfo extension: rely on the
        // signature parser instead of the client-declared type.
        $info = @getimagesize($path);
        $bySignature = (is_array($info) && isset($info['mime'])) ? (string) $info['mime'] : null;

        return ($bySignature !== null && in_array($bySignature, $allowed, true)) ? $bySignature : null;
    }

    private function uploadsBaseUrl(): string
    {
        // Config::uploadsBaseUrl() uses BASE_URL when configured and otherwise
        // auto-detects scheme, host and subdirectory from the request, honouring
        // the X-Forwarded-Proto/X-Forwarded-Host headers set by HTTPS
        // terminating hosts. Emitting http:// here would make browsers block the
        // photo as mixed content on the HTTPS deployed frontend.
        return Config::uploadsBaseUrl();
    }

    private function deleteStoredPhoto(string $photoUrl): void
    {
        $path = parse_url($photoUrl, PHP_URL_PATH);
        if (!is_string($path) || $path === '') {
            return;
        }

        // Only ever resolve the basename inside the uploads directory. This keeps
        // deletion inside our own storage regardless of the deployment prefix,
        // and neutralises traversal segments such as "../../app/config.php".
        $basename = basename(rawurldecode($path));
        if ($basename === '' || $basename === '.' || $basename === '..' || str_contains($basename, '/')) {
            return;
        }

        $uploadsDir = realpath(dirname(__DIR__, 2) . '/public/uploads');
        if ($uploadsDir === false) {
            return;
        }

        $candidate = realpath($uploadsDir . DIRECTORY_SEPARATOR . $basename);
        if ($candidate !== false && str_starts_with($candidate, $uploadsDir . DIRECTORY_SEPARATOR)) {
            @unlink($candidate);
        }
    }

    // --- Dashboard ----------------------------------------------------------

    public function dashboard(Request $request): never
    {
        $parent = $this->requireParent($request);
        $parentId = $parent['id'];
        $today = date('Y-m-d');

        $childrenRows = $this->db->prepare('SELECT * FROM children WHERE parent_id = ? ORDER BY created_at ASC');
        $childrenRows->execute([$parentId]);
        $children = $childrenRows->fetchAll();

        $totalCoins = 0;
        foreach ($children as $c) {
            $totalCoins += (int) $c['coins'];
        }

        $ids = array_column($children, 'id');
        $placeholders = count($ids) > 0 ? implode(',', array_fill(0, count($ids), '?')) : "''";

        $todayTasks = $this->db->prepare(
            "SELECT
               SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS done,
               COUNT(*) AS total
             FROM activities WHERE child_id IN ($placeholders) AND activity_date = ?"
        );
        $todayTasks->execute([...$ids, $today]);
        $tt = $todayTasks->fetch() ?: [];

        $pendingHw = $this->db->prepare(
            "SELECT COUNT(*) AS count FROM homework
             WHERE child_id IN ($placeholders) AND status != 'completed'"
        );
        $pendingHw->execute($ids);
        $pendingHomework = (int) ($pendingHw->fetch()['count'] ?? 0);

        $unread = $this->db->prepare('SELECT COUNT(*) AS count FROM notifications WHERE parent_id = ? AND is_read = 0');
        $unread->execute([$parentId]);
        $unreadCount = (int) ($unread->fetch()['count'] ?? 0);

        $sleepAvg = $this->db->prepare(
            "SELECT COALESCE(AVG(hours), 0) AS avg FROM sleep_records
             WHERE child_id IN ($placeholders) AND date BETWEEN ? AND ?"
        );
        $sleepAvg->execute([...$ids, date('Y-m-d', strtotime('-6 days')), $today]);
        $avgSleep = round((float) ($sleepAvg->fetch()['avg'] ?? 0), 1);

        $waterToday = $this->db->prepare(
            "SELECT COALESCE(SUM(glasses), 0) AS glasses, COALESCE(SUM(target_glasses), 0) AS target
             FROM water_intakes WHERE child_id IN ($placeholders) AND date = ?"
        );
        $waterToday->execute([...$ids, $today]);
        $water = $waterToday->fetch() ?: [];
        $target = (int) ($water['target'] ?? 0);
        $waterProgress = $target > 0 ? round(((int) ($water['glasses'] ?? 0) / $target) * 100, 1) : 0;

        $childSummaries = [];
        foreach ($children as $c) {
            $perChild = $this->db->prepare(
                "SELECT
                   SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS done,
                   COUNT(*) AS total
                 FROM activities WHERE child_id = ? AND activity_date = ?"
            );
            $perChild->execute([$c['id'], $today]);
            $pc = $perChild->fetch() ?: [];
            $childSummaries[] = [
                'child' => ChildModel::fromRow($c),
                'todayTasksDone' => (int) ($pc['done'] ?? 0),
                'todayTasksTotal' => (int) ($pc['total'] ?? 0),
            ];
        }

        Response::success([
            'childrenCount'      => count($children),
            'totalCoins'         => $totalCoins,
            'todayTasksDone'     => (int) ($tt['done'] ?? 0),
            'todayTasksTotal'    => (int) ($tt['total'] ?? 0),
            'pendingHomework'    => $pendingHomework,
            'unreadNotifications' => $unreadCount,
            'averageSleepHours'  => $avgSleep,
            'waterGoalProgress'  => $waterProgress,
            'children'           => $childSummaries,
        ], 200, 'Dashboard statistics retrieved.');
    }

    private function fetchChild(string $id): array
    {
        $stmt = $this->db->prepare('SELECT * FROM children WHERE id = ?');
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        if ($row === false) {
            throw new AppException('Child not found.', 404);
        }
        return $row;
    }

    /**
     * Single-child payload. Adds the configured security question keys so the
     * edit form can show them again (answers are never included).
     */
    private function childPayload(array $child): array
    {
        $payload = ChildModel::fromRow($child);
        $payload['securityQuestions'] = ChildSecurityQuestion::keysForChild(
            $this->db,
            (string) $child['id']
        );
        return $payload;
    }

    private static function ageError(): string
    {
        return 'Age must be between ' . Config::CHILD_AGE_MIN . ' and ' . Config::CHILD_AGE_MAX . '.';
    }

    private static function gradeError(): string
    {
        return 'Grade must be between Grade ' . Config::CHILD_GRADE_MIN
            . ' and Grade ' . Config::CHILD_GRADE_MAX . '.';
    }
}
