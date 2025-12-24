import 'package:equatable/equatable.dart';
import 'package:mydairy/app/core/enums/mood_enum.dart';

class DiaryEntry extends Equatable {
  final String id;
  final DateTime date;
  final String title;
  final String body;
  final List<String> tags;
  final String? aiSummary;
  final MoodType? aiMood;
  final double? aiConfidence;
  final List<String>? aiRecommendations;
  final String? aiEmpathy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPendingAnalysis;
  final bool hasSafetyAlert;

  const DiaryEntry({
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

  DiaryEntry copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? body,
    List<String>? tags,
    String? aiSummary,
    MoodType? aiMood,
    double? aiConfidence,
    List<String>? aiRecommendations,
    String? aiEmpathy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPendingAnalysis,
    bool? hasSafetyAlert,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      body: body ?? this.body,
      tags: tags ?? this.tags,
      aiSummary: aiSummary ?? this.aiSummary,
      aiMood: aiMood ?? this.aiMood,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      aiRecommendations: aiRecommendations ?? this.aiRecommendations,
      aiEmpathy: aiEmpathy ?? this.aiEmpathy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPendingAnalysis: isPendingAnalysis ?? this.isPendingAnalysis,
      hasSafetyAlert: hasSafetyAlert ?? this.hasSafetyAlert,
    );
  }

  @override
  List<Object?> get props => [
    id,
    date,
    title,
    body,
    tags,
    aiSummary,
    aiMood,
    aiConfidence,
    aiRecommendations,
    aiEmpathy,
    createdAt,
    updatedAt,
    isPendingAnalysis,
    hasSafetyAlert,
  ];
}
