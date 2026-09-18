/// 营养素信息
class NutritionInfo {
  final double calories;    // 热量 (kcal)
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

  const NutritionInfo({
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

  /// 根据食物重量计算营养素（食物数据通常是每100g的标准）
  NutritionInfo scaledBy(double grams) {
    final factor = grams / 100;
    return NutritionInfo(
      calories: calories * factor,
      protein: protein * factor,
      fat: fat * factor,
      carbs: carbs * factor,
      fiber: fiber * factor,
      vitaminA: vitaminA * factor,
      vitaminC: vitaminC * factor,
      vitaminD: vitaminD * factor,
      calcium: calcium * factor,
      iron: iron * factor,
      zinc: zinc * factor,
    );
  }

  /// 累加营养素
  NutritionInfo operator +(NutritionInfo other) {
    return NutritionInfo(
      calories: calories + other.calories,
      protein: protein + other.protein,
      fat: fat + other.fat,
      carbs: carbs + other.carbs,
      fiber: fiber + other.fiber,
      vitaminA: vitaminA + other.vitaminA,
      vitaminC: vitaminC + other.vitaminC,
      vitaminD: vitaminD + other.vitaminD,
      calcium: calcium + other.calcium,
      iron: iron + other.iron,
      zinc: zinc + other.zinc,
    );
  }

  /// 零值
  static const NutritionInfo zero = NutritionInfo(
    calories: 0,
    protein: 0,
    fat: 0,
    carbs: 0,
    fiber: 0,
    vitaminA: 0,
    vitaminC: 0,
    vitaminD: 0,
    calcium: 0,
    iron: 0,
    zinc: 0,
  );

  NutritionInfo copyWith({
    double? calories,
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
    return NutritionInfo(
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

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: (json['calories'] as num).toDouble(),
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
