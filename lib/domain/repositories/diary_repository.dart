import 'package:dartz/dartz.dart';
import 'package:mydairy/app/core/enums/mood_enum.dart';
import 'package:mydairy/app/core/utils/errors/failures.dart';
import 'package:mydairy/domain/entities/diary_entry.dart';

abstract class DiaryRepository {
  Future<Either<Failure, DiaryEntry>> createEntry(DiaryEntry entry);
  Future<Either<Failure, DiaryEntry>> updateEntry(DiaryEntry entry);
  Future<Either<Failure, void>> deleteEntry(String id);
  Future<Either<Failure, DiaryEntry>> getEntry(String id);
  Future<Either<Failure, List<DiaryEntry>>> getAllEntries();
  Future<Either<Failure, List<DiaryEntry>>> getEntriesByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<Either<Failure, List<DiaryEntry>>> getEntriesByMood(MoodType mood);
  Future<Either<Failure, List<DiaryEntry>>> getPendingAnalysisEntries();
  Stream<List<DiaryEntry>> watchAllEntries();
}
