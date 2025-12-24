import 'package:dartz/dartz.dart';
import 'package:mydairy/app/core/utils/errors/failures.dart';
import 'package:mydairy/domain/entities/diary_entry.dart';
import 'package:mydairy/domain/repositories/diary_repository.dart';

class SaveEntryUsecase {
  final DiaryRepository repository;

  SaveEntryUsecase(this.repository);

  Future<Either<Failure, DiaryEntry>> call(DiaryEntry entry) {
    return repository.createEntry(entry);
  }
}
