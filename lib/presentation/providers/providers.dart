import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/food_entry.dart';
import '../../data/models/exercise_entry.dart';
import '../../data/models/nutrition_info.dart';
import '../../data/models/food_data.dart';
import '../../data/models/exercise_data.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// ============ 数据持久化 ============

class StorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _foodEntriesKey = 'food_entries';
  static const String _exerciseEntriesKey = 'exercise_entries';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User Profile
  static Future<void> saveUserProfile(UserProfile profile) async {
    await _prefs?.setString(_userProfileKey, jsonEncode(profile.toJson()));
  }

  static UserProfile loadUserProfile() {
    final json = _prefs?.getString(_userProfileKey);
    if (json != null) {
      return UserProfile.fromJson(jsonDecode(json));
    }
    return UserProfile.defaultUser();
  }

  // Food Entries
  static Future<void> saveFoodEntries(List<FoodEntry> entries) async {
    final jsonList = entries.map((e) => e.toJson()).toList();
    await _prefs?.setString(_foodEntriesKey, jsonEncode(jsonList));
  }

  static List<FoodEntry> loadFoodEntries() {
    final json = _prefs?.getString(_foodEntriesKey);
    if (json != null) {
      final List<dynamic> jsonList = jsonDecode(json);
      return jsonList.map((e) => FoodEntry.fromJson(e)).toList();
    }
    return [];
  }

  // Exercise Entries
  static Future<void> saveExerciseEntries(List<ExerciseEntry> entries) async {
    final jsonList = entries.map((e) => e.toJson()).toList();
    await _prefs?.setString(_exerciseEntriesKey, jsonEncode(jsonList));
  }

  static List<ExerciseEntry> loadExerciseEntries() {
    final json = _prefs?.getString(_exerciseEntriesKey);
    if (json != null) {
      final List<dynamic> jsonList = jsonDecode(json);
      return jsonList.map((e) => ExerciseEntry.fromJson(e)).toList();
    }
    return [];
  }
}

// ============ 用户相关 Provider ============

/// 用户个人资料 Provider
class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(StorageService.loadUserProfile());

  void updateProfile(UserProfile profile) {
    state = profile;
    StorageService.saveUserProfile(profile);
  }

  void updateWeight(double weight) {
    final newGoals = DailyNutritionGoals.fromUserProfile(state.copyWith(weight: weight));
    state = state.copyWith(weight: weight, dailyGoals: newGoals);
    StorageService.saveUserProfile(state);
  }

  void updateHeight(double height) {
    final newGoals = DailyNutritionGoals.fromUserProfile(state.copyWith(height: height));
    state = state.copyWith(height: height, dailyGoals: newGoals);
    StorageService.saveUserProfile(state);
  }

  void updateAge(int age) {
    final newGoals = DailyNutritionGoals.fromUserProfile(state.copyWith(age: age));
    state = state.copyWith(age: age, dailyGoals: newGoals);
    StorageService.saveUserProfile(state);
  }

  void updateGender(Gender gender) {
    final newGoals = DailyNutritionGoals.fromUserProfile(state.copyWith(gender: gender));
    state = state.copyWith(gender: gender, dailyGoals: newGoals);
    StorageService.saveUserProfile(state);
  }

  void updateActivityLevel(ActivityLevel level) {
    final newGoals = DailyNutritionGoals.fromUserProfile(state.copyWith(activityLevel: level));
    state = state.copyWith(activityLevel: level, dailyGoals: newGoals);
    StorageService.saveUserProfile(state);
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

// ============ 饮食记录 Provider ============

/// 饮食记录列表
class FoodEntriesNotifier extends StateNotifier<List<FoodEntry>> {
  FoodEntriesNotifier() : super(StorageService.loadFoodEntries());

  void addEntry(FoodEntry entry) {
    state = [...state, entry];
    StorageService.saveFoodEntries(state);
  }

  void removeEntry(String id) {
    state = state.where((e) => e.id != id).toList();
    StorageService.saveFoodEntries(state);
  }

  void updateEntry(FoodEntry entry) {
    state = state.map((e) => e.id == entry.id ? entry : e).toList();
    StorageService.saveFoodEntries(state);
  }

  /// 获取指定日期的记录
  List<FoodEntry> getEntriesForDate(DateTime date) {
    return state.where((e) =>
      e.timestamp.year == date.year &&
      e.timestamp.month == date.month &&
      e.timestamp.day == date.day
    ).toList();
  }

  /// 获取指定日期和餐次的记录
  List<FoodEntry> getEntriesForMeal(DateTime date, MealType mealType) {
    return state.where((e) =>
      e.timestamp.year == date.year &&
      e.timestamp.month == date.month &&
      e.timestamp.day == date.day &&
      e.mealType == mealType
    ).toList();
  }
}

final foodEntriesProvider = StateNotifierProvider<FoodEntriesNotifier, List<FoodEntry>>((ref) {
  return FoodEntriesNotifier();
});

/// 今日饮食记录
final todayFoodEntriesProvider = Provider<List<FoodEntry>>((ref) {
  final entries = ref.watch(foodEntriesProvider);
  final today = DateTime.now();
  return entries.where((e) =>
    e.timestamp.year == today.year &&
    e.timestamp.month == today.month &&
    e.timestamp.day == today.day
  ).toList();
});

/// 今日营养摄入汇总
final todayNutritionProvider = Provider<NutritionInfo>((ref) {
  final entries = ref.watch(todayFoodEntriesProvider);
  return entries.fold<NutritionInfo>(
    NutritionInfo.zero,
    (sum, entry) => sum + entry.nutrition,
  );
});

// ============ 运动记录 Provider ============

/// 运动记录列表
class ExerciseEntriesNotifier extends StateNotifier<List<ExerciseEntry>> {
  ExerciseEntriesNotifier() : super(StorageService.loadExerciseEntries());

  void addEntry(ExerciseEntry entry) {
    state = [...state, entry];
    StorageService.saveExerciseEntries(state);
  }

  void removeEntry(String id) {
    state = state.where((e) => e.id != id).toList();
    StorageService.saveExerciseEntries(state);
  }

  void updateEntry(ExerciseEntry entry) {
    state = state.map((e) => e.id == entry.id ? entry : e).toList();
    StorageService.saveExerciseEntries(state);
  }

  /// 获取指定日期的记录
  List<ExerciseEntry> getEntriesForDate(DateTime date) {
    return state.where((e) =>
      e.timestamp.year == date.year &&
      e.timestamp.month == date.month &&
      e.timestamp.day == date.day
    ).toList();
  }
}

final exerciseEntriesProvider = StateNotifierProvider<ExerciseEntriesNotifier, List<ExerciseEntry>>((ref) {
  return ExerciseEntriesNotifier();
});

/// 今日运动记录
final todayExerciseEntriesProvider = Provider<List<ExerciseEntry>>((ref) {
  final entries = ref.watch(exerciseEntriesProvider);
  final today = DateTime.now();
  return entries.where((e) =>
    e.timestamp.year == today.year &&
    e.timestamp.month == today.month &&
    e.timestamp.day == today.day
  ).toList();
});

/// 今日消耗总热量
final todayCaloriesBurnedProvider = Provider<int>((ref) {
  final entries = ref.watch(todayExerciseEntriesProvider);
  return entries.fold<int>(0, (sum, entry) => sum + entry.caloriesBurned);
});

// ============ 统计相关 Provider ============

/// 选中日期
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// 指定日期的营养摄入
final dateNutritionProvider = Provider.family<NutritionInfo, DateTime>((ref, date) {
  final entries = ref.watch(foodEntriesProvider);
  final dayEntries = entries.where((e) =>
    e.timestamp.year == date.year &&
    e.timestamp.month == date.month &&
    e.timestamp.day == date.day
  );
  return dayEntries.fold<NutritionInfo>(NutritionInfo.zero, (sum, entry) => sum + entry.nutrition);
});

/// 指定日期的运动消耗
final dateCaloriesBurnedProvider = Provider.family<int, DateTime>((ref, date) {
  final entries = ref.watch(exerciseEntriesProvider);
  final dayEntries = entries.where((e) =>
    e.timestamp.year == date.year &&
    e.timestamp.month == date.month &&
    e.timestamp.day == date.day
  );
  return dayEntries.fold<int>(0, (sum, entry) => sum + entry.caloriesBurned);
});

// ============ 辅助 Provider ============

/// 搜索食物
final foodSearchQueryProvider = StateProvider<String>((ref) => '');

final foodSearchResultsProvider = Provider<List<FoodData>>((ref) {
  final query = ref.watch(foodSearchQueryProvider);
  return FoodDatabase.search(query);
});

/// 搜索运动
final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

final exerciseSearchResultsProvider = Provider<List<ExerciseData>>((ref) {
  final query = ref.watch(exerciseSearchQueryProvider);
  return ExerciseDatabase.search(query);
});

/// 生成ID
String generateId() => _uuid.v4();
