import 'package:hive/hive.dart';
import 'package:mydairy/app/core/enums/mood_enum.dart';
import 'package:mydairy/data/models/diary_entry_model.dart';
import 'package:mydairy/domain/entities/diary_entry.dart';

abstract class DiaryLocalDataSource {
  Future<DiaryEntry> createEntry(DiaryEntry entry);
  Future<DiaryEntry> updateEntry(DiaryEntry entry);
  Future<void> deleteEntry(String id);
  Future<DiaryEntry> getEntry(String id);
  Future<List<DiaryEntry>> getAllEntries();
  Future<List<DiaryEntry>> getEntriesByDateRange(DateTime start, DateTime end);
  Future<List<DiaryEntry>> getEntriesByMood(MoodType mood);
  Future<List<DiaryEntry>> getPendingAnalysisEntries();
  Stream<List<DiaryEntry>> watchAllEntries();
}

class DiaryLocalDataSourceImpl implements DiaryLocalDataSource {
  final Box<DiaryEntryModel> box;

  DiaryLocalDataSourceImpl(this.box);

  @override
  Future<DiaryEntry> createEntry(DiaryEntry entry) async {
    final model = DiaryEntryModel.fromEntity(entry);
    await box.put(entry.id, model);
    return model.toEntity();
  }

  @override
  Future<DiaryEntry> updateEntry(DiaryEntry entry) async {
    final model = DiaryEntryModel.fromEntity(entry);
    await box.put(entry.id, model);
    return model.toEntity();
  }

  @override
  Future<void> deleteEntry(String id) async {
    await box.delete(id);
  }

  @override
  Future<DiaryEntry> getEntry(String id) async {
    final model = box.get(id);
    if (model == null) {
      throw Exception('Entry not found');
    }
    return model.toEntity();
  }

  @override
  Future<List<DiaryEntry>> getAllEntries() async {
    final models = box.values.toList();
    return models.map((model) => model.toEntity()).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<DiaryEntry>> getEntriesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final models = box.values.where((model) {
      return model.date.isAfter(start.subtract(const Duration(days: 1))) &&
          model.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();

    return models.map((model) => model.toEntity()).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<DiaryEntry>> getEntriesByMood(MoodType mood) async {
    final models = box.values.where((model) {
      return model.aiMood == mood.label;
    }).toList();

    return models.map((model) => model.toEntity()).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<List<DiaryEntry>> getPendingAnalysisEntries() async {
    final models = box.values.where((model) {
      return model.isPendingAnalysis;
    }).toList();

    return models.map((model) => model.toEntity()).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Stream<List<DiaryEntry>> watchAllEntries() async* {
    yield await getAllEntries();

    yield* box.watch().asyncMap((_) async {
      return await getAllEntries();
    });
  }
}
