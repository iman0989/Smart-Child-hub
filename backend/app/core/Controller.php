<?php

declare(strict_types=1);

namespace SmartChildHub\Core;

use PDO;

/**
 * Base controller with shared authorization helpers.
 */
abstract class Controller
{
    protected PDO $db;

    public function __construct()
    {
        $this->db = Database::pdo();
    }

    protected function requireParent(Request $request): array
    {
        return Auth::parent($request);
    }

    /**
     * Resolve access to a child profile that may be granted either to the
     * owning parent (via a parent token) or to that child itself (via its own
     * child session token). Any other subject is rejected.
     *
     * Returns the full child row.
     */
    protected function requireChildAccess(Request $request, string $childId): array
    {
        $principal = Auth::principal($request);
        if ($principal === null) {
            throw new AppException(
                $request->bearerToken() === null
                    ? 'Authentication required. Provide a Bearer token.'
                    : 'Invalid or expired token.',
                401
            );
        }

        if (($principal['subject_type'] ?? '') === 'parent') {
            return $this->requireChild($request, (string) $principal['id'], $childId);
        }

        if (($principal['subject_type'] ?? '') === 'child') {
            if (($principal['subject_child_id'] ?? '') !== $childId) {
                throw new AppException('Child not found.', 404);
            }
            $stmt = $this->db->prepare('SELECT * FROM children WHERE id = ? LIMIT 1');
            $stmt->execute([$childId]);
            $child = $stmt->fetch();
            if ($child === false) {
                throw new AppException('Child not found.', 404);
            }
            return $child;
        }

        throw new AppException('Authentication required. Provide a Bearer token.', 401);
    }

    /**
     * Resolve the child id from the URL (`/api/children/{id}/...`) and verify
     * the requester (owning parent or that child) may access it.
     */
    protected function childIdFromPath(Request $request): array
    {
        $id = $request->param(2);
        if ($id === null || $id === '' || $id === 'null') {
            throw new AppException('Child id is required.', 400);
        }
        return $this->requireChildAccess($request, $id);
    }

    /**
     * Resolve a child id and verify it belongs to the authenticated parent.
     * Throws 403 when the child belongs to someone else.
     */
    protected function requireChild(Request $request, string $parentId, ?string $childId = null): array
    {
        $id = $childId ?? $request->param(2);
        if ($id === null || $id === '' || $id === 'null') {
            throw new AppException('Child id is required.', 400);
        }

        $stmt = $this->db->prepare(
            'SELECT * FROM children WHERE id = ? AND parent_id = ? LIMIT 1'
        );
        $stmt->execute([$id, $parentId]);
        $child = $stmt->fetch();
        if ($child === false) {
            throw new AppException('Child not found.', 404);
        }
        return $child;
    }

    protected function ownedChildId(Request $request, string $parentId): string
    {
        $child = $this->requireChild($request, $parentId);
        return (string) $child['id'];
    }

    protected function paginateParams(Request $request): array
    {
        $page = max(1, (int) ($request->query('page', 1)));
        $perPage = (int) $request->query('per_page', 20);
        $perPage = max(1, min(100, $perPage));
        return [$page, $perPage, ($page - 1) * $perPage];
    }
}
