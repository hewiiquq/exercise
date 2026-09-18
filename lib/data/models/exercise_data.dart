import 'exercise_entry.dart';

/// 运动数据
class ExerciseData {
  final String id;
  final String name;
  final ExerciseType type;
  final double met;                      // MET值（代谢当量）
  final List<MuscleGroup> muscleGroups; // 主要锻炼的肌肉群

  const ExerciseData({
    required this.id,
    required this.name,
    required this.type,
    required this.met,
    required this.muscleGroups,
  });

  /// 根据体重和时间计算消耗热量
  /// 公式: 热量 = MET × 体重(kg) × 时间(h)
  int calculateCalories(double weightKg, int durationMinutes) {
    return (met * weightKg * durationMinutes / 60).round();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'met': met,
      'muscleGroups': muscleGroups.map((e) => e.index).toList(),
    };
  }

  factory ExerciseData.fromJson(Map<String, dynamic> json) {
    return ExerciseData(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ExerciseType.values[json['type'] as int],
      met: (json['met'] as num).toDouble(),
      muscleGroups: (json['muscleGroups'] as List)
          .map((e) => MuscleGroup.values[e as int])
          .toList(),
    );
  }
}

/// 内置运动数据库
class ExerciseDatabase {
  static const List<ExerciseData> exercises = [
    // 有氧运动 - 跑步
    ExerciseData(
      id: 'jogging_slow',
      name: '慢跑 (6km/h)',
      type: ExerciseType.cardio,
      met: 5.0,
      muscleGroups: [MuscleGroup.quadriceps, MuscleGroup.hamstrings, MuscleGroup.calves],
    ),
    ExerciseData(
      id: 'jogging_medium',
      name: '慢跑 (8km/h)',
      type: ExerciseType.cardio,
      met: 8.3,
      muscleGroups: [MuscleGroup.quadriceps, MuscleGroup.hamstrings, MuscleGroup.calves],
    ),
    ExerciseData(
      id: 'jogging_fast',
      name: '快跑 (10km/h)',
      type: ExerciseType.cardio,
      met: 10.2,
      muscleGroups: [MuscleGroup.quadriceps, MuscleGroup.hamstrings, MuscleGroup.calves],
    ),

    // 有氧运动 - 步行
    ExerciseData(
      id: 'walking_slow',
      name: '慢走 (4km/h)',
      type: ExerciseType.cardio,
      met: 2.8,
      muscleGroups: [MuscleGroup.quadriceps, MuscleGroup.calves],
    ),
    ExerciseData(
      id: 'walking_medium',
      name: '快走 (6km/h)',
      type: ExerciseType.cardio,
      met: 5.0,
      muscleGroups: [MuscleGroup.quadriceps, MuscleGroup.hamstrings, MuscleGroup.calves],
    ),

    // 有氧运动 - 骑行
    ExerciseData(
      id: 'cycling_light',
      name: '骑行 (休闲)',
      type: ExerciseType.cardio,
      met: 4.0,
      muscleGroups: [MuscleGroup.quadriceps, MuscleGroup.hamstrings],
    ),
    ExerciseData(
      id: 'cycling_medium',
      name: '骑行 (16-19km/h)',
      type: ExerciseType.cardio,
      met: 7.0,
      muscleGroups: [MuscleGroup.quadriceps, MuscleGroup.hamstrings],
    ),
    ExerciseData(
      id: 'cycling_fast',
      name: '骑行 (22-25km/h)',
      type: ExerciseType.cardio,
      met: 10.0,
      muscleGroups: [MuscleGroup.quadriceps, MuscleGroup.hamstrings],
    ),

    // 有氧运动 - 游泳
    ExerciseData(
      id: 'swimming_relaxed',
      name: '游泳 (休闲)',
      type: ExerciseType.cardio,
      met: 5.8,
      muscleGroups: [MuscleGroup.chest, MuscleGroup.shoulders, MuscleGroup.core],
    ),
    ExerciseData(
      id: 'swimming_freestyle',
      name: '游泳 (自由式)',
      type: ExerciseType.cardio,
      met: 7.0,
      muscleGroups: [MuscleGroup.chest, MuscleGroup.shoulders, MuscleGroup.core, MuscleGroup.quadriceps],
    ),
    ExerciseData(
      id: 'swimming_backstroke',
      name: '游泳 (仰泳)',
      type: ExerciseType.cardio,
      met: 7.0,
      muscleGroups: [MuscleGroup.back, MuscleGroup.shoulders, MuscleGroup.core],
    ),

    // 力量训练
    ExerciseData(
      id: 'strength_chest',
      name: '卧推/胸部训练',
      type: ExerciseType.strength,
      met: 4.0,
      muscleGroups: [MuscleGroup.chest, MuscleGroup.triceps, MuscleGroup.shoulders],
    ),
    ExerciseData(
      id: 'strength_back',
      name: '背部训练',
      type: ExerciseType.strength,
      met: 4.0,
      muscleGroups: [MuscleGroup.back, MuscleGroup.biceps],
    ),
    ExerciseData(
      id: 'strength_shoulders',
      name: '肩部训练',
      type: ExerciseType.strength,
      met: 4.0,
      muscleGroups: [MuscleGroup.shoulders, MuscleGroup.triceps],
    ),
    ExerciseData(
      id: 'strength_legs',
      name: '腿部训练',
      type: ExerciseType.strength,
      met: 5.0,
      muscleGroups: [MuscleGroup.quadriceps, MuscleGroup.hamstrings, MuscleGroup.glutes, MuscleGroup.calves],
    ),
    ExerciseData(
      id: 'strength_arms',
      name: '手臂训练',
      type: ExerciseType.strength,
      met: 4.0,
      muscleGroups: [MuscleGroup.biceps, MuscleGroup.triceps, MuscleGroup.forearms],
    ),
    ExerciseData(
      id: 'strength_core',
      name: '核心训练',
      type: ExerciseType.strength,
      met: 4.0,
      muscleGroups: [MuscleGroup.core],
    ),

    // HIIT
    ExerciseData(
      id: 'hiit_beginner',
      name: 'HIIT (初级)',
      type: ExerciseType.hiit,
      met: 8.0,
      muscleGroups: [MuscleGroup.quadriceps, MuscleGroup.hamstrings, MuscleGroup.core],
    ),
    ExerciseData(
      id: 'hiit_advanced',
      name: 'HIIT (高级)',
      type: ExerciseType.hiit,
      met: 12.0,
      muscleGroups: [MuscleGroup.quadriceps, MuscleGroup.hamstrings, MuscleGroup.core, MuscleGroup.shoulders],
    ),

    // 柔韧性训练
    ExerciseData(
      id: 'yoga',
      name: '瑜伽',
      type: ExerciseType.flexibility,
      met: 2.5,
      muscleGroups: [MuscleGroup.core],
    ),
    ExerciseData(
      id: 'stretching',
      name: '拉伸',
      type: ExerciseType.flexibility,
      met: 2.5,
      muscleGroups: [],
    ),

    // 平衡训练
    ExerciseData(
      id: 'balance_training',
      name: '平衡训练',
      type: ExerciseType.balance,
      met: 3.0,
      muscleGroups: [MuscleGroup.core],
    ),
  ];

  /// 根据名称搜索运动
  static List<ExerciseData> search(String query) {
    if (query.isEmpty) return exercises;
    final lowerQuery = query.toLowerCase();
    return exercises.where((ex) =>
      ex.name.toLowerCase().contains(lowerQuery) ||
      ex.type.displayName.contains(lowerQuery)
    ).toList();
  }

  /// 根据类型获取运动
  static List<ExerciseData> getByType(ExerciseType type) {
    return exercises.where((ex) => ex.type == type).toList();
  }

  /// 根据肌肉群获取运动
  static List<ExerciseData> getByMuscleGroup(MuscleGroup muscleGroup) {
    return exercises.where((ex) => ex.muscleGroups.contains(muscleGroup)).toList();
  }

  /// 获取所有运动类型
  static List<ExerciseType> get types => ExerciseType.values;
}
