import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/food_data.dart';
import '../../data/models/food_entry.dart';
import '../providers/providers.dart';

class AddFoodPage extends ConsumerStatefulWidget {
  const AddFoodPage({super.key});

  @override
  ConsumerState<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends ConsumerState<AddFoodPage> {
  final _searchController = TextEditingController();
  String _selectedCategory = '全部';
  FoodData? _selectedFood;
  final _amountController = TextEditingController();
  MealType _selectedMealType = MealType.breakfast;

  // Voice input
  final _speech = SpeechToText();
  bool _isListening = false;
  String _voiceText = '';

  // Image picker
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _amountController.text = '100';
    _initSpeech();
  }

  void _initSpeech() async {
    await _speech.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      // Search with recognized text
      if (_voiceText.isNotEmpty) {
        _searchController.text = _voiceText;
        ref.read(foodSearchQueryProvider.notifier).state = _voiceText;
      }
    } else {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          _voiceText = result.recognizedWords;
        });
        if (result.finalResult) {
          _searchController.text = _voiceText;
          ref.read(foodSearchQueryProvider.notifier).state = _voiceText;
        }
      });
    }
  }

  void _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // TODO: Implement food recognition API call
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('图片已保存: ${image.name}\n图片识别功能开发中...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(foodSearchQueryProvider);
    final searchResults = ref.watch(foodSearchResultsProvider);
    final categories = ['全部', ...FoodDatabase.categories];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('添加食物'),
        backgroundColor: AppColors.background,
        actions: [
          if (_selectedFood != null)
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索食物...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isListening)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(Icons.mic, color: AppColors.primary),
                            ),
                          if (searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.textHint),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(foodSearchQueryProvider.notifier).state = '';
                              },
                            ),
                        ],
                      ),
                    ),
                    onChanged: (value) {
                      ref.read(foodSearchQueryProvider.notifier).state = value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Voice button
                IconButton(
                  onPressed: _toggleListening,
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? AppColors.primary : AppColors.textHint,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: _isListening ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
                  ),
                ),
                const SizedBox(width: 8),
                // Image button
                IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt, color: AppColors.textHint),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surface,
                  ),
                ),
              ],
            ),
          ),

          // 分类筛选
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // 食物列表
          Expanded(
            child: _selectedFood == null
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final food = searchResults[index];
                      return _FoodListItem(
                        food: food,
                        onTap: () {
                          setState(() {
                            _selectedFood = food;
                            _amountController.text = food.defaultAmount.toString();
                          });
                        },
                      );
                    },
                  )
                : _FoodDetailInput(
                    food: _selectedFood!,
                    amountController: _amountController,
                    selectedMealType: _selectedMealType,
                    onMealTypeChanged: (type) {
                      setState(() => _selectedMealType = type);
                    },
                    onBack: () {
                      setState(() => _selectedFood = null);
                    },
                    onAmountChanged: (value) {
                      setState(() {});
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _saveEntry() {
    if (_selectedFood == null) return;

    final amount = double.tryParse(_amountController.text) ?? 100;
    final nutrition = _selectedFood!.nutritionPer100g.scaledBy(amount);

    final entry = FoodEntry(
      id: generateId(),
      userId: 'current_user',
      name: _selectedFood!.name,
      amount: amount,
      unit: _selectedFood!.unit,
      nutrition: nutrition,
      mealType: _selectedMealType,
      timestamp: DateTime.now(),
    );

    ref.read(foodEntriesProvider.notifier).addEntry(entry);
    Navigator.pop(context);
  }
}

class _FoodListItem extends StatelessWidget {
  final FoodData food;
  final VoidCallback onTap;

  const _FoodListItem({required this.food, required this.onTap});

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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.restaurant,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${food.nutritionPer100g.calories.round()} kcal / 100${food.unit}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodDetailInput extends StatelessWidget {
  final FoodData food;
  final TextEditingController amountController;
  final MealType selectedMealType;
  final ValueChanged<MealType> onMealTypeChanged;
  final VoidCallback onBack;
  final ValueChanged<String> onAmountChanged;

  const _FoodDetailInput({
    required this.food,
    required this.amountController,
    required this.selectedMealType,
    required this.onMealTypeChanged,
    required this.onBack,
    required this.onAmountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(amountController.text) ?? 100;
    final nutrition = food.nutritionPer100g.scaledBy(amount);

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

          // 食物信息卡片
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '每 100${food.unit}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 数量输入
          const Text(
            '摄入数量',
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
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    suffixText: food.unit,
                  ),
                  onChanged: onAmountChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 餐次选择
          const Text(
            '选择餐次',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: MealType.values.map((type) {
              final isSelected = type == selectedMealType;
              return ChoiceChip(
                label: Text('${type.icon} ${type.displayName}'),
                selected: isSelected,
                onSelected: (_) => onMealTypeChanged(type),
                backgroundColor: AppColors.surface,
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 营养素预览
          const Text(
            '营养素估算',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _NutritionRow(
                  label: '热量',
                  value: '${nutrition.calories.round()} kcal',
                  color: AppColors.caloriesColor,
                ),
                _NutritionRow(
                  label: '蛋白质',
                  value: '${nutrition.protein.toStringAsFixed(1)} g',
                  color: AppColors.proteinColor,
                ),
                _NutritionRow(
                  label: '脂肪',
                  value: '${nutrition.fat.toStringAsFixed(1)} g',
                  color: AppColors.fatColor,
                ),
                _NutritionRow(
                  label: '碳水',
                  value: '${nutrition.carbs.toStringAsFixed(1)} g',
                  color: AppColors.carbsColor,
                ),
                _NutritionRow(
                  label: '纤维',
                  value: '${nutrition.fiber.toStringAsFixed(1)} g',
                  color: AppColors.fiberColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _NutritionRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
