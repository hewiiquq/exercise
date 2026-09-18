/// 性别枚举
enum Gender {
  male,
  female,
  other;

  String get displayName {
    switch (this) {
      case Gender.male:
        return '男';
      case Gender.female:
        return '女';
      case Gender.other:
        return '其他';
    }
  }
}

/// 活动水平枚举
enum ActivityLevel {
  sedentary,    // 久坐
  light,        // 轻度
  moderate,     // 中度
  active;       // 活跃

  String get displayName {
    switch (this) {
      case ActivityLevel.sedentary:
        return '久坐（很少运动）';
      case ActivityLevel.light:
        return '轻度（每周运动1-3天）';
      case ActivityLevel.moderate:
        return '中度（每周运动3-5天）';
      case ActivityLevel.active:
        return '活跃（每周运动6-7天）';
    }
  }

  /// 活动系数，用于计算每日所需热量
  double get factor {
    switch (this) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.light:
        return 1.375;
      case ActivityLevel.moderate:
        return 1.55;
      case ActivityLevel.active:
        return 1.725;
    }
  }
}

/// 用户个人资料
class UserProfile {
  final String id;
  final String name;
  final double height;      // 身高 cm
  final double weight;      // 体重 kg
  final int age;
  final Gender gender;
  final ActivityLevel activityLevel;
  final DailyNutritionGoals dailyGoals;

  const UserProfile({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.dailyGoals,
  });

  /// 计算基础代谢率 (BMR)
  /// 男: BMR = 66.5 + (13.75 × 体重kg) + (5.003 × 身高cm) - (6.755 × 年龄)
  /// 女: BMR = 655.1 + (9.563 × 体重kg) + (1.850 × 身高cm) - (4.676 × 年龄)
  double get bmr {
    if (gender == Gender.male) {
      return 66.5 + (13.75 * weight) + (5.003 * height) - (6.755 * age);
    } else {
      return 655.1 + (9.563 * weight) + (1.850 * height) - (4.676 * age);
    }
  }

  /// 计算每日所需热量
  int get dailyCalories {
    return (bmr * activityLevel.factor).round();
  }

  UserProfile copyWith({
    String? id,
    String? name,
    double? height,
    double? weight,
    int? age,
    Gender? gender,
    ActivityLevel? activityLevel,
    DailyNutritionGoals? dailyGoals,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      dailyGoals: dailyGoals ?? this.dailyGoals,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender.index,
      'activityLevel': activityLevel.index,
      'dailyGoals': dailyGoals.toJson(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      age: json['age'] as int,
      gender: Gender.values[json['gender'] as int],
      activityLevel: ActivityLevel.values[json['activityLevel'] as int],
      dailyGoals: DailyNutritionGoals.fromJson(json['dailyGoals'] as Map<String, dynamic>),
    );
  }

  /// 创建默认用户
  factory UserProfile.defaultUser() {
    return UserProfile(
      id: '',
      name: '用户',
      height: 170,
      weight: 65,
      age: 25,
      gender: Gender.male,
      activityLevel: ActivityLevel.moderate,
      dailyGoals: DailyNutritionGoals.defaultGoals(),
    );
  }
}

/// 每日营养目标
class DailyNutritionGoals {
  final int calories;       // 热量 (kcal)
  final double protein;     // 蛋白质 (g)
  final double fat;         // 脂肪 (g)
  final double carbs;       // 碳水化合物 (g)
  final double fiber;       // 膳食纤维 (g)
  final double vitaminA;    // 维生素A (μg)
  final double vitaminC;    // 维生素C (mg)
  final double vitaminD;    // 维生素D (μg)
  final double calcium;     // 钙 (mg)
  final double iron;        // 铁 (mg)
  final double zinc;        // 锌 (mg)

  const DailyNutritionGoals({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.fiber,
    required this.vitaminA,
    required this.vitaminC,
    required this.vitaminD,
    required this.calcium,
    required this.iron,
    required this.zinc,
  });

  /// 根据用户信息计算推荐目标
  factory DailyNutritionGoals.fromUserProfile(UserProfile user) {
    final dailyCal = user.dailyCalories;
    // 蛋白质: 1.2-1.8g/kg体重
    final protein = (user.weight * 1.5).clamp(60.0, 150.0);
    // 脂肪: 25-35%热量
    final fat = (dailyCal * 0.28 / 9).clamp(50.0, 100.0);
    // 碳水: 剩余热量
    final carbs = (dailyCal - protein * 4 - fat * 9) / 4;
    // 纤维: 25-30g
    const fiber = 28.0;

    return DailyNutritionGoals(
      calories: dailyCal,
      protein: protein,
      fat: fat,
      carbs: carbs,
      fiber: fiber,
      vitaminA: 800,
      vitaminC: 100,
      vitaminD: 10,
      calcium: 800,
      iron: 15,
      zinc: 12,
    );
  }

  /// 默认目标
  factory DailyNutritionGoals.defaultGoals() {
    return const DailyNutritionGoals(
      calories: 2000,
      protein: 75,
      fat: 65,
      carbs: 250,
      fiber: 28,
      vitaminA: 800,
      vitaminC: 100,
      vitaminD: 10,
      calcium: 800,
      iron: 15,
      zinc: 12,
    );
  }

  DailyNutritionGoals copyWith({
    int? calories,
    double? protein,
    double? fat,
    double? carbs,
    double? fiber,
    double? vitaminA,
    double? vitaminC,
    double? vitaminD,
    double? calcium,
    double? iron,
    double? zinc,
  }) {
    return DailyNutritionGoals(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      fiber: fiber ?? this.fiber,
      vitaminA: vitaminA ?? this.vitaminA,
      vitaminC: vitaminC ?? this.vitaminC,
      vitaminD: vitaminD ?? this.vitaminD,
      calcium: calcium ?? this.calcium,
      iron: iron ?? this.iron,
      zinc: zinc ?? this.zinc,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'fiber': fiber,
      'vitaminA': vitaminA,
      'vitaminC': vitaminC,
      'vitaminD': vitaminD,
      'calcium': calcium,
      'iron': iron,
      'zinc': zinc,
    };
  }

  factory DailyNutritionGoals.fromJson(Map<String, dynamic> json) {
    return DailyNutritionGoals(
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      vitaminA: (json['vitaminA'] as num).toDouble(),
      vitaminC: (json['vitaminC'] as num).toDouble(),
      vitaminD: (json['vitaminD'] as num).toDouble(),
      calcium: (json['calcium'] as num).toDouble(),
      iron: (json['iron'] as num).toDouble(),
      zinc: (json['zinc'] as num).toDouble(),
    );
  }
}
