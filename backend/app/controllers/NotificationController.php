<?php

declare(strict_types=1);

namespace SmartChildHub\Controllers;

use SmartChildHub\Core\AppException;
use SmartChildHub\Core\Auth;
use SmartChildHub\Core\Controller;
use SmartChildHub\Core\Request;
use SmartChildHub\Core\Response;
use SmartChildHub\Core\Validator;
use SmartChildHub\Models\NotificationModel;

/**
 * Notifications: reminder list, create, read/unread toggling, delete, counters.
 *
 * Records are scoped to the authenticated parent. Notifications are stored as
 * rows ready for any push provider (FCM/APNs) to be hydrated from.
 */
final class NotificationController extends Controller
{
    public function index(Request $request): never
    {
        $familyParentId = $this->familyParentId($request);
        [$page, $perPage, $offset] = $this->paginateParams($request);

        $where = ['parent_id = ?'];
        $params = [$familyParentId];

        $readFilter = $request->query('read');
        if ($readFilter === '0' || $readFilter === '1') {
            $where[] = 'is_read = ?';
            $params[] = (int) $readFilter;
        }

        $whereSql = implode(' AND ', $where);

        $countStmt = $this->db->prepare("SELECT COUNT(*) AS c FROM notifications WHERE $whereSql");
        $countStmt->execute($params);
        $total = (int) $countStmt->fetch()['c'];

        $stmt = $this->db->prepare(
            "SELECT * FROM notifications WHERE $whereSql ORDER BY created_at DESC LIMIT $perPage OFFSET $offset"
        );
        $stmt->execute($params);
        $items = array_map([NotificationModel::class, 'fromRow'], $stmt->fetchAll());

        Response::success([
            'items' => $items,
            'page'  => $page,
            'perPage' => $perPage,
            'total' => $total,
            'totalPages' => (int) ceil($total / $perPage),
        ], 200, 'Notifications retrieved.');
    }

    public function unreadCount(Request $request): never
    {
        $familyParentId = $this->familyParentId($request);
        $stmt = $this->db->prepare(
            'SELECT COUNT(*) AS c FROM notifications WHERE parent_id = ? AND is_read = 0'
        );
        $stmt->execute([$familyParentId]);
        Response::success(['unread' => (int) $stmt->fetch()['c']], 200, 'Unread count retrieved.');
    }

    public function store(Request $request): never
    {
        $parent = $this->requireParent($request);
        $data = $request->all();

        (new Validator($data))
            ->in('type', ['activity', 'meal', 'homework', 'announcement'])
            ->has('title')->string('title', 1, 160)
            ->has('message')->string('message', 1, 2000)
            ->string('icon', 0, 40)
            ->bool('read')
            ->validate();

        $cols = NotificationModel::toColumns($data, $parent['id']);
        if ($cols['child_id'] !== null) {
            // Ensure the referenced child belongs to this parent.
            $stmt = $this->db->prepare('SELECT id FROM children WHERE id = ? AND parent_id = ?');
            $stmt->execute([$cols['child_id'], $parent['id']]);
            if ($stmt->fetch() === false) {
                throw new AppException('Child not found.', 404, null, ['childId' => 'Unknown child.']);
            }
        }

        $cols['id'] = Auth::uuid();
        $this->insert($cols);

        Response::created(NotificationModel::fromRow($this->fetch((string) $cols['id'])), 'Notification created.');
    }

    public function show(Request $request): never
    {
        $parent = $this->requireParent($request);
        $row = $this->fetchOwned($request, $parent['id']);
        Response::success(NotificationModel::fromRow($row), 200, 'Notification retrieved.');
    }

    public function update(Request $request): never
    {
        $parent = $this->requireParent($request);
        $row = $this->fetchOwned($request, $parent['id']);
        $data = $request->all();

        (new Validator($data))
            ->in('type', ['activity', 'meal', 'homework', 'announcement'])
            ->string('title', 1, 160)
            ->string('message', 1, 2000)
            ->string('icon', 0, 40)
            ->bool('read')
            ->validate();

        $isRead = isset($data['read']) ? (int) (bool) $data['read'] : (int) $row['is_read'];
        $this->db->prepare(
            'UPDATE notifications SET type = ?, title = ?, message = ?, icon = ?, is_read = ? WHERE id = ?'
        )->execute([
            $data['type'] ?? $row['type'],
            $data['title'] ?? $row['title'],
            $data['message'] ?? $row['message'],
            $data['icon'] ?? $row['icon'],
            $isRead,
            $row['id'],
        ]);

        Response::success(NotificationModel::fromRow($this->fetch((string) $row['id'])), 200, 'Notification updated.');
    }

    public function markRead(Request $request): never
    {
        $familyParentId = $this->familyParentId($request);
        $row = $this->fetchOwned($request, $familyParentId);

        $this->db->prepare('UPDATE notifications SET is_read = 1 WHERE id = ?')->execute([$row['id']]);
        Response::success(NotificationModel::fromRow($this->fetch((string) $row['id'])), 200, 'Notification marked as read.');
    }

    public function markAllRead(Request $request): never
    {
        $familyParentId = $this->familyParentId($request);
        $stmt = $this->db->prepare('UPDATE notifications SET is_read = 1 WHERE parent_id = ? AND is_read = 0');
        $stmt->execute([$familyParentId]);
        Response::success(['updated' => $stmt->rowCount()], 200, 'All notifications marked as read.');
    }

    public function destroy(Request $request): never
    {
        $parent = $this->requireParent($request);
        $row = $this->fetchOwned($request, $parent['id']);
        $this->db->prepare('DELETE FROM notifications WHERE id = ?')->execute([$row['id']]);
        Response::noContent('Notification deleted.');
    }

    // -------------------------------------------------------------------------

    /**
     * Resolve the family's parent id from a parent or a child session token.
     * Children may read family notifications but cannot change the account.
     */
    private function familyParentId(Request $request): string
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
        return (string) $principal['id'];
    }

    private function fetchOwned(Request $request, string $parentId): array
    {
        $id = $request->param(2);
        if ($id === null || $id === '' || $id === 'null') {
            throw new AppException('Notification id is required.', 400);
        }
        $stmt = $this->db->prepare('SELECT * FROM notifications WHERE id = ? AND parent_id = ?');
        $stmt->execute([$id, $parentId]);
        $row = $stmt->fetch();
        if ($row === false) {
            throw new AppException('Notification not found.', 404);
        }
        return $row;
    }

    private function fetch(string $id): array
    {
        $stmt = $this->db->prepare('SELECT * FROM notifications WHERE id = ?');
        $stmt->execute([$id]);
        return $stmt->fetch() ?: [];
    }

    private function insert(array $cols): void
    {
        $this->db->prepare(
            'INSERT INTO notifications (id, parent_id, child_id, type, title, message, icon, is_read)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
        )->execute([
            $cols['id'], $cols['parent_id'], $cols['child_id'], $cols['type'],
            $cols['title'], $cols['message'], $cols['icon'], $cols['is_read'],
        ]);
    }
}
