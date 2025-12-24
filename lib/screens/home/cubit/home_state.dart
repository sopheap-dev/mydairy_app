import 'package:equatable/equatable.dart';
import 'package:mydairy/domain/entities/diary_entry.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<DiaryEntry> entries;
  final String? errorMessage;
  final DateTime selectedDate;

  HomeState({
    this.status = HomeStatus.initial,
    this.entries = const [],
    this.errorMessage,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  HomeState copyWith({
    HomeStatus? status,
    List<DiaryEntry>? entries,
    String? errorMessage,
    DateTime? selectedDate,
  }) {
    return HomeState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      errorMessage: errorMessage,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [status, entries, errorMessage, selectedDate];
}
