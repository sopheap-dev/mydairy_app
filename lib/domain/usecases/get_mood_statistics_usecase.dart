import 'package:dartz/dartz.dart';
import 'package:mydairy/app/core/enums/mood_enum.dart';
import 'package:mydairy/app/core/utils/errors/failures.dart';
import 'package:mydairy/domain/repositories/diary_repository.dart';

class MoodStatistics {
  final Map<MoodType, int> moodCounts;
  final MoodType? dominantMood;
  final int totalEntries;
  final int currentStreak;

  const MoodStatistics({
    required this.moodCounts,
    this.dominantMood,
    required this.totalEntries,
    this.currentStreak = 0,
  });
}

class GetMoodStatisticsUsecase {
  final DiaryRepository repository;

  GetMoodStatisticsUsecase(this.repository);

  Future<Either<Failure, MoodStatistics>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final entriesResult = startDate != null && endDate != null
        ? await repository.getEntriesByDateRange(startDate, endDate)
        : await repository.getAllEntries();

    return entriesResult.fold((failure) => Left(failure), (entries) {
      final moodCounts = <MoodType, int>{};

      for (final entry in entries) {
        if (entry.aiMood != null) {
          moodCounts[entry.aiMood!] = (moodCounts[entry.aiMood!] ?? 0) + 1;
        }
      }

      MoodType? dominantMood;
      if (moodCounts.isNotEmpty) {
        dominantMood = moodCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }

      // Calculate streak (consecutive days with entries)
      final sortedEntries = List<DateTime>.from(
        entries.map((e) => DateTime(e.date.year, e.date.month, e.date.day)),
      )..sort((a, b) => b.compareTo(a));

      int streak = 0;
      if (sortedEntries.isNotEmpty) {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);

        DateTime expectedDate = todayDate;
        for (final date in sortedEntries) {
          if (date == expectedDate) {
            streak++;
            expectedDate = expectedDate.subtract(const Duration(days: 1));
          } else {
            break;
          }
        }
      }

      return Right(
        MoodStatistics(
          moodCounts: moodCounts,
          dominantMood: dominantMood,
          totalEntries: entries.length,
          currentStreak: streak,
        ),
      );
    });
  }
}
