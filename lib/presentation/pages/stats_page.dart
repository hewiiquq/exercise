import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/nutrition_info.dart';
import '../providers/providers.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  int _selectedDays = 7;

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final dailyGoals = userProfile.dailyGoals;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('统计'),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 时间选择器
            Row(
              children: [
                _TimeChip(label: '7天', isSelected: _selectedDays == 7, onTap: () => setState(() => _selectedDays = 7)),
                const SizedBox(width: 8),
                _TimeChip(label: '14天', isSelected: _selectedDays == 14, onTap: () => setState(() => _selectedDays = 14)),
                const SizedBox(width: 8),
                _TimeChip(label: '30天', isSelected: _selectedDays == 30, onTap: () => setState(() => _selectedDays = 30)),
              ],
            ),
            const SizedBox(height: 24),

            // 热量趋势图
            const _SectionTitle(title: '热量摄入趋势'),
            const SizedBox(height: 16),
            _CalorieChart(
              days: _selectedDays,
              goal: dailyGoals.calories,
            ),
            const SizedBox(height: 32),

            // 营养素趋势
            const _SectionTitle(title: '营养素趋势'),
            const SizedBox(height: 16),
            _NutritionChart(
              title: '蛋白质',
              currentData: _getWeeklyData('protein'),
              goal: dailyGoals.protein,
              color: AppColors.proteinColor,
            ),
            const SizedBox(height: 16),
            _NutritionChart(
              title: '脂肪',
              currentData: _getWeeklyData('fat'),
              goal: dailyGoals.fat,
              color: AppColors.fatColor,
            ),
            const SizedBox(height: 16),
            _NutritionChart(
              title: '碳水',
              currentData: _getWeeklyData('carbs'),
              goal: dailyGoals.carbs,
              color: AppColors.carbsColor,
            ),
            const SizedBox(height: 32),

            // 运动统计
            const _SectionTitle(title: '运动统计'),
            const SizedBox(height: 16),
            _ExerciseStatsCard(days: _selectedDays),
          ],
        ),
      ),
    );
  }

  List<double> _getWeeklyData(String nutrient) {
    final List<double> data = [];
    final now = DateTime.now();

    for (int i = _selectedDays - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final nutrition = ref.read(dateNutritionProvider(date));
      double value = 0;
      switch (nutrient) {
        case 'protein':
          value = nutrition.protein;
          break;
        case 'fat':
          value = nutrition.fat;
          break;
        case 'carbs':
          value = nutrition.carbs;
          break;
        case 'calories':
          value = nutrition.calories;
          break;
      }
      data.add(value);
    }

    return data;
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
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

class _CalorieChart extends ConsumerWidget {
  final int days;
  final int goal;

  const _CalorieChart({required this.days, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '目标',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
              Text(
                '$goal kcal',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: goal / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.textHint.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textHint,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() == 0 || value.toInt() == days - 1) {
                          final date = DateTime.now().subtract(Duration(days: days - 1 - value.toInt()));
                          return Text(
                            '${date.month}/${date.day}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textHint,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (days - 1).toDouble(),
                minY: 0,
                maxY: goal * 1.5,
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: goal.toDouble(),
                      color: AppColors.primary.withValues(alpha: 0.5),
                      strokeWidth: 2,
                      dashArray: [5, 5],
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateSpots(ref),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateSpots(WidgetRef ref) {
    final List<FlSpot> spots = [];
    final now = DateTime.now();
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: days - 1 - i));
      final dateKey = DateTime(date.year, date.month, date.day);
      // 使用真实数据
      final nutrition = ref.read(dateNutritionProvider(dateKey));
      spots.add(FlSpot(i.toDouble(), nutrition.calories));
    }
    return spots;
  }
}

class _NutritionChart extends StatelessWidget {
  final String title;
  final List<double> currentData;
  final double goal;
  final Color color;

  const _NutritionChart({
    required this.title,
    required this.currentData,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final avg = currentData.isEmpty ? 0.0 : currentData.reduce((a, b) => a + b) / currentData.length;
    final percentage = goal > 0 ? (avg / goal * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '平均 $percentage%',
                style: TextStyle(
                  fontSize: 13,
                  color: percentage >= 80 && percentage <= 120 ? AppColors.accent : AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (avg / goal).clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '日均 ${avg.toStringAsFixed(1)}g / 目标 ${goal.toStringAsFixed(0)}g',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseStatsCard extends StatelessWidget {
  final int days;

  const _ExerciseStatsCard({required this.days});

  @override
  Widget build(BuildContext context) {
    // 模拟运动统计数据
    final totalCalories = days * 250;
    final totalMinutes = days * 45;
    final exerciseDays = (days * 0.7).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  value: '$totalCalories',
                  unit: 'kcal',
                  label: '总消耗',
                  icon: Icons.local_fire_department,
                  color: AppColors.accent,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppColors.textHint.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _StatItem(
                  value: '$totalMinutes',
                  unit: '分钟',
                  label: '总时长',
                  icon: Icons.timer_outlined,
                  color: AppColors.info,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: AppColors.textHint.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _StatItem(
                  value: '$exerciseDays',
                  unit: '天',
                  label: '运动天数',
                  icon: Icons.calendar_today,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.value,
    required this.unit,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              TextSpan(
                text: unit,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
