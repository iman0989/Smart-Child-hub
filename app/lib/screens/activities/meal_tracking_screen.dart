import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_icons.dart';
import '../../core/services/dashboard_loader.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/meal_model.dart';
import '../../providers/child_provider.dart';
import '../../providers/meal_provider.dart';
import '../../widgets/cards/dashboard_card.dart';
import '../../widgets/common/app_icon.dart';
import '../../widgets/common/error_state_widget.dart' show showAppError, showAppSnackBar;
import '../../widgets/common/linear_progress_widget.dart';
import '../../widgets/common/status_pill.dart';
import '../../widgets/common/world_screen.dart';

/// Meal tracking: today's meals, nutrition summary, add-meal flow.
class MealTrackingScreen extends StatelessWidget {
  const MealTrackingScreen({super.key});

  Future<void> _addMeal(BuildContext context, MealProvider provider, String childId) async {
    final MealModel? meal = await showModalBottomSheet<MealModel>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddMealSheet(childId: childId),
    );
    if (meal == null) return;
    await provider.addMeal(meal);
    if (context.mounted) {
      if (provider.error != null) {
        showAppError(context, provider.error);
      } else {
        showAppSnackBar(context, '${meal.name} added');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppPalette palette = context.sch;
    final MealProvider provider = context.watch<MealProvider>();
    final String childId = context.watch<ChildProvider>().selectedChildId ?? '';
    final DateTime today = DateTime.now();
    final List<MealModel> meals = provider.mealsFor(childId, date: today);

    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;
    for (final MealModel meal in meals) {
      if (meal.eaten) {
        totalCalories += meal.calories;
        totalProtein += meal.protein;
        totalCarbs += meal.carbs;
        totalFat += meal.fat;
      }
    }

    return WorldScreen(
      title: 'Meals',
      subtitle: Formatters.shortDate(today),
      actions: [
        IconButton(
          tooltip: 'Add meal',
          onPressed: () => _addMeal(context, provider, childId),
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
              title: 'Today’s meals',
              icon: AppIcons.food,
              child: Column(
                children: [
                  for (final MealModel meal in meals)
                    _MealRow(
                      meal: meal,
                      onToggle: () async {
                        await provider.toggleEaten(meal.id);
                        if (context.mounted && provider.error != null) {
                          showAppError(context, provider.error);
                        }
                      },
                    ),
                  if (meals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No meals logged today yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: palette.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            DashboardCard(
              title: 'Nutrition summary',
              subtitle: 'Eaten meals only',
              icon: AppIcons.chart,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Calories', style: theme.textTheme.titleSmall),
                      Text(
                        '$totalCalories kcal',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _NutrientBar(
                    label: 'Protein',
                    value: totalProtein,
                    max: 40,
                    unit: 'g',
                    color: context.sch.grape,
                  ),
                  const SizedBox(height: 12),
                  _NutrientBar(
                    label: 'Carbs',
                    value: totalCarbs,
                    max: 180,
                    unit: 'g',
                    color: context.sch.warning,
                  ),
                  const SizedBox(height: 12),
                  _NutrientBar(
                    label: 'Fat',
                    value: totalFat,
                    max: 55,
                    unit: 'g',
                    color: const Color(0xFFFF7BA9),
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

class _MealRow extends StatelessWidget {
  const _MealRow({required this.meal, required this.onToggle});

  final MealModel meal;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
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
                color: meal.eaten ? context.sch.success : Colors.transparent,
                border: meal.eaten
                    ? null
                    : Border.all(color: theme.colorScheme.outlineVariant, width: 2),
              ),
              child: meal.eaten ? Icon(Icons.check, size: 16, color: context.sch.onTertiary) : null,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: context.sch.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AppIcon(meal.type.icon, size: 20, color: context.sch.onSecondaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${meal.type.label} · ${meal.name}',
                  style: theme.textTheme.bodyLarge?.copyWith(decoration: meal.eaten ? null : null),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${meal.time} · ${meal.calories} kcal',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          StatusPill(
            label: meal.eaten ? 'Eaten' : 'Missed',
            color: meal.eaten ? context.sch.success : context.sch.warning,
          ),
        ],
      ),
    );
  }
}

class _NutrientBar extends StatelessWidget {
  const _NutrientBar({
    required this.label,
    required this.value,
    required this.max,
    required this.unit,
    required this.color,
  });

  final String label;
  final int value;
  final int max;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Text(
              '$value$unit / $max$unit',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressWidget(value: max == 0 ? 0 : value / max, height: 8, color: color),
      ],
    );
  }
}

class _AddMealSheet extends StatefulWidget {
  const _AddMealSheet({required this.childId});

  final String childId;

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  MealType _type = MealType.lunch;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _save() {
    final String name = _nameController.text.trim();
    if (name.isEmpty) return;
    final MealModel meal = MealModel(
      id: 'm-${DateTime.now().millisecondsSinceEpoch}',
      childId: widget.childId,
      date: DateTime.now(),
      type: _type,
      name: name,
      icon: _type.icon,
      time: Formatters.timeOfDay(DateTime.now()),
      calories: int.tryParse(_caloriesController.text) ?? 0,
      eaten: true,
    );
    Navigator.of(context).pop(meal);
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
          Text('Add meal', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final MealType type in MealType.values)
                ChoiceChip(
                  avatar: AppIcon(type.icon, size: 16),
                  label: Text(type.label),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Meal name',
              hintText: 'e.g. Yogurt with honey',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _caloriesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Calories', hintText: 'e.g. 250'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: const Text('Add meal'),
          ),
        ],
      ),
    );
  }
}
