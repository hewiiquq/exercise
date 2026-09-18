import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/add_food_page.dart';
import 'presentation/pages/add_exercise_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/stats_page.dart';
import 'presentation/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const ProviderScope(child: NutritionTrackerApp()));
}

class NutritionTrackerApp extends StatelessWidget {
  const NutritionTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '营养追踪',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainShell(),
      routes: {
        '/home': (context) => const HomePage(),
        '/add-food': (context) => const AddFoodPage(),
        '/add-exercise': (context) => const AddExercisePage(),
        '/profile': (context) => const ProfilePage(),
        '/stats': (context) => const StatsPage(),
        '/food': (context) => const FoodListPage(),
        '/exercise': (context) => const ExerciseListPage(),
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    StatsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: '首页',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart,
                  label: '统计',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: '我的',
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 饮食列表页
class FoodListPage extends ConsumerWidget {
  const FoodListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final entries = ref.watch(foodEntriesProvider);
    final dayEntries = entries.where((e) =>
      e.timestamp.year == selectedDate.year &&
      e.timestamp.month == selectedDate.month &&
      e.timestamp.day == selectedDate.day
    ).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('饮食记录'),
        backgroundColor: AppColors.background,
      ),
      body: dayEntries.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, size: 64, color: AppColors.textHint),
                  SizedBox(height: 16),
                  Text(
                    '今日暂无饮食记录',
                    style: TextStyle(color: AppColors.textHint),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dayEntries.length,
              itemBuilder: (context, index) {
                final entry = dayEntries[index];
                return Dismissible(
                  key: Key(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppColors.error,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref.read(foodEntriesProvider.notifier).removeEntry(entry.id);
                  },
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(entry.mealType.icon, style: const TextStyle(fontSize: 20)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${entry.amount}${entry.unit} · ${entry.mealType.displayName}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${entry.nutrition.calories.round()} kcal',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-food'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// 运动列表页
class ExerciseListPage extends ConsumerWidget {
  const ExerciseListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final entries = ref.watch(exerciseEntriesProvider);
    final dayEntries = entries.where((e) =>
      e.timestamp.year == selectedDate.year &&
      e.timestamp.month == selectedDate.month &&
      e.timestamp.day == selectedDate.day
    ).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('运动记录'),
        backgroundColor: AppColors.background,
      ),
      body: dayEntries.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, size: 64, color: AppColors.textHint),
                  SizedBox(height: 16),
                  Text(
                    '今日暂无运动记录',
                    style: TextStyle(color: AppColors.textHint),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dayEntries.length,
              itemBuilder: (context, index) {
                final entry = dayEntries[index];
                return Dismissible(
                  key: Key(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: AppColors.error,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    ref.read(exerciseEntriesProvider.notifier).removeEntry(entry.id);
                  },
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.fitness_center, color: AppColors.accent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${entry.duration}分钟',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${entry.caloriesBurned} kcal',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-exercise'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
