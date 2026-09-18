import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/exercise_data.dart';
import '../../data/models/exercise_entry.dart';
import '../providers/providers.dart';

class AddExercisePage extends ConsumerStatefulWidget {
  const AddExercisePage({super.key});

  @override
  ConsumerState<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends ConsumerState<AddExercisePage> {
  final _searchController = TextEditingController();
  ExerciseType? _selectedType;
  ExerciseData? _selectedExercise;
  final _durationController = TextEditingController(text: '30');

  @override
  void dispose() {
    _searchController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(exerciseSearchQueryProvider);
    final searchResults = ref.watch(exerciseSearchResultsProvider);
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('添加运动'),
        backgroundColor: AppColors.background,
        actions: [
          if (_selectedExercise != null)
            TextButton(
              onPressed: _saveEntry,
              child: const Text('保存'),
            ),
        ],
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索运动...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textHint),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(exerciseSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(exerciseSearchQueryProvider.notifier).state = value;
              },
            ),
          ),

          // 类型筛选
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('全部'),
                    selected: _selectedType == null,
                    onSelected: (_) {
                      setState(() => _selectedType = null);
                    },
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.accent.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: _selectedType == null ? AppColors.accent : AppColors.textSecondary,
                    ),
                  ),
                ),
                ...ExerciseType.values.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type.displayName),
                      selected: _selectedType == type,
                      onSelected: (selected) {
                        setState(() => _selectedType = selected ? type : null);
                      },
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.accent.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: _selectedType == type ? AppColors.accent : AppColors.textSecondary,
                      ),
                      checkmarkColor: AppColors.accent,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 运动列表
          Expanded(
            child: _selectedExercise == null
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final exercise = searchResults[index];
                      if (_selectedType != null && exercise.type != _selectedType) {
                        return const SizedBox.shrink();
                      }
                      return _ExerciseListItem(
                        exercise: exercise,
                        onTap: () {
                          setState(() {
                            _selectedExercise = exercise;
                          });
                        },
                      );
                    },
                  )
                : _ExerciseDetailInput(
                    exercise: _selectedExercise!,
                    durationController: _durationController,
                    userWeight: userProfile.weight,
                    onBack: () {
                      setState(() => _selectedExercise = null);
                    },
                    onDurationChanged: (value) {
                      setState(() {});
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _saveEntry() {
    if (_selectedExercise == null) return;

    final duration = int.tryParse(_durationController.text) ?? 30;
    final userProfile = ref.read(userProfileProvider);
    final caloriesBurned = _selectedExercise!.calculateCalories(userProfile.weight, duration);

    final entry = ExerciseEntry(
      id: generateId(),
      userId: 'current_user',
      name: _selectedExercise!.name,
      type: _selectedExercise!.type,
      duration: duration,
      caloriesBurned: caloriesBurned,
      muscleGroups: _selectedExercise!.muscleGroups,
      timestamp: DateTime.now(),
    );

    ref.read(exerciseEntriesProvider.notifier).addEntry(entry);
    Navigator.pop(context);
  }
}

class _ExerciseListItem extends StatelessWidget {
  final ExerciseData exercise;
  final VoidCallback onTap;

  const _ExerciseListItem({required this.exercise, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${exercise.type.displayName} · MET ${exercise.met}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (exercise.muscleGroups.isNotEmpty)
              Wrap(
                children: exercise.muscleGroups.take(2).map((mg) => Text(
                  '${mg.icon} ',
                  style: const TextStyle(fontSize: 16),
                )).toList(),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _ExerciseDetailInput extends StatelessWidget {
  final ExerciseData exercise;
  final TextEditingController durationController;
  final double userWeight;
  final VoidCallback onBack;
  final ValueChanged<String> onDurationChanged;

  const _ExerciseDetailInput({
    required this.exercise,
    required this.durationController,
    required this.userWeight,
    required this.onBack,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    final duration = int.tryParse(durationController.text) ?? 30;
    final caloriesBurned = exercise.calculateCalories(userWeight, duration);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 返回按钮
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            label: const Text('重新选择'),
          ),
          const SizedBox(height: 16),

          // 运动信息卡片
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  exercise.type.displayName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 时长输入
          const Text(
            '运动时长',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    suffixText: '分钟',
                  ),
                  onChanged: onDurationChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 快速时长按钮
          Wrap(
            spacing: 8,
            children: [15, 30, 45, 60].map((mins) {
              return ActionChip(
                label: Text('$mins分钟'),
                onPressed: () {
                  durationController.text = mins.toString();
                  onDurationChanged(mins.toString());
                },
                backgroundColor: AppColors.surface,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 消耗热量预览
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: AppColors.accent,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '预计消耗',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$caloriesBurned kcal',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 锻炼肌肉群
          if (exercise.muscleGroups.isNotEmpty) ...[
            const Text(
              '锻炼肌肉群',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exercise.muscleGroups.map((mg) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(mg.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        mg.displayName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
