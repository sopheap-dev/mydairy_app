import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mydairy/app/core/enums/mood_enum.dart';
import 'package:mydairy/domain/entities/ai_analysis.dart';

abstract class GroqRemoteDataSource {
  Future<AiAnalysis> analyzeEntry(String entryText, String apiKey);
  Future<bool> checkSafety(String entryText, String apiKey);
}

class GroqRemoteDataSourceImpl implements GroqRemoteDataSource {
  final Dio dio;
  static const String baseUrl = 'https://api.groq.com/openai/v1';
  static const String model = 'llama-3.3-70b-versatile';

  GroqRemoteDataSourceImpl(this.dio);

  @override
  Future<AiAnalysis> analyzeEntry(String entryText, String apiKey) async {
    try {
      final prompt = _buildCombinedPrompt(entryText);

      final response = await dio.post(
        '$baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.1,
          'max_tokens': 400,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      return _parseAnalysisResponse(content);
    } on DioException catch (e) {
      throw Exception('Failed to analyze entry: ${e.message}');
    }
  }

  @override
  Future<bool> checkSafety(String entryText, String apiKey) async {
    try {
      final prompt =
          '''
ONLY_JSON_START
Does the following text include signs of self-harm, suicidal ideation, or immediate danger? Return JSON {"safety_alert": true/false, "category": "none|self_harm|violence|abuse"}
ONLY_JSON_END

Text:
$entryText
''';

      final response = await dio.post(
        '$baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.0,
          'max_tokens': 80,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      final jsonContent = _extractJson(content);
      final parsed = json.decode(jsonContent);

      return parsed['safety_alert'] == true;
    } on DioException catch (e) {
      throw Exception('Failed to check safety: ${e.message}');
    }
  }

  String _buildCombinedPrompt(String entryText) {
    return '''
ONLY_JSON_START
You are an assistant that analyzes diary entries. For the diary entry provided, return a single JSON object with the exact fields shown below. Do not add any other keys.

Fields:
- summary: short 1-2 sentence summary of main events/emotions.
- mood: exactly one word from [Happy, Sad, Angry, Anxious, Neutral, Motivated].
- confidence: number between 0 and 1 representing mood confidence.
- recommendations: array of up to 3 short actionable activities (each <= 30 words).
- empathy: one short empathetic sentence (<= 18 words).

Rules:
- Use plain language; no emojis.
- Keep summary <= 2 sentences.
- recommendations should be practical, short, and prioritized (most helpful first).
- If the entry is ambiguous, pick Neutral and set confidence <= 0.5.
- If entry includes words implying self-harm, include only the field "safety_alert":true and do not provide recommendations.

Return JSON with this exact schema and nothing else. Example:
{
  "summary":"...",
  "mood":"Sad",
  "confidence":0.87,
  "recommendations":["...","..."],
  "empathy":"..."
}
ONLY_JSON_END

DiaryEntry:
$entryText
''';
  }

  AiAnalysis _parseAnalysisResponse(String content) {
    try {
      final jsonContent = _extractJson(content);
      final parsed = json.decode(jsonContent);

      // Check for safety alert
      if (parsed['safety_alert'] == true) {
        return AiAnalysis(
          summary: 'Content flagged for safety review',
          mood: MoodType.neutral,
          confidence: 1.0,
          recommendations: const [
            'Please reach out to a mental health professional',
            'Contact a crisis helpline if you need immediate support',
          ],
          empathy: 'Your wellbeing matters. Please seek support.',
          safetyAlert: true,
          safetyCategory: parsed['category'] ?? 'unknown',
        );
      }

      return AiAnalysis(
        summary: parsed['summary'] ?? '',
        mood: MoodType.fromString(parsed['mood'] ?? 'Neutral'),
        confidence: (parsed['confidence'] ?? 0.5).toDouble(),
        recommendations: List<String>.from(parsed['recommendations'] ?? []),
        empathy: parsed['empathy'] ?? '',
        safetyAlert: false,
      );
    } catch (e) {
      throw Exception('Failed to parse AI response: $e');
    }
  }

  String _extractJson(String content) {
    // Try to find JSON between ONLY_JSON_START and ONLY_JSON_END
    final startMarker = 'ONLY_JSON_START';
    final endMarker = 'ONLY_JSON_END';

    if (content.contains(startMarker) && content.contains(endMarker)) {
      final start = content.indexOf(startMarker) + startMarker.length;
      final end = content.indexOf(endMarker);
      content = content.substring(start, end).trim();
    }

    // Find the first { and last }
    final firstBrace = content.indexOf('{');
    final lastBrace = content.lastIndexOf('}');

    if (firstBrace != -1 && lastBrace != -1) {
      return content.substring(firstBrace, lastBrace + 1);
    }

    return content;
  }
}
