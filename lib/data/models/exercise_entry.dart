/// 肌肉群枚举
enum MuscleGroup {
  chest,        // 胸部
  back,         // 背部
  shoulders,    // 肩部
  biceps,       // 二头肌
  triceps,      // 三头肌
  forearms,     // 前臂
  core,         // 核心
  quadriceps,   // 大腿前侧
  hamstrings,   // 大腿后侧
  glutes,       // 臀部
  calves;       // 小腿

  String get displayName {
    switch (this) {
      case MuscleGroup.chest:
        return '胸部';
      case MuscleGroup.back:
        return '背部';
      case MuscleGroup.shoulders:
        return '肩部';
      case MuscleGroup.biceps:
        return '二头肌';
      case MuscleGroup.triceps:
        return '三头肌';
      case MuscleGroup.forearms:
        return '前臂';
      case MuscleGroup.core:
        return '核心';
      case MuscleGroup.quadriceps:
        return '大腿前侧';
      case MuscleGroup.hamstrings:
        return '大腿后侧';
      case MuscleGroup.glutes:
        return '臀部';
      case MuscleGroup.calves:
        return '小腿';
    }
  }

  String get icon {
    switch (this) {
      case MuscleGroup.chest:
        return '💪';
      case MuscleGroup.back:
        return '🔙';
      case MuscleGroup.shoulders:
        return '🎯';
      case MuscleGroup.biceps:
        return '💪';
      case MuscleGroup.triceps:
        return '💪';
      case MuscleGroup.forearms:
        return '🤚';
      case MuscleGroup.core:
        return '🎯';
      case MuscleGroup.quadriceps:
        return '🦵';
      case MuscleGroup.hamstrings:
        return '🦵';
      case MuscleGroup.glutes:
        return '🍑';
      case MuscleGroup.calves:
        return '🦶';
    }
  }
}

/// 运动类型
enum ExerciseType {
  cardio,       // 有氧
  strength,     // 力量
  flexibility,  // 柔韧
  balance,      // 平衡
  hiit;         // HIIT

  String get displayName {
    switch (this) {
      case ExerciseType.cardio:
        return '有氧运动';
      case ExerciseType.strength:
        return '力量训练';
      case ExerciseType.flexibility:
        return '柔韧性训练';
      case ExerciseType.balance:
        return '平衡训练';
      case ExerciseType.hiit:
        return 'HIIT';
    }
  }
}

/// 运动记录条目
class ExerciseEntry {
  final String id;
  final String userId;
  final String name;
  final ExerciseType type;
  final int duration;           // 持续时间（分钟）
  final int caloriesBurned;     // 消耗热量 (kcal)
  final List<MuscleGroup> muscleGroups;  // 训练到的肌肉群
  final DateTime timestamp;

  const ExerciseEntry({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.duration,
    required this.caloriesBurned,
    required this.muscleGroups,
    required this.timestamp,
  });

  ExerciseEntry copyWith({
    String? id,
    String? userId,
    String? name,
    ExerciseType? type,
    int? duration,
    int? caloriesBurned,
    List<MuscleGroup>? muscleGroups,
    DateTime? timestamp,
  }) {
    return ExerciseEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type.index,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'muscleGroups': muscleGroups.map((e) => e.index).toList(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ExerciseEntry.fromJson(Map<String, dynamic> json) {
    return ExerciseEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      type: ExerciseType.values[json['type'] as int],
      duration: json['duration'] as int,
      caloriesBurned: json['caloriesBurned'] as int,
      muscleGroups: (json['muscleGroups'] as List)
          .map((e) => MuscleGroup.values[e as int])
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
