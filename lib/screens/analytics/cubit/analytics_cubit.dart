import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mydairy/domain/usecases/get_mood_statistics_usecase.dart';
import 'package:mydairy/screens/analytics/cubit/analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final GetMoodStatisticsUsecase getMoodStatisticsUsecase;

  AnalyticsCubit({required this.getMoodStatisticsUsecase})
    : super(const AnalyticsState());

  void init() {
    loadStatistics();
  }

  void changePeriod(AnalyticsPeriod period) {
    emit(state.copyWith(period: period));
    loadStatistics();
  }

  void setCustomDateRange(DateTime startDate, DateTime endDate) {
    emit(
      state.copyWith(
        period: AnalyticsPeriod.custom,
        customStartDate: startDate,
        customEndDate: endDate,
      ),
    );
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    emit(state.copyWith(status: AnalyticsStatus.loading));

    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    switch (state.period) {
      case AnalyticsPeriod.today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case AnalyticsPeriod.week:
        // Calculate Monday of the current week
        // DateTime.weekday returns 1 (Monday) to 7 (Sunday)
        final daysFromMonday = (now.weekday - 1) % 7;
        startDate = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: daysFromMonday));
        // End date is today (or Sunday if we want to include the full week)
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case AnalyticsPeriod.month:
        // First day of the current month
        startDate = DateTime(now.year, now.month, 1);
        // Today
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case AnalyticsPeriod.all:
        startDate = null;
        endDate = null;
        break;
      case AnalyticsPeriod.custom:
        startDate = state.customStartDate;
        endDate = state.customEndDate;
        break;
    }

    final result = await getMoodStatisticsUsecase(
      startDate: startDate,
      endDate: endDate,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AnalyticsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (statistics) => emit(
        state.copyWith(status: AnalyticsStatus.success, statistics: statistics),
      ),
    );
  }
}
