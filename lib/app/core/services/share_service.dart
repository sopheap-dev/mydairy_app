import 'package:flutter/services.dart';
import 'package:mydairy/domain/entities/diary_entry.dart';
import 'package:intl/intl.dart';

class ShareService {
  /// Share entry as text
  static Future<void> shareEntryAsText(DiaryEntry entry) async {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final text = _buildShareText(entry, dateFormat);

    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Get shareable text for entry
  static String _buildShareText(DiaryEntry entry, DateFormat dateFormat) {
    final buffer = StringBuffer();

    // Title and date
    buffer.writeln('📔 ${entry.title}');
    buffer.writeln('📅 ${dateFormat.format(entry.date)}');
    buffer.writeln();

    // Mood if available
    if (entry.aiMood != null) {
      buffer.writeln('${entry.aiMood!.emoji} Mood: ${entry.aiMood!.label}');
      buffer.writeln();
    }

    // Summary or body
    if (entry.aiSummary != null && entry.aiSummary!.isNotEmpty) {
      buffer.writeln('Summary:');
      buffer.writeln(entry.aiSummary);
    } else {
      buffer.writeln('Entry:');
      buffer.writeln(entry.body);
    }

    // Tags
    if (entry.tags.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Tags: ${entry.tags.join(", ")}');
    }

    buffer.writeln();
    buffer.writeln('---');
    buffer.writeln('Shared from My Diary App');

    return buffer.toString();
  }

  /// Share entry with mood insights
  static String buildShareableInsight(DiaryEntry entry) {
    final buffer = StringBuffer();

    if (entry.aiMood != null) {
      buffer.writeln('${entry.aiMood!.emoji} Feeling ${entry.aiMood!.label} today');
      buffer.writeln();
    }

    if (entry.aiSummary != null) {
      buffer.writeln(entry.aiSummary);
    }

    if (entry.aiEmpathy != null) {
      buffer.writeln();
      buffer.writeln('💙 ${entry.aiEmpathy}');
    }

    return buffer.toString();
  }

  /// Create a privacy-safe share (without diary content)
  static String buildPrivacyShareText(DiaryEntry entry) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final buffer = StringBuffer();

    buffer.writeln('📔 My Diary Entry');
    buffer.writeln('📅 ${dateFormat.format(entry.date)}');
    buffer.writeln();

    if (entry.aiMood != null) {
      buffer.writeln('${entry.aiMood!.emoji} Mood: ${entry.aiMood!.label}');
    }

    if (entry.tags.isNotEmpty) {
      buffer.writeln('Tags: ${entry.tags.join(", ")}');
    }

    buffer.writeln();
    buffer.writeln('I\'m tracking my mood and emotional wellness with My Diary App');

    return buffer.toString();
  }
}
