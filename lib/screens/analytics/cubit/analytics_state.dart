import 'package:equatable/equatable.dart';
import 'package:mydairy/domain/usecases/get_mood_statistics_usecase.dart';

enum AnalyticsStatus { initial, loading, success, failure }

enum AnalyticsPeriod { today, week, month, all, custom }

class AnalyticsState extends Equatable {
  final AnalyticsStatus status;
  final MoodStatistics? statistics;
  final AnalyticsPeriod period;
  final String? errorMessage;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.statistics,
    this.period = AnalyticsPeriod.month,
    this.errorMessage,
    this.customStartDate,
    this.customEndDate,
  });

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    MoodStatistics? statistics,
    AnalyticsPeriod? period,
    String? errorMessage,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      statistics: statistics ?? this.statistics,
      period: period ?? this.period,
      errorMessage: errorMessage,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
    );
  }

  @override
  List<Object?> get props => [
        status,
        statistics,
        period,
        errorMessage,
        customStartDate,
        customEndDate,
      ];
}
