import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/child_model.dart';
import '../../models/task_model.dart';
import '../../providers/child_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/child_avatar.dart';
import '../../widgets/common/error_state_widget.dart'
    show showAppError, showAppSnackBar, showConfirmDialog;
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/world_screen.dart';
import '../activities/task_form_dialog.dart';
import 'pin_change_dialog.dart';

/// Manages tasks for a specific child: view, add, edit, delete tasks.
class ChildTaskManagementScreen extends StatefulWidget {
  const ChildTaskManagementScreen({super.key, required this.childId, this.child});

  final String childId;

  /// The child identity carried from the caller. Falls back to the loaded
  /// children list so the header never collapses to a bare "Child tasks".
  final ChildModel? child;

  @override
  State<ChildTaskManagementScreen> createState() => _ChildTaskManagementScreenState();
}

class _ChildTaskManagementScreenState extends State<ChildTaskManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TaskProvider>().loadFor(widget.childId);
    });
  }

  ChildModel? _child(BuildContext context) {
    return widget.child ?? context.read<ChildProvider>().childById(widget.childId);
  }

  Future<void> _addTask() async {
    final TaskModel? result = await showDialog<TaskModel>(
      context: context,
      builder: (_) => TaskFormDialog(childId: widget.childId),
    );
    if (result == null || !mounted) return;

    final TaskProvider provider = context.read<TaskProvider>();
    try {
      await provider.createTask(widget.childId, {
        'title': result.title,
        'icon': result.icon,
        'category': result.category,
        'time': result.time,
        'coins': result.coins,
        'status': result.status.name,
        'date': Formatters.apiDate(DateTime.now()),
      });
      if (!mounted) return;
      if (provider.error != null) {
        showAppError(context, provider.error);
      } else {
        showAppSnackBar(context, 'Task added!');
      }
    } catch (e) {
      if (mounted) showAppError(context, e);
    }
  }

  Future<void> _editTask(TaskModel task) async {
    final TaskModel? result = await showDialog<TaskModel>(
      context: context,
      builder: (_) => TaskFormDialog(task: task, childId: widget.childId),
    );
    if (result == null || !mounted) return;

    final TaskProvider provider = context.read<TaskProvider>();
    try {
      await provider.updateTask(widget.childId, task.id, {
        'title': result.title,
        'icon': result.icon,
        'category': result.category,
        'time': result.time,
        'coins': result.coins,
        'status': result.status.name,
      });
      if (!mounted) return;
      if (provider.error != null) {
        showAppError(context, provider.error);
      } else {
        showAppSnackBar(context, 'Task updated!');
      }
    } catch (e) {
      if (mounted) showAppError(context, e);
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Delete Task',
      message: 'Are you sure you want to delete "${task.title}"?',
      confirmLabel: 'Delete',
      danger: true,
    );
    if (!confirmed || !mounted) return;

    final TaskProvider provider = context.read<TaskProvider>();
    try {
      await provider.deleteTask(widget.childId, task.id);
      if (!mounted) return;
      if (provider.error != null) {
        showAppError(context, provider.error);
      } else {
        showAppSnackBar(context, 'Task deleted.');
      }
    } catch (e) {
      if (mounted) showAppError(context, e);
    }
  }

  void _changePin() {
    final ChildModel? child = _child(context);
    if (child == null) return;
    showDialog(
      context: context,
      builder: (_) => PinChangeDialog(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.sch;
    final ThemeData theme = Theme.of(context);
    final ChildModel? child = _child(context);
    final TaskProvider taskProvider = context.watch<TaskProvider>();
    final List<TaskModel> tasks = taskProvider.tasksFor(widget.childId);

    return WorldScreen(
      title: '${child?.name ?? 'Child'} tasks',
      subtitle: 'Manage daily tasks',
      child: Column(
        children: [
          if (child != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  ChildAvatar(
                    name: child.name,
                    avatarKey: child.avatarKey,
                    size: 48,
                    photoUrl: child.photoUrl,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${tasks.length} tasks  ·  ${child.coins} coins',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Change PIN',
                    onPressed: _changePin,
                    icon: const AppIcon(AppIcons.shield, size: 22),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SectionHeader(title: 'Tasks', subtitle: '${tasks.length} assigned'),
              ),
              PrimaryButton(
                label: 'Add Task',
                icon: AppIcons.plus,
                expanded: false,
                onPressed: _addTask,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: taskProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : taskProvider.error != null && tasks.isEmpty
                ? _TaskLoadError(
                    message: taskProvider.error!,
                    onRetry: () {
                      final TaskProvider provider = context.read<TaskProvider>();
                      provider.clearError();
                      provider.loadFor(widget.childId);
                    },
                  )
                : tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(
                            AppIcons.tasks,
                            size: 48,
                            color: palette.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: palette.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add a task to get started!',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: palette.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final TaskModel task = tasks[index];
                      return _TaskItem(
                        task: task,
                        onEdit: () => _editTask(task),
                        onDelete: () => _deleteTask(task),
                        onToggle: () async {
                          final TaskProvider tp = taskProvider;
                          await tp.toggle(task.id);
                          final String? err = tp.error;
                          if (err != null && context.mounted) {
                            showAppError(context, err);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  const _TaskItem({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final TaskModel task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;
    final bool done = task.status == TaskStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: done ? palette.successContainer.withValues(alpha: 0.35) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            InkWell(
              onTap: onToggle,
              customBorder: const CircleBorder(),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? palette.success : Colors.transparent,
                  border: done ? null : Border.all(color: palette.primary, width: 2),
                ),
                child: done ? Icon(Icons.check, size: 18, color: palette.onTertiary) : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${task.category} · ${task.time.isNotEmpty ? task.time : 'Any time'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: palette.secondaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AppIcon(AppIcons.coin, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    '+${task.coins}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: palette.onSecondaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskLoadError extends StatelessWidget {
  const _TaskLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.sch;
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(AppIcons.info, size: 48, color: palette.error.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text(
              'Couldn’t load tasks',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: palette.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
