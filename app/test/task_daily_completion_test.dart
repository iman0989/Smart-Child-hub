import 'package:flutter_test/flutter_test.dart';

import 'package:smart_child_hub/core/repositories/activity_repository.dart';
import 'package:smart_child_hub/models/task_model.dart';
import 'package:smart_child_hub/providers/task_provider.dart';

/// In-memory stand-in for the `activities` table: one row per child, per day,
/// per task — the same shape the backend stores.
class _FakeActivityRepository extends ActivityRepository {
  _FakeActivityRepository(this.rows);

  final List<TaskModel> rows;

  /// Every write the provider issued, in order.
  final List<Map<String, Object?>> writes = [];

  int _seq = 0;

  @override
  Future<List<TaskModel>> activities(String childId, {DateTime? date}) async => rows
      .where((TaskModel t) => t.childId == childId && (date == null || t.date == _key(date)))
      .toList();

  @override
  Future<TaskModel> createActivity(String childId, Map<String, dynamic> payload) async {
    writes.add({'op': 'create', ...payload});
    final TaskModel created = TaskModel(
      id: 'server-${_seq++}',
      title: payload['title'] as String? ?? '',
      icon: payload['icon'] as String? ?? 'sparkle',
      category: payload['category'] as String? ?? 'Routine',
      time: payload['time'] as String? ?? '',
      coins: payload['coins'] as int? ?? 0,
      status: TaskStatus.values.byName(payload['status'] as String? ?? TaskStatus.pending.name),
      childId: childId,
      date: payload['date'] as String? ?? '',
    );
    rows.add(created);
    return created;
  }

  @override
  Future<TaskModel> updateActivity(
    String childId,
    String activityId,
    Map<String, dynamic> payload,
  ) async {
    writes.add({'op': 'update', 'id': activityId, ...payload});
    final int i = rows.indexWhere((TaskModel t) => t.id == activityId);
    final TaskModel current = rows[i];
    final TaskModel updated = current.copyWith(
      status: payload['status'] == null
          ? current.status
          : TaskStatus.values.byName(payload['status'] as String),
    );
    rows[i] = updated;
    return updated;
  }

  @override
  Future<void> deleteActivity(String childId, String activityId) async {
    writes.add({'op': 'delete', 'id': activityId});
    rows.removeWhere((TaskModel t) => t.id == activityId);
  }

  static String _key(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

TaskModel _task({
  required String id,
  required String childId,
  required String title,
  required String date,
  TaskStatus status = TaskStatus.pending,
  int coins = 5,
}) => TaskModel(
  id: id,
  title: title,
  icon: 'sparkle',
  category: 'Morning routine',
  time: '7:00 AM',
  coins: coins,
  status: status,
  childId: childId,
  date: date,
);

void main() {
  const String childId = 'c-1';
  final DateTime day1 = DateTime(2026, 8, 10, 7, 30);
  final DateTime day2 = DateTime(2026, 8, 11, 8, 15);

  group('Daily task completion', () {
    test('Day 1: tick is stored with Day 1 date and counts as done', () async {
      final _FakeActivityRepository repo = _FakeActivityRepository(<TaskModel>[
        _task(id: 'a1', childId: childId, title: 'Brush Teeth', date: '2026-08-10'),
        _task(id: 'a2', childId: childId, title: 'Make the bed', date: '2026-08-10'),
      ]);
      DateTime clock = day1;
      final TaskProvider provider = TaskProvider(repository: repo, now: () => clock);

      await provider.loadFor(childId);
      expect(provider.dayFor(childId), '2026-08-10');
      expect(provider.completedCount(childId), 0);

      final String brushTeeth = provider
          .tasksFor(childId)
          .firstWhere((TaskModel t) => t.title == 'Brush Teeth')
          .id;
      await provider.toggle(brushTeeth);

      // Shown as completed for today only.
      expect(provider.completedCount(childId), 1);
      expect(
        provider
            .tasksFor(childId)
            .firstWhere((TaskModel t) => t.title == 'Brush Teeth')
            .isCompletedOnDay(day1),
        isTrue,
      );

      // Persisted against Day 1.
      final TaskModel stored = repo.rows.firstWhere((TaskModel t) => t.title == 'Brush Teeth');
      expect(stored.status, TaskStatus.completed);
      expect(stored.date, '2026-08-10');
    });

    test('Day 2: same task appears unchecked, then records a new completion', () async {
      final _FakeActivityRepository repo = _FakeActivityRepository(<TaskModel>[
        _task(
          id: 'a1',
          childId: childId,
          title: 'Brush Teeth',
          date: '2026-08-10',
          status: TaskStatus.completed,
        ),
      ]);
      DateTime clock = day2;
      final TaskProvider provider = TaskProvider(repository: repo, now: () => clock);

      // --- Day 2 load: the previous day is stale and must be re-read.
      expect(provider.isStale(childId), isTrue);
      await provider.loadFor(childId);

      expect(provider.dayFor(childId), '2026-08-11');

      // Requirement 3 + 8: shows as NOT COMPLETED on the new day.
      final List<TaskModel> day2Tasks = provider.tasksFor(childId);
      expect(day2Tasks, hasLength(1));
      final TaskModel today = day2Tasks.first;
      expect(today.title, 'Brush Teeth');
      expect(today.status, TaskStatus.pending);
      expect(today.isCompletedOnDay(day2), isFalse);
      expect(provider.completedCount(childId), 0);
      expect(provider.progress(childId), 0);

      // Requirement 2: yesterday must not leak into today.
      expect(today.isCompletedOn('2026-08-10'), isFalse);

      // Child checks it again -> a NEW completion for Day 2.
      await provider.toggle(today.id);
      expect(provider.completedCount(childId), 1);
      expect(provider.tasksFor(childId).first.isCompletedOnDay(day2), isTrue);

      final List<TaskModel> todayRows = repo.rows
          .where((TaskModel t) => t.date == '2026-08-11')
          .toList();
      expect(todayRows, hasLength(1));
      expect(todayRows.first.status, TaskStatus.completed);
      expect(todayRows.first.isPlanned, isFalse);

      // Requirement 4: Day 1's completion survives as history.
      final TaskModel yesterday = repo.rows.firstWhere((TaskModel t) => t.date == '2026-08-10');
      expect(yesterday.status, TaskStatus.completed);
      expect(repo.rows, hasLength(2));
    });

    test('a day with no rows projects the routine without writing records', () async {
      final _FakeActivityRepository repo = _FakeActivityRepository(<TaskModel>[
        _task(
          id: 'a1',
          childId: childId,
          title: 'Brush Teeth',
          date: '2026-08-09',
          status: TaskStatus.completed,
        ),
        _task(
          id: 'a2',
          childId: childId,
          title: 'Make the bed',
          date: '2026-08-09',
          status: TaskStatus.completed,
        ),
      ]);
      final TaskProvider provider = TaskProvider(
        repository: repo,
        now: () => DateTime(2026, 8, 11),
      );

      await provider.loadFor(childId);

      // Routine comes from the most recent earlier day, projected onto today.
      expect(provider.tasksFor(childId), hasLength(2));
      expect(provider.tasksFor(childId).every((TaskModel t) => t.date == '2026-08-11'), isTrue);
      expect(provider.tasksFor(childId).every((TaskModel t) => t.isPlanned), isTrue);
      expect(provider.completedCount(childId), 0);

      // Requirement 10: reading a new day must not duplicate task records.
      expect(repo.rows, hasLength(2));
      expect(repo.writes, isEmpty);
    });

    test('future-dated rows never leak into an earlier day', () async {
      final _FakeActivityRepository repo = _FakeActivityRepository(<TaskModel>[
        _task(id: 'a1', childId: childId, title: 'Scheduled ahead', date: '2026-08-20'),
      ]);
      final TaskProvider provider = TaskProvider(
        repository: repo,
        now: () => DateTime(2026, 8, 11),
      );

      await provider.loadFor(childId);

      expect(provider.tasksFor(childId), isEmpty);
    });

    test('toggle never flips a row from another calendar day', () async {
      final _FakeActivityRepository repo = _FakeActivityRepository(<TaskModel>[
        _task(id: 'a1', childId: childId, title: 'Yesterday', date: '2026-08-10'),
      ]);
      DateTime clock = DateTime(2026, 8, 11);
      final TaskProvider provider = TaskProvider(repository: repo, now: () => clock);
      await provider.loadFor(childId);

      // 'a1' is not in today's list, so it cannot be toggled at all.
      await provider.toggle('a1');

      expect(repo.rows.first.status, TaskStatus.pending);
      expect(repo.writes, isEmpty);
    });

    test('completion from yesterday does not award coins for today', () async {
      final _FakeActivityRepository repo = _FakeActivityRepository(<TaskModel>[
        _task(
          id: 'a1',
          childId: childId,
          title: 'Brush Teeth',
          date: '2026-08-10',
          status: TaskStatus.completed,
        ),
      ]);
      DateTime clock = day2;
      final TaskProvider provider = TaskProvider(repository: repo, now: () => clock);

      await provider.loadFor(childId);
      // The projected task inherits no completion, so today's coin progress
      // starts at zero despite yesterday being completed.
      expect(provider.progress(childId), 0);
      expect(provider.completedCount(childId), 0);

      await provider.toggle(provider.tasksFor(childId).first.id);
      expect(repo.writes.where((Map<String, Object?> w) => w['op'] == 'update'), isEmpty);
      expect(repo.writes.single['date'], '2026-08-11');
    });

    test('day rollover is detected for a list left open overnight', () async {
      final _FakeActivityRepository repo = _FakeActivityRepository(<TaskModel>[
        _task(
          id: 'a1',
          childId: childId,
          title: 'Brush Teeth',
          date: '2026-08-10',
          status: TaskStatus.completed,
        ),
      ]);
      DateTime clock = day1;
      final TaskProvider provider = TaskProvider(repository: repo, now: () => clock);

      await provider.loadFor(childId);
      expect(provider.completedCount(childId), 1);
      expect(provider.isStale(childId), isFalse);

      // Midnight passes without the app being restarted.
      clock = day2;
      expect(provider.isStale(childId), isTrue);

      await provider.ensureCurrentDay(childId);
      expect(provider.completedCount(childId), 0);
      expect(provider.tasksFor(childId).first.status, TaskStatus.pending);
    });

    test('toggle reports the new state so rewards stay correct', () async {
      final _FakeActivityRepository repo = _FakeActivityRepository(<TaskModel>[
        _task(
          id: 'a1',
          childId: childId,
          title: 'Brush Teeth',
          date: '2026-08-10',
          status: TaskStatus.completed,
          coins: 7,
        ),
      ]);
      DateTime clock = day2;
      final TaskProvider provider = TaskProvider(repository: repo, now: () => clock);

      await provider.loadFor(childId);
      final TaskModel projected = provider.tasksFor(childId).single;

      // The projected task gets a brand new id, so callers must be able to
      // read the resulting state from the return value.
      final TaskModel? completed = await provider.toggle(projected.id);
      expect(completed, isNotNull);
      expect(completed!.id, isNot(projected.id));
      expect(completed.status, TaskStatus.completed);
      expect(completed.isCompletedOnDay(day2), isTrue);
      expect(completed.coins, 7);

      // Un-ticking today's real row still round-trips.
      final TaskModel? reopened = await provider.toggle(completed.id);
      expect(reopened!.status, TaskStatus.pending);
      expect(provider.completedCount(childId), 0);
    });

    test('reloading on the same day does not refetch', () async {
      final _FakeActivityRepository repo = _FakeActivityRepository(<TaskModel>[
        _task(id: 'a1', childId: childId, title: 'Brush Teeth', date: '2026-08-10'),
      ]);
      int calls = 0;
      final TaskProvider provider = TaskProvider(
        repository: _CountingRepository(repo, () => calls++),
        now: () => day1,
      );

      await provider.loadFor(childId);
      await provider.loadFor(childId);
      expect(calls, 1);
    });
  });
}

/// Wraps the fake so the test can count fetches.
class _CountingRepository extends ActivityRepository {
  _CountingRepository(this._inner, this._onFetch);

  final _FakeActivityRepository _inner;
  final void Function() _onFetch;

  @override
  Future<List<TaskModel>> activities(String childId, {DateTime? date}) {
    _onFetch();
    return _inner.activities(childId, date: date);
  }

  @override
  Future<TaskModel> createActivity(String childId, Map<String, dynamic> payload) =>
      _inner.createActivity(childId, payload);

  @override
  Future<TaskModel> updateActivity(
    String childId,
    String activityId,
    Map<String, dynamic> payload,
  ) => _inner.updateActivity(childId, activityId, payload);

  @override
  Future<void> deleteActivity(String childId, String activityId) =>
      _inner.deleteActivity(childId, activityId);
}
