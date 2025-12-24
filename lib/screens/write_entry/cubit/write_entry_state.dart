import 'package:equatable/equatable.dart';
import 'package:mydairy/domain/entities/diary_entry.dart';

enum WriteEntryStatus { initial, saving, analyzing, success, failure }

class WriteEntryState extends Equatable {
  final WriteEntryStatus status;
  final DiaryEntry? entry;
  final String? errorMessage;
  final bool hasUnsavedChanges;

  const WriteEntryState({
    this.status = WriteEntryStatus.initial,
    this.entry,
    this.errorMessage,
    this.hasUnsavedChanges = false,
  });

  WriteEntryState copyWith({
    WriteEntryStatus? status,
    DiaryEntry? entry,
    String? errorMessage,
    bool? hasUnsavedChanges,
  }) {
    return WriteEntryState(
      status: status ?? this.status,
      entry: entry ?? this.entry,
      errorMessage: errorMessage,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  @override
  List<Object?> get props => [status, entry, errorMessage, hasUnsavedChanges];
}
