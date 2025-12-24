import 'package:equatable/equatable.dart';
import 'package:mydairy/app/core/enums/mood_enum.dart';

class AiAnalysis extends Equatable {
  final String summary;
  final MoodType mood;
  final double confidence;
  final List<String> recommendations;
  final String empathy;
  final bool safetyAlert;
  final String? safetyCategory;

  const AiAnalysis({
    required this.summary,
    required this.mood,
    required this.confidence,
    required this.recommendations,
    required this.empathy,
    this.safetyAlert = false,
    this.safetyCategory,
  });

  @override
  List<Object?> get props => [
    summary,
    mood,
    confidence,
    recommendations,
    empathy,
    safetyAlert,
    safetyCategory,
  ];
}
