import 'package:flutter/material.dart';

import '../../core/constants/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../models/task_model.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/common/secondary_button.dart';

/// Create / edit a task for a specific child. Returns the resulting
/// [TaskModel] or null if cancelled.
class TaskFormDialog extends StatefulWidget {
  const TaskFormDialog({super.key, this.task, required this.childId});

  final TaskModel? task;
  final String childId;

  @override
  State<TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  static const List<String> _icons = [
    'sparkle',
    'book',
    'food',
    'run',
    'bed',
    'water',
    'sun',
    'moon',
    'target',
    'homework',
    'edit',
    'plants',
  ];

  static const List<String> _categories = [
    'Routine',
    'Morning routine',
    'Evening routine',
    'Learning & fun',
    'Chores',
    'Health',
    'Creative',
  ];

  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _coinsController;
  late final TextEditingController _timeController;
  late String _icon;
  late String _category;
  late String _status;

  @override
  void initState() {
    super.initState();
    final TaskModel? t = widget.task;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController();
    _coinsController = TextEditingController(text: '${t?.coins ?? 5}');
    _timeController = TextEditingController(text: t?.time ?? '');
    _icon = t?.icon ?? 'sparkle';
    _category = t?.category ?? 'Routine';
    _status = t?.status.name ?? 'pending';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _coinsController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _save() {
    final String title = _titleController.text.trim();
    if (title.isEmpty) return;
    final int coins = int.tryParse(_coinsController.text.trim()) ?? 5;

    final TaskModel result = TaskModel(
      id: widget.task?.id ?? '',
      title: title,
      icon: _icon,
      category: _category,
      time: _timeController.text.trim(),
      coins: coins,
      status: TaskStatus.values.byName(_status),
      childId: widget.childId,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;

    return AlertDialog(
      title: Text(
        widget.task == null ? 'Add Task' : 'Edit Task',
        style: theme.textTheme.titleLarge,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _titleController,
              label: 'Task name',
              hint: 'e.g. Brush teeth',
              prefixIcon: AppIcons.edit,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _timeController,
              label: 'Time (optional)',
              hint: 'e.g. 7:00 AM',
              prefixIcon: AppIcons.clock,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _coinsController,
              label: 'Coins reward',
              hint: '5',
              prefixIcon: AppIcons.coin,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            Text('Category', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final cat in _categories)
                  ChoiceChip(
                    label: Text(cat, style: theme.textTheme.labelSmall),
                    selected: _category == cat,
                    onSelected: (_) => setState(() => _category = cat),
                    selectedColor: palette.primaryContainer,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text('Icon', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final iconKey in _icons)
                  InkWell(
                    onTap: () => setState(() => _icon = iconKey),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _icon == iconKey
                            ? palette.primaryContainer
                            : palette.surfaceContainer,
                        shape: BoxShape.circle,
                        border: _icon == iconKey
                            ? Border.all(color: palette.primary, width: 2)
                            : null,
                      ),
                      child: AppIcon(iconKey, size: 18),
                    ),
                  ),
              ],
            ),
            if (widget.task != null) ...[
              const SizedBox(height: 14),
              Text('Status', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final s in ['pending', 'inProgress', 'completed'])
                    ChoiceChip(
                      label: Text(
                        s == 'inProgress' ? 'In progress' : s[0].toUpperCase() + s.substring(1),
                        style: theme.textTheme.labelSmall,
                      ),
                      selected: _status == s,
                      onSelected: (_) => setState(() => _status = s),
                      selectedColor: palette.primaryContainer,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        SecondaryButton(
          label: 'Cancel',
          expanded: false,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 8),
        PrimaryButton(
          label: widget.task == null ? 'Add Task' : 'Save',
          expanded: false,
          onPressed: _save,
        ),
      ],
    );
  }
}
