import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mydairy/domain/entities/diary_entry.dart';
import 'package:mydairy/domain/repositories/diary_repository.dart';
import 'package:mydairy/domain/usecases/get_entries_usecase.dart';
import 'package:mydairy/screens/home/cubit/home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetEntriesUsecase getEntriesUsecase;
  final DiaryRepository diaryRepository;
  StreamSubscription<List<DiaryEntry>>? _entriesSubscription;

  HomeCubit({required this.getEntriesUsecase, required this.diaryRepository})
    : super(HomeState());

  void init() {
    loadEntries();
    _watchEntries();
  }

  void _watchEntries() {
    _entriesSubscription = diaryRepository.watchAllEntries().listen((entries) {
      emit(state.copyWith(status: HomeStatus.success, entries: entries));
    });
  }

  Future<void> loadEntries() async {
    emit(state.copyWith(status: HomeStatus.loading));

    final result = await getEntriesUsecase();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (entries) =>
          emit(state.copyWith(status: HomeStatus.success, entries: entries)),
    );
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  List<DiaryEntry> getEntriesForSelectedDate() {
    return state.entries.where((entry) {
      return entry.date.year == state.selectedDate.year &&
          entry.date.month == state.selectedDate.month &&
          entry.date.day == state.selectedDate.day;
    }).toList();
  }

  @override
  Future<void> close() {
    _entriesSubscription?.cancel();
    return super.close();
  }
}
