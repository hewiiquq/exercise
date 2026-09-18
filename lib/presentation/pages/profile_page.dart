import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_profile.dart';
import '../providers/providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  Gender _selectedGender = Gender.male;
  ActivityLevel _selectedActivityLevel = ActivityLevel.moderate;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _heightController = TextEditingController(text: profile.height.toString());
    _weightController = TextEditingController(text: profile.weight.toString());
    _ageController = TextEditingController(text: profile.age.toString());
    _selectedGender = profile.gender;
    _selectedActivityLevel = profile.activityLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('个人设置'),
        backgroundColor: AppColors.background,
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text('编辑'),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text('保存'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像卡片
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 基本信息
            const _SectionTitle(title: '基本信息'),
            const SizedBox(height: 16),
            _InputField(
              label: '昵称',
              controller: _nameController,
              enabled: _isEditing,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InputField(
                    label: '身高 (cm)',
                    controller: _heightController,
                    enabled: _isEditing,
                    icon: Icons.height,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _InputField(
                    label: '体重 (kg)',
                    controller: _weightController,
                    enabled: _isEditing,
                    icon: Icons.monitor_weight_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InputField(
              label: '年龄',
              controller: _ageController,
              enabled: _isEditing,
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // 性别选择
            const _SectionTitle(title: '性别'),
            const SizedBox(height: 16),
            Row(
              children: Gender.values.map((gender) {
                final isSelected = gender == _selectedGender;
                return Expanded(
                  child: GestureDetector(
                    onTap: _isEditing ? () => setState(() => _selectedGender = gender) : null,
                    child: Container(
                      margin: EdgeInsets.only(right: gender != Gender.other ? 12 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            gender == Gender.male ? '👨' : gender == Gender.female ? '👩' : '🧑',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            gender.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 活动水平
            const _SectionTitle(title: '活动水平'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: ActivityLevel.values.map((level) {
                  final isSelected = level == _selectedActivityLevel;
                  return GestureDetector(
                    onTap: _isEditing ? () => setState(() => _selectedActivityLevel = level) : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.accent : AppColors.textHint,
                                width: 2,
                              ),
                              color: isSelected ? AppColors.accent : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  level.displayName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: isSelected ? AppColors.accent : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // 每日目标预览
            const _SectionTitle(title: '每日营养目标（自动计算）'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _GoalRow(
                    label: '热量',
                    value: '${profile.dailyGoals.calories} kcal',
                    icon: Icons.local_fire_department,
                    color: AppColors.caloriesColor,
                  ),
                  const Divider(height: 24),
                  _GoalRow(
                    label: '蛋白质',
                    value: '${profile.dailyGoals.protein.toStringAsFixed(0)} g',
                    icon: Icons.egg_outlined,
                    color: AppColors.proteinColor,
                  ),
                  const Divider(height: 24),
                  _GoalRow(
                    label: '脂肪',
                    value: '${profile.dailyGoals.fat.toStringAsFixed(0)} g',
                    icon: Icons.water_drop_outlined,
                    color: AppColors.fatColor,
                  ),
                  const Divider(height: 24),
                  _GoalRow(
                    label: '碳水',
                    value: '${profile.dailyGoals.carbs.toStringAsFixed(0)} g',
                    icon: Icons.grain,
                    color: AppColors.carbsColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '目标根据您的身体数据自动计算，如有特殊需求可手动调整',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    final height = double.tryParse(_heightController.text) ?? 170;
    final weight = double.tryParse(_weightController.text) ?? 65;
    final age = int.tryParse(_ageController.text) ?? 25;

    final newProfile = UserProfile(
      id: 'current_user',
      name: _nameController.text,
      height: height,
      weight: weight,
      age: age,
      gender: _selectedGender,
      activityLevel: _selectedActivityLevel,
      dailyGoals: DailyNutritionGoals.fromUserProfile(
        UserProfile(
          id: 'current_user',
          name: _nameController.text,
          height: height,
          weight: weight,
          age: age,
          gender: _selectedGender,
          activityLevel: _selectedActivityLevel,
          dailyGoals: DailyNutritionGoals.defaultGoals(),
        ),
      ),
    );

    ref.read(userProfileProvider.notifier).updateProfile(newProfile);
    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('保存成功'), duration: Duration(seconds: 1)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final IconData icon;
  final TextInputType? keyboardType;

  const _InputField({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.background,
          ),
        ),
      ],
    );
  }
}

class _GoalRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _GoalRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
