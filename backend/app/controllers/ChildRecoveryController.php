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
use SmartChildHub\Models\ChildPinRecoveryToken;
use SmartChildHub\Models\ChildSecurityQuestion;

/**
 * Child-specific 4-digit PIN recovery.
 *
 * This is deliberately separate from the parent password reset: a child
 * recovering their PIN must never touch a parent account or use the parent's
 * email. The flow is:
 *
 *   1. questions  - proves which child is being recovered and returns the
 *                   question keys the parent configured (never the answers)
 *   2. verify     - checks every answer and hands back a short-lived,
 *                   single-child recovery token
 *   3. reset      - exchanges that token for a new 4-digit PIN
 *
 * Cross-child protection: every step is scoped to one `child_id`. When the
 * caller is authenticated, ownership is enforced against the token; an
 * unauthenticated caller (a child who cannot get into the app yet) must supply
 * the child's name. A recovery token therefore only ever changes the PIN of the
 * single child it was issued for.
 */
final class ChildRecoveryController extends Controller
{
    private const NOT_FOUND = 'Child not found. Please check the name and try again.';
    private const NO_QUESTIONS = 'No security questions are set up for this child. Please ask a parent to add one.';

    /**
     * Step 1: return the child's configured security questions.
     */
    public function questions(Request $request): never
    {
        $data = $request->all();
        (new Validator($data))
            ->has('childId')->string('childId', 1, 64)
            ->validate();

        $child = $this->resolveChild($request, trim((string) $data['childId']), $data);

        $this->assertNotLockedOut($child);

        $keys = ChildSecurityQuestion::keysForChild($this->db, (string) $child['id']);
        if ($keys === []) {
            throw new AppException(self::NO_QUESTIONS, 400);
        }

        Response::success([
            'childId'   => (string) $child['id'],
            'name'      => (string) $child['name'],
            'questions' => array_map(static fn (string $key): array => [
                'questionKey' => $key,
                'question'    => ChildSecurityQuestion::questionText($key),
            ], $keys),
        ], 200, 'Security questions retrieved.');
    }

    /**
     * Step 2: verify the answers and issue a recovery token.
     */
    public function verify(Request $request): never
    {
        $data = $request->all();
        (new Validator($data))
            ->has('childId')->string('childId', 1, 64)
            ->validate();

        $child = $this->resolveChild($request, trim((string) $data['childId']), $data);
        $this->assertNotLockedOut($child);

        $rows = ChildSecurityQuestion::rowsForChild($this->db, (string) $child['id']);
        if ($rows === []) {
            throw new AppException(self::NO_QUESTIONS, 400);
        }

        $answers = $this->collectAnswers($data['answers'] ?? null, $rows);

        foreach ($rows as $row) {
            $key = (string) $row['question_key'];
            if (!ChildSecurityQuestion::verifyAnswer($answers[$key], (string) $row['answer_hash'])) {
                $this->registerFailedAttempt($child);
                throw new AppException('Incorrect answer. Please try again.', 400, null, [
                    'answers' => 'One or more answers are incorrect.',
                ]);
            }
        }

        $this->db->prepare(
            'UPDATE children SET recovery_failed_attempts = 0, recovery_locked_until = NULL WHERE id = ?'
        )->execute([$child['id']]);

        ChildPinRecoveryToken::prune($this->db);
        $token = ChildPinRecoveryToken::issue($this->db, (string) $child['id']);

        Response::success([
            'childId'          => (string) $child['id'],
            'recoveryToken'    => $token,
            'expiresInMinutes' => Config::CHILD_RECOVERY_TOKEN_TTL_MINUTES,
        ], 200, 'Answers verified. Choose a new PIN.');
    }

    /**
     * Step 3: exchange the recovery token for a new 4-digit PIN.
     */
    public function reset(Request $request): never
    {
        $data = $request->all();

        (new Validator($data))
            ->has('recoveryToken')->string('recoveryToken', 16, 255)
            ->has('newPin')->pin('newPin')
            ->has('newPinConfirmation')
            ->validate();

        $newPin = (string) $data['newPin'];
        if ($newPin !== (string) $data['newPinConfirmation']) {
            throw new AppException('The new PIN and confirmation do not match.', 400, null, [
                'newPinConfirmation' => 'PINs do not match.',
            ]);
        }

        $resolved = ChildPinRecoveryToken::resolve($this->db, (string) $data['recoveryToken']);
        if ($resolved === null) {
            throw new AppException('This recovery session is invalid or has expired. Please start again.', 400);
        }

        $child = $this->db->prepare('SELECT * FROM children WHERE id = ? LIMIT 1');
        $child->execute([$resolved['child_id']]);
        $row = $child->fetch();
        if ($row === false) {
            throw new AppException('This recovery session is invalid or has expired. Please start again.', 400);
        }

        $pinColumns = ChildModel::pinColumns($newPin);

        $this->db->beginTransaction();
        try {
            // Only this child's PIN is touched.
            $this->db->prepare('UPDATE children SET pin = ?, pin_hash = ? WHERE id = ?')
                ->execute([$pinColumns['pin'], $pinColumns['pin_hash'], $resolved['child_id']]);

            ChildPinRecoveryToken::markUsed($this->db, $resolved['token_id']);

            // A PIN change ends every session opened with the old PIN.
            $this->db->prepare(
                'UPDATE auth_tokens SET revoked = 1 WHERE child_id = ? AND revoked = 0'
            )->execute([$resolved['child_id']]);

            $this->db->commit();
        } catch (\Throwable $e) {
            $this->db->rollBack();
            throw new AppException('Could not reset the PIN. Please try again.', 500, $e);
        }

        Response::success([
            'childId' => (string) $resolved['child_id'],
            'name'    => (string) $row['name'],
        ], 200, 'PIN reset successful. You can log in with your new PIN now.');
    }

    // --- Internals ----------------------------------------------------------

    /**
     * Resolve the child being recovered and prove the caller may do so.
     *
     * Authenticated callers must own the child (or be that child). Without a
     * token the child's name is required, which keeps an anonymous request from
     * silently recovering an arbitrary profile.
     */
    private function resolveChild(Request $request, string $childId, array $data): array
    {
        $principal = Auth::principal($request);

        $sql = 'SELECT * FROM children WHERE id = ?';
        $params = [$childId];

        if ($principal !== null) {
            if (($principal['subject_type'] ?? '') === 'parent') {
                $sql .= ' AND parent_id = ?';
                $params[] = (string) $principal['id'];
            } else {
                // A child session may only ever recover itself.
                if (($principal['subject_child_id'] ?? '') !== $childId) {
                    throw new AppException(self::NOT_FOUND, 404);
                }
            }
        } else {
            $name = trim((string) ($data['name'] ?? ''));
            if ($name === '') {
                throw new AppException('Enter the name of the child you are helping.', 400, null, [
                    'name' => 'The child name is required.',
                ]);
            }
            $sql .= ' AND LOWER(name) = ?';
            $params[] = mb_strtolower($name);
        }

        $sql .= ' LIMIT 1';
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        $child = $stmt->fetch();

        if ($child === false) {
            throw new AppException(self::NOT_FOUND, 404);
        }

        return $child;
    }

    /**
     * @param list<array{question_key: string, answer_hash: string}> $rows
     * @return array<string, string>
     */
    private function collectAnswers(mixed $answers, array $rows): array
    {
        if (!is_array($answers)) {
            throw new AppException('Please answer the security questions.', 400, null, [
                'answers' => 'Please answer every security question.',
            ]);
        }

        $provided = [];
        foreach ($answers as $entry) {
            if (!is_array($entry)) {
                continue;
            }
            $key = trim((string) ($entry['questionKey'] ?? ''));
            if ($key !== '') {
                $provided[$key] = (string) ($entry['answer'] ?? '');
            }
        }

        foreach ($rows as $row) {
            $key = (string) $row['question_key'];
            if (!array_key_exists($key, $provided) || trim($provided[$key]) === '') {
                throw new AppException('Please answer every security question.', 400, null, [
                    'answers' => 'Please answer every security question.',
                ]);
            }
        }

        return $provided;
    }

    private function assertNotLockedOut(array $child): void
    {
        $lockedUntil = (string) ($child['recovery_locked_until'] ?? '');
        if ($lockedUntil === '') {
            return;
        }

        if (strtotime($lockedUntil) > time()) {
            $minutes = max(1, (int) ceil((strtotime($lockedUntil) - time()) / 60));
            throw new AppException(
                'Too many wrong answers. Please wait ' . $minutes . ' minute' . ($minutes === 1 ? '' : 's') . ' and try again.',
                429
            );
        }

        // Lockout has expired: clear it so the next attempt starts fresh.
        $this->db->prepare(
            'UPDATE children SET recovery_failed_attempts = 0, recovery_locked_until = NULL WHERE id = ?'
        )->execute([$child['id']]);
    }

    private function registerFailedAttempt(array $child): void
    {
        $attempts = (int) ($child['recovery_failed_attempts'] ?? 0) + 1;

        if ($attempts >= Config::CHILD_RECOVERY_MAX_ATTEMPTS) {
            $this->db->prepare(
                'UPDATE children
                 SET recovery_failed_attempts = ?, recovery_locked_until = DATE_ADD(NOW(), INTERVAL ? MINUTE)
                 WHERE id = ?'
            )->execute([$attempts, Config::CHILD_RECOVERY_LOCKOUT_MINUTES, $child['id']]);
            return;
        }

        $this->db->prepare('UPDATE children SET recovery_failed_attempts = ? WHERE id = ?')
            ->execute([$attempts, $child['id']]);
    }
}