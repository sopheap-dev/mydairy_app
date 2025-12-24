import 'package:dartz/dartz.dart';
import 'package:mydairy/app/core/utils/errors/failures.dart';
import 'package:mydairy/domain/entities/diary_entry.dart';
import 'package:mydairy/domain/repositories/diary_repository.dart';

class GetEntriesUsecase {
  final DiaryRepository repository;

  GetEntriesUsecase(this.repository);

  Future<Either<Failure, List<DiaryEntry>>> call() {
    return repository.getAllEntries();
  }
}
