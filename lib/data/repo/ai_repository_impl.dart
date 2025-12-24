import 'package:dartz/dartz.dart';
import 'package:mydairy/app/core/services/api_key_service.dart';
import 'package:mydairy/app/core/utils/errors/failures.dart';
import 'package:mydairy/data/datasources/groq_remote_datasource.dart';
import 'package:mydairy/domain/entities/ai_analysis.dart';
import 'package:mydairy/domain/repositories/ai_repository.dart';

class AiRepositoryImpl implements AiRepository {
  final GroqRemoteDataSource remoteDataSource;
  final ApiKeyService apiKeyService;

  AiRepositoryImpl({
    required this.remoteDataSource,
    required this.apiKeyService,
  });

  @override
  Future<Either<Failure, AiAnalysis>> analyzeEntry(String entryText) async {
    try {
      final apiKey = apiKeyService.getApiKey();
      if (apiKey.isEmpty) {
        return const Left(ServerFailure('API key not configured'));
      }

      final result = await remoteDataSource.analyzeEntry(entryText, apiKey);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkSafety(String entryText) async {
    try {
      final apiKey = apiKeyService.getApiKey();
      if (apiKey.isEmpty) {
        return const Right(false);
      }

      final result = await remoteDataSource.checkSafety(entryText, apiKey);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
