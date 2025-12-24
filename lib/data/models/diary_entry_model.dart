import 'package:hive/hive.dart';
import 'package:mydairy/app/core/enums/mood_enum.dart';
import 'package:mydairy/domain/entities/diary_entry.dart';

part 'diary_entry_model.g.dart';

@HiveType(typeId: 0)
class DiaryEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String body;

  @HiveField(4)
  final List<String> tags;

  @HiveField(5)
  final String? aiSummary;

  @HiveField(6)
  final String? aiMood;

  @HiveField(7)
  final double? aiConfidence;

  @HiveField(8)
  final List<String>? aiRecommendations;

  @HiveField(9)
  final String? aiEmpathy;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  @HiveField(12)
  final bool isPendingAnalysis;

  @HiveField(13)
  final bool hasSafetyAlert;

  DiaryEntryModel({
    required this.id,
    required this.date,
    required this.title,
    required this.body,
    this.tags = const [],
    this.aiSummary,
    this.aiMood,
    this.aiConfidence,
    this.aiRecommendations,
    this.aiEmpathy,
    required this.createdAt,
    required this.updatedAt,
    this.isPendingAnalysis = false,
    this.hasSafetyAlert = false,
  });

  DiaryEntry toEntity() {
    return DiaryEntry(
      id: id,
      date: date,
      title: title,
      body: body,
      tags: tags,
      aiSummary: aiSummary,
      aiMood: aiMood != null ? MoodType.fromString(aiMood!) : null,
      aiConfidence: aiConfidence,
      aiRecommendations: aiRecommendations,
      aiEmpathy: aiEmpathy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isPendingAnalysis: isPendingAnalysis,
      hasSafetyAlert: hasSafetyAlert,
    );
  }

  factory DiaryEntryModel.fromEntity(DiaryEntry entry) {
    return DiaryEntryModel(
      id: entry.id,
      date: entry.date,
      title: entry.title,
      body: entry.body,
      tags: entry.tags,
      aiSummary: entry.aiSummary,
      aiMood: entry.aiMood?.label,
      aiConfidence: entry.aiConfidence,
      aiRecommendations: entry.aiRecommendations,
      aiEmpathy: entry.aiEmpathy,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
      isPendingAnalysis: entry.isPendingAnalysis,
      hasSafetyAlert: entry.hasSafetyAlert,
    );
  }
}
