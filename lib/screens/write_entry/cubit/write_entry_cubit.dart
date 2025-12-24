import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mydairy/domain/entities/diary_entry.dart';
import 'package:mydairy/domain/usecases/analyze_entry_usecase.dart';
import 'package:mydairy/domain/usecases/save_entry_usecase.dart';
import 'package:mydairy/screens/write_entry/cubit/write_entry_state.dart';
import 'package:uuid/uuid.dart';

class WriteEntryCubit extends Cubit<WriteEntryState> {
  final SaveEntryUsecase saveEntryUsecase;
  final AnalyzeEntryUsecase analyzeEntryUsecase;

  WriteEntryCubit({
    required this.saveEntryUsecase,
    required this.analyzeEntryUsecase,
  }) : super(const WriteEntryState());

  void markAsChanged() {
    if (!state.hasUnsavedChanges) {
      emit(state.copyWith(hasUnsavedChanges: true));
    }
  }

  Future<void> saveEntry({
    required String title,
    required String body,
    List<String>? tags,
    bool analyzeWithAI = true,
  }) async {
    if (title.trim().isEmpty || body.trim().isEmpty) {
      emit(state.copyWith(
        status: WriteEntryStatus.failure,
        errorMessage: 'Title and body cannot be empty',
      ));
      return;
    }

    emit(state.copyWith(status: WriteEntryStatus.saving));

    final now = DateTime.now();
    final entry = DiaryEntry(
      id: const Uuid().v4(),
      date: now,
      title: title.trim(),
      body: body.trim(),
      tags: tags ?? [],
      createdAt: now,
      updatedAt: now,
      isPendingAnalysis: analyzeWithAI,
    );

    final result = await saveEntryUsecase(entry);

    await result.fold(
      (failure) async {
        emit(state.copyWith(
          status: WriteEntryStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (savedEntry) async {
        emit(state.copyWith(
          entry: savedEntry,
          hasUnsavedChanges: false,
        ));

        if (analyzeWithAI) {
          await _analyzeEntry(savedEntry);
        } else {
          emit(state.copyWith(status: WriteEntryStatus.success));
        }
      },
    );
  }

  Future<void> _analyzeEntry(DiaryEntry entry) async {
    emit(state.copyWith(status: WriteEntryStatus.analyzing));

    final result = await analyzeEntryUsecase(entry);

    result.fold(
      (failure) {
        // Analysis failed, but entry is saved
        emit(state.copyWith(
          status: WriteEntryStatus.success,
          errorMessage: 'Entry saved, but AI analysis failed: ${failure.message}',
        ));
      },
      (analyzedEntry) {
        emit(state.copyWith(
          status: WriteEntryStatus.success,
          entry: analyzedEntry,
        ));
      },
    );
  }
}
