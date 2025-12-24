import 'package:dartz/dartz.dart';
import 'package:mydairy/app/core/utils/errors/failures.dart';
import 'package:mydairy/domain/entities/diary_entry.dart';
import 'package:mydairy/domain/repositories/ai_repository.dart';
import 'package:mydairy/domain/repositories/diary_repository.dart';

class AnalyzeEntryUsecase {
  final AiRepository aiRepository;
  final DiaryRepository diaryRepository;

  AnalyzeEntryUsecase({
    required this.aiRepository,
    required this.diaryRepository,
  });

  Future<Either<Failure, DiaryEntry>> call(DiaryEntry entry) async {
    // Analyze the entry
    final analysisResult = await aiRepository.analyzeEntry(entry.body);

    return analysisResult.fold((failure) => Left(failure), (analysis) async {
      // Update entry with AI analysis
      final updatedEntry = entry.copyWith(
        aiSummary: analysis.summary,
        aiMood: analysis.mood,
        aiConfidence: analysis.confidence,
        aiRecommendations: analysis.recommendations,
        aiEmpathy: analysis.empathy,
        isPendingAnalysis: false,
        hasSafetyAlert: analysis.safetyAlert,
        updatedAt: DateTime.now(),
      );

      // Save updated entry
      return await diaryRepository.updateEntry(updatedEntry);
    });
  }
}
