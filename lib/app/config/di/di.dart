import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mydairy/app/core/constants/hive_constants.dart';
import 'package:mydairy/app/core/services/ai_analysis_queue_service.dart';
import 'package:mydairy/app/core/services/api_key_service.dart';
import 'package:mydairy/app/core/services/storage_service.dart';
import 'package:mydairy/data/datasources/diary_local_datasource.dart';
import 'package:mydairy/data/datasources/groq_remote_datasource.dart';
import 'package:mydairy/data/models/diary_entry_model.dart';
import 'package:mydairy/data/repo/ai_repository_impl.dart';
import 'package:mydairy/data/repo/diary_repository_impl.dart';
import 'package:mydairy/domain/repositories/ai_repository.dart';
import 'package:mydairy/domain/repositories/diary_repository.dart';
import 'package:mydairy/domain/usecases/analyze_entry_usecase.dart';
import 'package:mydairy/domain/usecases/get_entries_usecase.dart';
import 'package:mydairy/domain/usecases/get_mood_statistics_usecase.dart';
import 'package:mydairy/domain/usecases/save_entry_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(DiaryEntryModelAdapter());

  // Open Hive boxes
  final diaryBox = await Hive.openBox<DiaryEntryModel>(
    HiveConstants.diaryEntriesBoxName,
  );

  // Core
  getIt
    ..registerSingletonAsync<SharedPreferences>(
      () async => SharedPreferences.getInstance(),
    )
    ..registerSingletonAsync<StorageService>(
      () async => StorageService(await getIt.getAsync<SharedPreferences>()),
    )
    ..registerSingletonAsync<ApiKeyService>(
      () async => ApiKeyService(await getIt.getAsync<StorageService>()),
    );

  // External
  getIt.registerLazySingleton<Dio>(() => Dio());

  // Data sources
  getIt
    ..registerLazySingleton<DiaryLocalDataSource>(
      () => DiaryLocalDataSourceImpl(diaryBox),
    )
    ..registerLazySingleton<GroqRemoteDataSource>(
      () => GroqRemoteDataSourceImpl(getIt()),
    );

  // Repositories
  getIt
    ..registerLazySingleton<DiaryRepository>(() => DiaryRepositoryImpl(getIt()))
    ..registerSingletonAsync<AiRepository>(
      () async => AiRepositoryImpl(
        remoteDataSource: getIt(),
        apiKeyService: await getIt.getAsync<ApiKeyService>(),
      ),
    );

  // Use cases
  getIt
    ..registerLazySingleton(() => SaveEntryUsecase(getIt()))
    ..registerSingletonAsync<AnalyzeEntryUsecase>(
      () async => AnalyzeEntryUsecase(
        aiRepository: await getIt.getAsync<AiRepository>(),
        diaryRepository: getIt(),
      ),
    )
    ..registerLazySingleton(() => GetEntriesUsecase(getIt()))
    ..registerLazySingleton(() => GetMoodStatisticsUsecase(getIt()));

  // Services
  getIt.registerSingletonAsync<AiAnalysisQueueService>(
    () async => AiAnalysisQueueService(
      diaryRepository: getIt(),
      analyzeEntryUsecase: await getIt.getAsync<AnalyzeEntryUsecase>(),
    )..start(),
  );

  await getIt.allReady();
}
