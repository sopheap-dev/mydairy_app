import 'package:dartz/dartz.dart';
import 'package:mydairy/app/core/utils/errors/failures.dart';
import 'package:mydairy/domain/entities/ai_analysis.dart';

abstract class AiRepository {
  Future<Either<Failure, AiAnalysis>> analyzeEntry(String entryText);
  Future<Either<Failure, bool>> checkSafety(String entryText);
}
