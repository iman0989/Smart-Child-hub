import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_icons.dart';
import '../../core/services/dashboard_loader.dart';
import '../../core/theme/app_colors.dart';
import '../../models/homework_model.dart';
import '../../providers/child_provider.dart';
import '../../providers/homework_provider.dart';
import '../../widgets/cards/dashboard_card.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/error_state_widget.dart' show showAppError, showAppSnackBar;
import '../../widgets/common/linear_progress_widget.dart';
import '../../widgets/common/status_pill.dart';
import '../../widgets/common/world_screen.dart';

/// Homework: assignments, progress, coin rewards.
class HomeworkScreen extends StatelessWidget {
  const HomeworkScreen({super.key});

  Future<void> _addHomework(BuildContext context, HomeworkProvider provider, String childId) async {
    final HomeworkModel? item = await showModalBottomSheet<HomeworkModel>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddHomeworkSheet(childId: childId),
    );
    if (item == null) return;
    await provider.addHomework(item);
    if (context.mounted) {
      if (provider.error != null) {
        showAppError(context, provider.error);
      } else {
        showAppSnackBar(context, '${item.title} added');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final HomeworkProvider provider = context.watch<HomeworkProvider>();
    final String childId = context.watch<ChildProvider>().selectedChildId ?? '';
    final List<HomeworkModel> list = provider.homeworkFor(childId);
    final double progress = provider.progressFor(childId);

    return WorldScreen(
      title: 'Homework',
      subtitle: 'School tasks',
      actions: [
        IconButton(
          tooltip: 'Add homework',
          onPressed: () => _addHomework(context, provider, childId),
          icon: const AppIcon(AppIcons.plus),
        ),
        const NotificationBellAction(),
      ],
      child: RefreshIndicator(
        onRefresh: () => loadDashboardData(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            DashboardCard(
              title: 'Completion',
              icon: AppIcons.medal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progress * 100).round()}% done',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${provider.completedFor(childId).length}/${list.length} tasks',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressWidget(value: progress, height: 10, color: const Color(0xFF1FBFA0)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            DashboardCard(
              title: 'Assignments',
              icon: AppIcons.homework,
              child: list.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No homework assigned.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (final HomeworkModel item in list)
                          _HomeworkRow(
                            item: item,
                            onToggle: () async {
                              await provider.toggleComplete(item.id);
                              if (context.mounted && provider.error != null) {
                                showAppError(context, provider.error);
                              }
                            },
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeworkRow extends StatelessWidget {
  const _HomeworkRow({required this.item, required this.onToggle});

  final HomeworkModel item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final int daysLeft = item.dueDate.difference(DateTime.now()).inDays;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          InkWell(
            onTap: onToggle,
            customBorder: const CircleBorder(),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.isCompleted ? context.sch.success : Colors.transparent,
                border: item.isCompleted
                    ? null
                    : Border.all(color: theme.colorScheme.outlineVariant, width: 2),
              ),
              child: item.isCompleted
                  ? Icon(Icons.check, size: 16, color: context.sch.onTertiary)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E7FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AppIcon(item.icon, size: 20, color: const Color(0xFF2A3DB5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.subject} · due ${daysLeft <= 0 ? 'today' : 'in $daysLeft d'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusPill(
            label: item.status.label,
            color: item.isCompleted
                ? context.sch.success
                : item.status == HomeworkStatus.inProgress
                ? const Color(0xFF4359E0)
                : context.sch.warning,
          ),
        ],
      ),
    );
  }
}

class _AddHomeworkSheet extends StatefulWidget {
  const _AddHomeworkSheet({required this.childId});

  final String childId;

  @override
  State<_AddHomeworkSheet> createState() => _AddHomeworkSheetState();
}

class _AddHomeworkSheetState extends State<_AddHomeworkSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  String _icon = AppIcons.book;

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _save() {
    final String title = _titleController.text.trim();
    if (title.isEmpty) return;
    final HomeworkModel item = HomeworkModel(
      id: 'hw-${DateTime.now().millisecondsSinceEpoch}',
      childId: widget.childId,
      title: title,
      subject: _subjectController.text.trim().isEmpty ? 'School' : _subjectController.text.trim(),
      icon: _icon,
      dueDate: DateTime.now().add(const Duration(days: 2)),
    );
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add homework', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final String icon in const [
                AppIcons.book,
                AppIcons.homework,
                AppIcons.paint,
                AppIcons.music,
                AppIcons.pets,
                AppIcons.plants,
              ])
                ChoiceChip(
                  avatar: AppIcon(icon, size: 16),
                  label: Text(icon.split('_').first),
                  selected: _icon == icon,
                  onSelected: (_) => setState(() => _icon = icon),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Assignment',
              hintText: 'e.g. Math worksheet 4',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Subject', hintText: 'e.g. Math'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: const Text('Add assignment'),
          ),
        ],
      ),
    );
  }
}
