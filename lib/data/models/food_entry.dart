import 'nutrition_info.dart';

/// 餐次类型
enum MealType {
  breakfast,  // 早餐
  lunch,      // 午餐
  dinner,     // 晚餐
  snack;      // 加餐

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return '早餐';
      case MealType.lunch:
        return '午餐';
      case MealType.dinner:
        return '晚餐';
      case MealType.snack:
        return '加餐';
    }
  }

  String get icon {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍪';
    }
  }
}

/// 饮食记录条目
class FoodEntry {
  final String id;
  final String userId;
  final String name;
  final double amount;        // 数量
  final String unit;          // 单位 (g/个/杯等)
  final NutritionInfo nutrition;  // 营养素信息（已按数量计算）
  final MealType mealType;
  final DateTime timestamp;

  const FoodEntry({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.unit,
    required this.nutrition,
    required this.mealType,
    required this.timestamp,
  });

  FoodEntry copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    String? unit,
    NutritionInfo? nutrition,
    MealType? mealType,
    DateTime? timestamp,
  }) {
    return FoodEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      nutrition: nutrition ?? this.nutrition,
      mealType: mealType ?? this.mealType,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'amount': amount,
      'unit': unit,
      'nutrition': nutrition.toJson(),
      'mealType': mealType.index,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      nutrition: NutritionInfo.fromJson(json['nutrition'] as Map<String, dynamic>),
      mealType: MealType.values[json['mealType'] as int],
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
