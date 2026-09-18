import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';
import '../../data/models/nutrition_info.dart';
import '../../data/models/food_entry.dart';

/// 营养素进度环
class NutritionRing extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final Color color;
  final String unit;
  final double size;

  const NutritionRing({
    super.key,
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
    this.unit = 'g',
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = goal > 0 ? (current / goal).clamp(0.0, 1.5) : 0.0;
    final displayPercentage = (percentage * 100).round();

    return SizedBox(
      width: size,
      height: size + 30,
      child: Column(
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _RingPainter(
                progress: percentage.clamp(0.0, 1.0),
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Text(
                  '$displayPercentage%',
                  style: TextStyle(
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
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
          Text(
            '${current.toStringAsFixed(0)}/$goal$unit',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;
    const strokeWidth = 8.0;

    // 背景环
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // 进度环
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// 热量剩余卡片
class CalorieCard extends StatelessWidget {
  final int consumed;
  final int goal;
  final int burned;

  const CalorieCard({
    super.key,
    required this.consumed,
    required this.goal,
    required this.burned,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = goal - consumed + burned;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '今日热量',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                remaining.toString(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  ' kcal',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const Text(
            '剩余',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CalorieItem(
                label: '摄入',
                value: consumed,
                color: AppColors.caloriesColor,
              ),
              Container(
                width: 1,
                height: 30,
                color: AppColors.textHint.withValues(alpha: 0.2),
              ),
              _CalorieItem(
                label: '消耗',
                value: burned,
                color: AppColors.accent,
              ),
              Container(
                width: 1,
                height: 30,
                color: AppColors.textHint.withValues(alpha: 0.2),
              ),
              _CalorieItem(
                label: '目标',
                value: goal,
                color: AppColors.info,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalorieItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _CalorieItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textHint,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// 营养素摘要条
class NutritionBar extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final Color color;

  const NutritionBar({
    super.key,
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)} / ${goal.toStringAsFixed(0)}g',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

/// 餐次卡片
class MealCard extends StatelessWidget {
  final MealType mealType;
  final List<dynamic> entries;
  final VoidCallback onAddTap;
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.mealType,
    required this.entries,
    required this.onAddTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = entries.fold<double>(
      0, (sum, e) => sum + e.nutrition.calories
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      mealType.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mealType.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                if (entries.isNotEmpty)
                  Text(
                    '${totalCalories.round()} kcal',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              GestureDetector(
                onTap: onAddTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.textHint.withValues(alpha: 0.2),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          size: 18,
                          color: AppColors.textHint,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '添加食物',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...entries.take(3).map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${entry.nutrition.calories.round()} kcal',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              )),
            if (entries.length > 3)
              Text(
                '还有 ${entries.length - 3} 项...',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
