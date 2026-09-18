import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/food_entry.dart';
import '../../data/models/nutrition_info.dart';
import '../providers/providers.dart';
import '../widgets/nutrition_widgets.dart';
import 'package:intl/intl.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final userProfile = ref.watch(userProfileProvider);
    final dailyGoals = userProfile.dailyGoals;

    // Get entries for selected date
    final allFoodEntries = ref.watch(foodEntriesProvider);
    final dayFoodEntries = allFoodEntries.where((e) =>
      e.timestamp.year == selectedDate.year &&
      e.timestamp.month == selectedDate.month &&
      e.timestamp.day == selectedDate.day
    ).toList();
    final dayNutrition = dayFoodEntries.fold<NutritionInfo>(
      NutritionInfo.zero, (sum, e) => sum + e.nutrition);

    final allExerciseEntries = ref.watch(exerciseEntriesProvider);
    final dayExerciseEntries = allExerciseEntries.where((e) =>
      e.timestamp.year == selectedDate.year &&
      e.timestamp.month == selectedDate.month &&
      e.timestamp.day == selectedDate.day
    ).toList();
    final dayCaloriesBurned = dayExerciseEntries.fold<int>(0, (sum, e) => sum + e.caloriesBurned);

    final isToday = _isToday(selectedDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部问候
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isToday ? _getGreeting() : DateFormat('M月d日').format(selectedDate),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userProfile.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          ref.read(selectedDateProvider.notifier).state =
                            selectedDate.subtract(const Duration(days: 1));
                        },
                        icon: const Icon(Icons.chevron_left),
                      ),
                      TextButton(
                        onPressed: isToday ? null : () {
                          ref.read(selectedDateProvider.notifier).state = DateTime.now();
                        },
                        child: Text(isToday ? '今天' : '回到今天'),
                      ),
                      IconButton(
                        onPressed: isToday ? null : () {
                          ref.read(selectedDateProvider.notifier).state =
                            selectedDate.add(const Duration(days: 1));
                        },
                        icon: const Icon(Icons.chevron_right),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 热量卡片
              CalorieCard(
                consumed: dayNutrition.calories.round(),
                goal: dailyGoals.calories,
                burned: dayCaloriesBurned,
              ),
              const SizedBox(height: 24),

              // 营养素进度
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '营养摄入',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        NutritionRing(
                          label: '蛋白质',
                          current: dayNutrition.protein,
                          goal: dailyGoals.protein,
                          color: AppColors.proteinColor,
                        ),
                        NutritionRing(
                          label: '脂肪',
                          current: dayNutrition.fat,
                          goal: dailyGoals.fat,
                          color: AppColors.fatColor,
                        ),
                        NutritionRing(
                          label: '碳水',
                          current: dayNutrition.carbs,
                          goal: dailyGoals.carbs,
                          color: AppColors.carbsColor,
                        ),
                        NutritionRing(
                          label: '纤维',
                          current: dayNutrition.fiber,
                          goal: dailyGoals.fiber,
                          color: AppColors.fiberColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 今日饮食
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isToday ? '今日饮食' : '饮食记录',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/food'),
                    child: const Text('查看全部'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...MealType.values.map((mealType) {
                final mealEntries = dayFoodEntries
                    .where((e) => e.mealType == mealType)
                    .toList();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MealCard(
                    mealType: mealType,
                    entries: mealEntries,
                    onAddTap: () => Navigator.pushNamed(
                      context,
                      '/add-food',
                      arguments: {'mealType': mealType},
                    ),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/food',
                      arguments: {'mealType': mealType},
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // 今日运动
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isToday ? '今日运动' : '运动记录',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/exercise'),
                    child: const Text('查看全部'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _TodayExerciseCard(
                entries: dayExerciseEntries,
                totalCalories: dayCaloriesBurned,
                onAddTap: () => Navigator.pushNamed(context, '/add-exercise'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickAddSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '早上好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  void _showQuickAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textHint.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '快速添加',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _QuickAddButton(
                    icon: Icons.restaurant,
                    label: '饮食',
                    color: AppColors.caloriesColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/add-food');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickAddButton(
                    icon: Icons.fitness_center,
                    label: '运动',
                    color: AppColors.accent,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/add-exercise');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _TodayExerciseCard extends StatelessWidget {
  final List entries;
  final int totalCalories;
  final VoidCallback onAddTap;

  const _TodayExerciseCard({
    required this.entries,
    required this.totalCalories,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: entries.isEmpty
          ? GestureDetector(
              onTap: onAddTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.textHint.withValues(alpha: 0.2),
                  ),
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: AppColors.textHint),
                      SizedBox(width: 8),
                      Text(
                        '添加运动记录',
                        style: TextStyle(color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: AppColors.accent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '今日消耗',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '$totalCalories kcal',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...entries.take(3).map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${entry.duration}分钟 · ${entry.caloriesBurned}kcal',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
