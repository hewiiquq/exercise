import 'nutrition_info.dart';

/// 食物数据（每100g的营养含量）
class FoodData {
  final String id;
  final String name;
  final String category;      // 分类：主食、肉类、蔬菜、水果等
  final String unit;          // 默认单位
  final double defaultAmount; // 默认数量
  final NutritionInfo nutritionPer100g;

  const FoodData({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.defaultAmount,
    required this.nutritionPer100g,
  });

  /// 根据数量获取营养素
  NutritionInfo getNutrition(double amount) {
    return nutritionPer100g.scaledBy(amount);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'unit': unit,
      'defaultAmount': defaultAmount,
      'nutritionPer100g': nutritionPer100g.toJson(),
    };
  }

  factory FoodData.fromJson(Map<String, dynamic> json) {
    return FoodData(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      unit: json['unit'] as String,
      defaultAmount: (json['defaultAmount'] as num).toDouble(),
      nutritionPer100g: NutritionInfo.fromJson(json['nutritionPer100g'] as Map<String, dynamic>),
    );
  }
}

/// 内置食物数据库（精简版，常见食物）
class FoodDatabase {
  static const List<FoodData> foods = [
    // 米面类主食
    FoodData(
      id: 'rice',
      name: '米饭',
      category: '主食',
      unit: 'g',
      defaultAmount: 100,
      nutritionPer100g: NutritionInfo(
        calories: 116, protein: 2.6, fat: 0.3, carbs: 25.9,
        fiber: 0.3, vitaminA: 0, vitaminC: 0, vitaminD: 0,
        calcium: 2, iron: 0.2, zinc: 0.4,
      ),
    ),
    FoodData(
      id: 'noodles',
      name: '面条',
      category: '主食',
      unit: 'g',
      defaultAmount: 100,
      nutritionPer100g: NutritionInfo(
        calories: 284, protein: 8.3, fat: 0.8, carbs: 59.5,
        fiber: 1.8, vitaminA: 0, vitaminC: 0, vitaminD: 0,
        calcium: 11, iron: 2.7, zinc: 1.0,
      ),
    ),
    FoodData(
      id: 'bread',
      name: '面包',
      category: '主食',
      unit: 'g',
      defaultAmount: 100,
      nutritionPer100g: NutritionInfo(
        calories: 265, protein: 9.0, fat: 3.2, carbs: 49.8,
        fiber: 2.0, vitaminA: 0, vitaminC: 0, vitaminD: 0,
        calcium: 52, iron: 2.5, zinc: 0.8,
      ),
    ),
    FoodData(
      id: 'steamed_bun',
      name: '馒头',
      category: '主食',
      unit: 'g',
      defaultAmount: 100,
      nutritionPer100g: NutritionInfo(
        calories: 223, protein: 7.0, fat: 1.1, carbs: 47.0,
        fiber: 1.3, vitaminA: 0, vitaminC: 0, vitaminD: 0,
        calcium: 18, iron: 1.8, zinc: 0.7,
      ),
    ),

    // 肉类
    FoodData(
      id: 'chicken_breast',
      name: '鸡胸肉',
      category: '肉类',
      unit: 'g',
      defaultAmount: 100,
      nutritionPer100g: NutritionInfo(
        calories: 133, protein: 31.0, fat: 1.2, carbs: 0,
        fiber: 0, vitaminA: 6, vitaminC: 0, vitaminD: 0.1,
        calcium: 5, iron: 0.4, zinc: 0.6,
      ),
    ),
    FoodData(
      id: 'pork',
      name: '猪肉',
      category: '肉类',
      unit: 'g',
      defaultAmount: 100,
      nutritionPer100g: NutritionInfo(
        calories: 143, protein: 21.3, fat: 6.2, carbs: 0,
        fiber: 0, vitaminA: 5, vitaminC: 0, vitaminD: 0.2,
        calcium: 6, iron: 1.0, zinc: 2.0,
      ),
    ),
    FoodData(
      id: 'beef',
      name: '牛肉',
      category: '肉类',
      unit: 'g',
      defaultAmount: 100,
      nutritionPer100g: NutritionInfo(
        calories: 125, protein: 26.0, fat: 2.4, carbs: 0,
        fiber: 0, vitaminA: 3, vitaminC: 0, vitaminD: 0.1,
        calcium: 7, iron: 2.6, zinc: 4.0,
      ),
    ),
    FoodData(
      id: 'fish',
      name: '鱼肉',
      category: '肉类',
      unit: 'g',
      defaultAmount: 100,
      nutritionPer100g: NutritionInfo(
        calories: 90, protein: 18.0, fat: 2.0, carbs: 0,
        fiber: 0, vitaminA: 10, vitaminC: 0, vitaminD: 0.5,
        calcium: 30, iron: 0.5, zinc: 0.6,
      ),
    ),
    FoodData(
      id: 'shrimp',
      name: '虾',
      category: '肉类',
      unit: 'g',
      defaultAmount: 100,
      nutritionPer100g: NutritionInfo(
        calories: 85, protein: 18.0, fat: 0.6, carbs: 0.8,
        fiber: 0, vitaminA: 18, vitaminC: 0, vitaminD: 0.5,
        calcium: 70, iron: 1.5, zinc: 1.4,
      ),
    ),

    // 蛋类
    FoodData(
      id: 'egg',
      name: '鸡蛋',
      category: '蛋类',
      unit: '个',
      defaultAmount: 50,
      nutritionPer100g: NutritionInfo(
        calories: 144, protein: 13.3, fat: 9.5, carbs: 1.5,
        fiber: 0, vitaminA: 234, vitaminC: 0, vitaminD: 2.0,
        calcium: 47, iron: 1.6, zinc: 1.0,
      ),
    ),

    // 蔬菜类
    FoodData(
      id: 'broccoli',
      name: '西兰花',
      category: '蔬菜',
      unit: 'g',
      defaultAmount: 100,
      nutritionPer100g: NutritionInfo(
        calories: 27, protein: 2.8, fat: 0.4, carbs: 4.3,
        fiber: 2.6, vitaminA: 31, vitaminC: 89.2, vitaminD: 0,
        calcium: 47, iron: 0.7, zinc: 0.4,
      ),
    ),
    FoodData(
      id: 'spinach',
      name: '菠菜',
      category: '蔬菜',
      unit: 'g',
      defaultAmount: 100,
      nutritionPer100g: NutritionInfo(
        calories: 20, protein: 2.4, fat: 0.3, carbs: 2.5,
        fiber: 2.2, vitaminA: 469, vitaminC: 28.1, vitaminD: 0,
        calcium: 99, iron: 2.9, zinc: 0.5,
      ),
    ),
    FoodData(
      id: 'carrot',
      name: '胡萝卜',
      category: '蔬菜',
      unit: 'g',
      defaultAmount: 100,
      nutritionPer100g: NutritionInfo(
        calories: 32, protein: 0.8, fat: 0.2, carbs: 7.6,
        fiber: 2.8, vitaminA: 668, vitaminC: 5.9, vitaminD: 0,
        calcium: 32, iron: 0.5, zinc: 0.2,
      ),
    ),
    FoodData(
      id: 'tomato',
      name: '番茄',
      category: '蔬菜',
      unit: 'g',
      defaultAmount: 100,
      nutritionPer100g: NutritionInfo(
        calories: 15, protein: 0.7, fat: 0.2, carbs: 3.3,
        fiber: 1.0, vitaminA: 42, vitaminC: 14.0, vitaminD: 0,
        calcium: 8, iron: 0.3, zinc: 0.1,
      ),
    ),
    FoodData(
      id: 'cucumber',
      name: '黄瓜',
      category: '蔬菜',
      unit: 'g',
      defaultAmount: 100,
      nutritionPer100g: NutritionInfo(
        calories: 12, protein: 0.6, fat: 0.1, carbs: 2.5,
        fiber: 0.7, vitaminA: 15, vitaminC: 3.0, vitaminD: 0,
        calcium: 16, iron: 0.2, zinc: 0.1,
      ),
    ),

    // 水果类
    FoodData(
      id: 'apple',
      name: '苹果',
      category: '水果',
      unit: '个',
      defaultAmount: 200,
      nutritionPer100g: NutritionInfo(
        calories: 49, protein: 0.3, fat: 0.2, carbs: 12.7,
        fiber: 1.7, vitaminA: 10, vitaminC: 4.0, vitaminD: 0,
        calcium: 8, iron: 0.2, zinc: 0.1,
      ),
    ),
    FoodData(
      id: 'banana',
      name: '香蕉',
      category: '水果',
      unit: '根',
      defaultAmount: 120,
      nutritionPer100g: NutritionInfo(
        calories: 89, protein: 1.1, fat: 0.2, carbs: 22.8,
        fiber: 1.7, vitaminA: 3, vitaminC: 8.7, vitaminD: 0,
        calcium: 5, iron: 0.3, zinc: 0.2,
      ),
    ),
    FoodData(
      id: 'orange',
      name: '橙子',
      category: '水果',
      unit: '个',
      defaultAmount: 180,
      nutritionPer100g: NutritionInfo(
        calories: 45, protein: 0.9, fat: 0.1, carbs: 11.4,
        fiber: 2.4, vitaminA: 13, vitaminC: 53.2, vitaminD: 0,
        calcium: 40, iron: 0.3, zinc: 0.1,
      ),
    ),

    // 奶制品
    FoodData(
      id: 'milk',
      name: '牛奶',
      category: '奶制品',
      unit: 'ml',
      defaultAmount: 250,
      nutritionPer100g: NutritionInfo(
        calories: 54, protein: 3.0, fat: 3.2, carbs: 3.4,
        fiber: 0, vitaminA: 46, vitaminC: 0, vitaminD: 0.5,
        calcium: 104, iron: 0.1, zinc: 0.4,
      ),
    ),
    FoodData(
      id: 'yogurt',
      name: '酸奶',
      category: '奶制品',
      unit: 'g',
      defaultAmount: 100,
      nutritionPer100g: NutritionInfo(
        calories: 72, protein: 2.9, fat: 2.7, carbs: 9.3,
        fiber: 0, vitaminA: 26, vitaminC: 0.5, vitaminD: 0.1,
        calcium: 118, iron: 0.1, zinc: 0.4,
      ),
    ),

    // 坚果类
    FoodData(
      id: 'almonds',
      name: '杏仁',
      category: '坚果',
      unit: 'g',
      defaultAmount: 30,
      nutritionPer100g: NutritionInfo(
        calories: 579, protein: 21.0, fat: 49.9, carbs: 21.6,
        fiber: 10.3, vitaminA: 0, vitaminC: 0, vitaminD: 0,
        calcium: 264, iron: 3.7, zinc: 3.1,
      ),
    ),
    FoodData(
      id: 'peanuts',
      name: '花生',
      category: '坚果',
      unit: 'g',
      defaultAmount: 30,
      nutritionPer100g: NutritionInfo(
        calories: 567, protein: 25.0, fat: 44.4, carbs: 16.2,
        fiber: 5.5, vitaminA: 0, vitaminC: 0, vitaminD: 0,
        calcium: 56, iron: 1.6, zinc: 3.3,
      ),
    ),

    // 饮品
    FoodData(
      id: 'cola',
      name: '可乐',
      category: '饮品',
      unit: 'ml',
      defaultAmount: 330,
      nutritionPer100g: NutritionInfo(
        calories: 42, protein: 0, fat: 0, carbs: 10.6,
        fiber: 0, vitaminA: 0, vitaminC: 0, vitaminD: 0,
        calcium: 2, iron: 0, zinc: 0,
      ),
    ),
  ];

  /// 根据名称搜索食物
  static List<FoodData> search(String query) {
    if (query.isEmpty) return foods;
    final lowerQuery = query.toLowerCase();
    return foods.where((food) =>
      food.name.toLowerCase().contains(lowerQuery) ||
      food.category.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// 根据分类获取食物
  static List<FoodData> getByCategory(String category) {
    return foods.where((food) => food.category == category).toList();
  }

  /// 获取所有分类
  static List<String> get categories {
    return foods.map((food) => food.category).toSet().toList()..sort();
  }
}
