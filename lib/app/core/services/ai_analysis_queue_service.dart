import 'dart:async';
import 'package:mydairy/domain/repositories/diary_repository.dart';
import 'package:mydairy/domain/usecases/analyze_entry_usecase.dart';

class AiAnalysisQueueService {
  final DiaryRepository diaryRepository;
  final AnalyzeEntryUsecase analyzeEntryUsecase;

  Timer? _timer;
  bool _isProcessing = false;

  AiAnalysisQueueService({
    required this.diaryRepository,
    required this.analyzeEntryUsecase,
  });

  /// Start the background queue processor
  /// Checks for pending entries every 30 seconds
  void start() {
    if (_timer != null && _timer!.isActive) {
      return; // Already running
    }

    // Run immediately on start
    _processQueue();

    // Then run every 30 seconds
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _processQueue(),
    );
  }

  /// Stop the background queue processor
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Process pending analysis entries
  Future<void> _processQueue() async {
    if (_isProcessing) {
      return; // Already processing
    }

    _isProcessing = true;

    try {
      // Get all pending entries
      final result = await diaryRepository.getPendingAnalysisEntries();

      await result.fold(
        (failure) async {
          // Log error but don't crash
          print('Failed to get pending entries: ${failure.message}');
        },
        (entries) async {
          if (entries.isEmpty) {
            return;
          }

          print('Processing ${entries.length} pending entries...');

          // Process entries one by one
          for (final entry in entries) {
            try {
              await analyzeEntryUsecase(entry);
              print('✓ Analyzed entry: ${entry.id}');
            } catch (e) {
              print('✗ Failed to analyze entry ${entry.id}: $e');
              // Continue with next entry even if one fails
            }

            // Small delay between requests to avoid rate limiting
            await Future.delayed(const Duration(milliseconds: 500));
          }

          print('Queue processing complete');
        },
      );
    } finally {
      _isProcessing = false;
    }
  }

  /// Manually trigger queue processing
  Future<void> processNow() async {
    await _processQueue();
  }

  /// Check if service is running
  bool get isRunning => _timer != null && _timer!.isActive;

  /// Dispose resources
  void dispose() {
    stop();
  }
}
