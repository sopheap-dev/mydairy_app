import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mydairy/app/config/di/di.dart';
import 'package:mydairy/app/core/enums/mood_enum.dart';
import 'package:mydairy/app/core/widgets/mood_badge.dart';
import 'package:mydairy/domain/usecases/get_mood_statistics_usecase.dart';
import 'package:mydairy/screens/analytics/cubit/analytics_cubit.dart';
import 'package:mydairy/screens/analytics/cubit/analytics_state.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnalyticsCubit(getMoodStatisticsUsecase: getIt())..init(),
      child: const AnalyticsView(),
    );
  }
}

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics'), elevation: 0),
      body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
        builder: (context, state) {
          if (state.status == AnalyticsStatus.loading &&
              state.statistics == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AnalyticsStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Failed to load analytics'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<AnalyticsCubit>().loadStatistics(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final statistics = state.statistics;
          final hasData = statistics != null && statistics.totalEntries > 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Modern Period Selector - Always visible
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.secondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withAlpha(50),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.filter_list,
                            color: theme.colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Time Period',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              _getPeriodDescription(state.period),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer
                                    .withAlpha(180),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Quick Filter Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _PeriodChip(
                          label: 'Today',
                          icon: Icons.today,
                          isSelected: state.period == AnalyticsPeriod.today,
                          onTap: () => context
                              .read<AnalyticsCubit>()
                              .changePeriod(AnalyticsPeriod.today),
                          theme: theme,
                        ),
                        _PeriodChip(
                          label: 'This Week',
                          icon: Icons.view_week,
                          isSelected: state.period == AnalyticsPeriod.week,
                          onTap: () => context
                              .read<AnalyticsCubit>()
                              .changePeriod(AnalyticsPeriod.week),
                          theme: theme,
                        ),
                        _PeriodChip(
                          label: 'This Month',
                          icon: Icons.calendar_month,
                          isSelected: state.period == AnalyticsPeriod.month,
                          onTap: () => context
                              .read<AnalyticsCubit>()
                              .changePeriod(AnalyticsPeriod.month),
                          theme: theme,
                        ),
                        _PeriodChip(
                          label: 'All Time',
                          icon: Icons.all_inclusive,
                          isSelected: state.period == AnalyticsPeriod.all,
                          onTap: () => context
                              .read<AnalyticsCubit>()
                              .changePeriod(AnalyticsPeriod.all),
                          theme: theme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Custom Date Range Button
                    _ModernCustomDateRangeButton(
                      startDate: state.customStartDate,
                      endDate: state.customEndDate,
                      isActive: state.period == AnalyticsPeriod.custom,
                      onDateRangeSelected: (start, end) {
                        context.read<AnalyticsCubit>().setCustomDateRange(
                          start,
                          end,
                        );
                      },
                      theme: theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Empty State or Data Content
              if (!hasData)
                // Empty State
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No data available',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start writing entries to see your analytics',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Data Content - statistics is guaranteed to be non-null here
                // because hasData is true in this branch
                // ignore: unnecessary_non_null_assertion
                ..._buildDataContent(statistics!, theme),
            ],
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<MoodType, int> moodCounts,
  ) {
    final total = moodCounts.values.fold(0, (sum, count) => sum + count);

    return moodCounts.entries.map((entry) {
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '$percentage%',
        color: Color(int.parse(entry.key.colorHex.replaceAll('#', '0xFF'))),
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<Widget> _buildLegend(Map<MoodType, int> moodCounts) {
    return moodCounts.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Color(
                  int.parse(entry.key.colorHex.replaceAll('#', '0xFF')),
                ),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text('${entry.key.emoji} ${entry.key.label}'),
            const Spacer(),
            Text('${entry.value} entries'),
          ],
        ),
      );
    }).toList();
  }

  String _getPeriodDescription(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.today:
        return 'Showing today\'s entries';
      case AnalyticsPeriod.week:
        return 'This week (Mon-Sun)';
      case AnalyticsPeriod.month:
        return 'This month (from 1st to today)';
      case AnalyticsPeriod.all:
        return 'All your entries';
      case AnalyticsPeriod.custom:
        return 'Custom date range';
    }
  }

  List<Widget> _buildDataContent(MoodStatistics statistics, ThemeData theme) {
    return [
      // Stats Cards
      Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Total Entries',
              value: '${statistics.totalEntries}',
              icon: Icons.edit_note,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'Current Streak',
              value: '${statistics.currentStreak}',
              subtitle: 'days',
              icon: Icons.local_fire_department,
              color: Colors.orange,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),

      // Dominant Mood
      if (statistics.dominantMood != null) ...[
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Most Common Mood',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: MoodBadge(mood: statistics.dominantMood!, size: 80),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],

      // Mood Distribution Chart
      if (statistics.moodCounts.isNotEmpty) ...[
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mood Distribution',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieChartSections(statistics.moodCounts),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ..._buildLegend(statistics.moodCounts),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],

      // Mood Breakdown
      Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detailed Breakdown',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...statistics.moodCounts.entries.map((entry) {
                final percentage = (entry.value / statistics.totalEntries * 100)
                    .toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      MoodBadge(mood: entry.key, showLabel: false, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key.label,
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: entry.value / statistics.totalEntries,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              color: Color(
                                int.parse(
                                  entry.key.colorHex.replaceAll('#', '0xFF'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.value}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$percentage%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    ];
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (subtitle != null) ...[
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modern Period Chip Widget
class _PeriodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _PeriodChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface.withAlpha(180),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withAlpha(100),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(80),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface.withAlpha(180),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modern Custom Date Range Button
class _ModernCustomDateRangeButton extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final Function(DateTime, DateTime) onDateRangeSelected;
  final ThemeData theme;

  const _ModernCustomDateRangeButton({
    required this.onDateRangeSelected,
    required this.isActive,
    required this.theme,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return InkWell(
      onTap: () => _showDateRangePicker(context),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary.withAlpha(230)
              : theme.colorScheme.surface.withAlpha(180),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withAlpha(100),
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(80),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.onPrimary.withAlpha(50)
                    : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_today,
                size: 20,
                color: isActive
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Custom Date Range',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? theme.colorScheme.onPrimary.withAlpha(200)
                          : theme.colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    startDate != null && endDate != null
                        ? '${dateFormat.format(startDate!)} - ${dateFormat.format(endDate!)}'
                        : 'Tap to select date range',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isActive
                  ? theme.colorScheme.onPrimary.withAlpha(200)
                  : theme.colorScheme.onSurface.withAlpha(150),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final now = DateTime.now();
    final initialDateRange = DateTimeRange(
      start: startDate ?? now.subtract(const Duration(days: 7)),
      end: endDate ?? now,
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: AppBarTheme(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeSelected(picked.start, picked.end);
    }
  }
}
