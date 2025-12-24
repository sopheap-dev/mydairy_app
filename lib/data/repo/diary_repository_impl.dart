import 'package:dartz/dartz.dart';
import 'package:mydairy/app/core/enums/mood_enum.dart';
import 'package:mydairy/app/core/utils/errors/failures.dart';
import 'package:mydairy/data/datasources/diary_local_datasource.dart';
import 'package:mydairy/domain/entities/diary_entry.dart';
import 'package:mydairy/domain/repositories/diary_repository.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final DiaryLocalDataSource localDataSource;

  DiaryRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, DiaryEntry>> createEntry(DiaryEntry entry) async {
    try {
      final result = await localDataSource.createEntry(entry);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DiaryEntry>> updateEntry(DiaryEntry entry) async {
    try {
      final result = await localDataSource.updateEntry(entry);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEntry(String id) async {
    try {
      await localDataSource.deleteEntry(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DiaryEntry>> getEntry(String id) async {
    try {
      final result = await localDataSource.getEntry(id);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DiaryEntry>>> getAllEntries() async {
    try {
      final result = await localDataSource.getAllEntries();
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DiaryEntry>>> getEntriesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final result = await localDataSource.getEntriesByDateRange(start, end);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DiaryEntry>>> getEntriesByMood(
    MoodType mood,
  ) async {
    try {
      final result = await localDataSource.getEntriesByMood(mood);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DiaryEntry>>> getPendingAnalysisEntries() async {
    try {
      final result = await localDataSource.getPendingAnalysisEntries();
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<List<DiaryEntry>> watchAllEntries() {
    return localDataSource.watchAllEntries();
  }
}
