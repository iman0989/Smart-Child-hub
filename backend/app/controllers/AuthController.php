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
use SmartChildHub\Models\ParentModel;

/**
 * Authentication: register, login, logout, password recovery, session profile.
 */
final class AuthController extends Controller
{
    public function register(Request $request): never
    {
        $data = $request->all();

        (new Validator($data))
            ->has('fullName')->string('fullName', 2, 120)
            ->has('email')->email('email')
            ->string('phone', 0, 32)
            ->has('password')->password('password')->confirmed('password')
            ->validate();

        $email = strtolower(trim((string) $data['email']));
        $stmt = $this->db->prepare('SELECT id FROM parents WHERE email = ?');
        $stmt->execute([$email]);
        if ($stmt->fetch() !== false) {
            throw new AppException('An account with this email already exists.', 409, null, ['email' => 'Email already registered.']);
        }

        $id = Auth::uuid();
        $this->db->prepare(
            'INSERT INTO parents (id, full_name, email, phone, password_hash, avatar_key)
             VALUES (?, ?, ?, ?, ?, ?)'
        )->execute([
            $id,
            trim((string) $data['fullName']),
            $email,
            trim((string) ($data['phone'] ?? '')),
            password_hash((string) $data['password'], PASSWORD_DEFAULT),
            trim((string) ($data['avatarKey'] ?? 'grape')),
        ]);

        $token = Auth::issueToken($id, (string) ($data['deviceName'] ?? 'mobile'));

        Response::created(
            $this->sessionPayload($id, $token),
            'Account created. Welcome to Smart Child Hub!'
        );
    }

    public function login(Request $request): never
    {
        $data = $request->all();

        (new Validator($data))
            ->has('email')->email('email')
            ->has('password')->validate();

        $email = strtolower(trim((string) $data['email']));
        $stmt = $this->db->prepare(
            'SELECT * FROM parents WHERE email = ? LIMIT 1'
        );
        $stmt->execute([$email]);
        $parent = $stmt->fetch();

        if ($parent === false || !password_verify((string) $data['password'], $parent['password_hash'])) {
            throw new AppException('Incorrect email or password.', 401);
        }

        $token = Auth::issueToken($parent['id'], (string) ($data['deviceName'] ?? 'mobile'));

        Response::success(
            $this->sessionPayload($parent['id'], $token),
            200,
            'Login successful.'
        );
    }

    public function logout(Request $request): never
    {
        $this->requireParent($request);
        Auth::revoke($request);
        Response::success(null, 200, 'Logged out successfully.');
    }

    public function me(Request $request): never
    {
        $parent = $this->requireParent($request);
        Response::success(ParentModel::publicRow($parent), 200, 'Profile retrieved.');
    }

    public function forgotPassword(Request $request): never
    {
        $data = $request->all();
        (new Validator($data))->has('email')->email('email')->validate();

        $email = strtolower(trim((string) $data['email']));
        $stmt = $this->db->prepare('SELECT id FROM parents WHERE email = ? LIMIT 1');
        $stmt->execute([$email]);
        $parent = $stmt->fetch();

        // Generic message keeps account enumeration at bay.
        $message = 'If an account exists for that email, a reset link has been sent.';

        if ($parent !== false) {
            $raw = bin2hex(random_bytes(Config::RESET_TOKEN_CHARS));
            $this->db->prepare(
                'INSERT INTO password_resets (id, parent_id, token_hash, expires_at)
                 VALUES (?, ?, ?, ?)'
            )->execute([
                Auth::uuid(),
                $parent['id'],
                hash('sha256', $raw),
                (new \DateTimeImmutable('+' . Config::RESET_TOKEN_TTL_MINUTES . ' minutes'))->format('Y-m-d H:i:s'),
            ]);

            // Development convenience: return the one-time token in the body.
            // In production this is sent by email instead.
            Response::success([
                'resetToken' => $raw,
                'expiresInMinutes' => Config::RESET_TOKEN_TTL_MINUTES,
            ], 200, $message);
        }

        Response::success(null, 200, $message);
    }

    public function resetPassword(Request $request): never
    {
        $data = $request->all();

        (new Validator($data))
            ->has('token')->string('token', 16)
            ->has('email')->email('email')
            ->has('password')->password('password')->confirmed('password')
            ->validate();

        $email = strtolower(trim((string) $data['email']));
        $stmt = $this->db->prepare(
            'SELECT pr.* FROM password_resets pr
             INNER JOIN parents p ON p.id = pr.parent_id
             WHERE pr.token_hash = ? AND pr.used = 0 AND p.email = ?
             ORDER BY pr.created_at DESC LIMIT 1'
        );
        $stmt->execute([hash('sha256', (string) $data['token']), $email]);
        $reset = $stmt->fetch();

        if ($reset === false) {
            throw new AppException('Invalid or expired reset token.', 400);
        }
        if (strtotime($reset['expires_at']) < time()) {
            throw new AppException('This reset token has expired. Request a new one.', 400);
        }

        $this->db->beginTransaction();
        try {
            $this->db->prepare('UPDATE parents SET password_hash = ? WHERE id = ?')
                ->execute([password_hash((string) $data['password'], PASSWORD_DEFAULT), $reset['parent_id']]);
            $this->db->prepare('UPDATE password_resets SET used = 1 WHERE id = ?')
                ->execute([$reset['id']]);
            Auth::revokeAll($reset['parent_id']);
            $this->db->commit();
        } catch (\Throwable $e) {
            $this->db->rollBack();
            throw new AppException('Could not reset the password. Please try again.', 500, $e);
        }

        Response::success(null, 200, 'Password reset successful. You can log in now.');
    }

    public function changePassword(Request $request): never
    {
        $parent = $this->requireParent($request);
        $data = $request->all();

        (new Validator($data))
            ->has('currentPassword')
            ->has('newPassword')->password('newPassword')
            ->confirmed('newPassword', 'newPasswordConfirmation')
            ->validate();

        if (!password_verify((string) $data['currentPassword'], $parent['password_hash'])) {
            throw new AppException('The current password is incorrect.', 400, null, ['currentPassword' => 'Incorrect current password.']);
        }

        $this->db->prepare('UPDATE parents SET password_hash = ? WHERE id = ?')
            ->execute([password_hash((string) $data['newPassword'], PASSWORD_DEFAULT), $parent['id']]);

        Auth::revokeAll($parent['id']);
        $token = Auth::issueToken($parent['id'], (string) ($data['deviceName'] ?? 'mobile'));

        Response::success(
            $this->sessionPayload($parent['id'], $token),
            200,
            'Password changed. Other sessions have been signed out.'
        );
    }

    private function sessionPayload(string $parentId, string $token): array
    {
        $stmt = $this->db->prepare('SELECT * FROM parents WHERE id = ?');
        $stmt->execute([$parentId]);
        $parent = $stmt->fetch();

        return [
            'user'       => ParentModel::publicRow($parent),
            'token'      => $token,
            'tokenType'  => 'Bearer',
            'expiresIn'  => Config::TOKEN_TTL_HOURS * 3600,
        ];
    }

    public function childLogin(Request $request): never
    {
        $data = $request->all();

        (new Validator($data))
            ->has('childId')->string('childId', 1, 255)
            ->has('pin')->pin('pin')
            ->validate();

        $childId = trim((string) $data['childId']);
        $pin = trim((string) $data['pin']);

        $stmt = $this->db->prepare(
            'SELECT * FROM children WHERE id = ? LIMIT 1'
        );
        $stmt->execute([$childId]);
        $child = $stmt->fetch();

        if ($child === false) {
            throw new AppException('Child not found.', 404);
        }

        // A profile without any PIN must not be reachable by guessing: it has
        // no credential to check, so a parent has to set one first.
        if (!ChildModel::hasPin($child)) {
            throw new AppException('This child has no PIN yet. Please ask a parent to set one.', 403);
        }

        if (!ChildModel::verifyPin($child, $pin)) {
            throw new AppException('Incorrect PIN. Please try again.', 401);
        }

        // The child gets its own session token so the backend can tell a
        // PIN-authenticated child apart from the parent and reject any
        // profile, PIN or account-management request on their behalf.
        $token = Auth::issueChildToken(
            (string) $child['parent_id'],
            (string) $child['id'],
            'child-app'
        );

        Response::success([
            'child'     => ChildModel::fromRow($child),
            'token'     => $token,
            'tokenType' => 'Bearer',
            'expiresIn' => Config::TOKEN_TTL_HOURS * 3600,
        ], 200, 'Child login successful.');
    }
}
