import 'package:flutter/material.dart';
import 'package:mydairy/app/core/enums/mood_enum.dart';

class GradientColors {
  // Beautiful gradient combinations for each mood
  static const Map<MoodType, List<Color>> moodGradients = {
    MoodType.happy: [
      Color(0xFFFFD700), // Gold
      Color(0xFFFFE066), // Light Gold
      Color(0xFFFFF4CC), // Pale Gold
    ],
    MoodType.sad: [
      Color(0xFF4169E1), // Royal Blue
      Color(0xFF6495ED), // Cornflower Blue
      Color(0xFF87CEEB), // Sky Blue
    ],
    MoodType.angry: [
      Color(0xFFDC143C), // Crimson
      Color(0xFFFF6B6B), // Light Red
      Color(0xFFFFB3B3), // Pale Red
    ],
    MoodType.anxious: [
      Color(0xFFFF6347), // Tomato
      Color(0xFFFF8C69), // Salmon
      Color(0xFFFFB6A3), // Light Salmon
    ],
    MoodType.neutral: [
      Color(0xFF808080), // Gray
      Color(0xFFA9A9A9), // Dark Gray
      Color(0xFFD3D3D3), // Light Gray
    ],
    MoodType.motivated: [
      Color(0xFF32CD32), // Lime Green
      Color(0xFF66DD66), // Light Green
      Color(0xFF99EE99), // Pale Green
    ],
  };

  // Alternative gradient styles
  static const Map<String, List<Color>> themeGradients = {
    'sunset': [
      Color(0xFFFF6B6B),
      Color(0xFFFFD93D),
      Color(0xFFFFF9B0),
    ],
    'ocean': [
      Color(0xFF667EEA),
      Color(0xFF764BA2),
      Color(0xFFF093FB),
    ],
    'forest': [
      Color(0xFF134E5E),
      Color(0xFF71B280),
      Color(0xFFB2DFDB),
    ],
    'lavender': [
      Color(0xFF9796F0),
      Color(0xFFFBC7D4),
      Color(0xFFFFE6F0),
    ],
    'peach': [
      Color(0xFFED4264),
      Color(0xFFFFEDBC),
      Color(0xFFFFF5E6),
    ],
    'mint': [
      Color(0xFF00B4DB),
      Color(0xFF0083B0),
      Color(0xFF00D9FF),
    ],
    'rose': [
      Color(0xFFEB3349),
      Color(0xFFF45C43),
      Color(0xFFFFB6B9),
    ],
    'cosmic': [
      Color(0xFF4E54C8),
      Color(0xFF8F94FB),
      Color(0xFFE0C3FC),
    ],
  };

  // Get gradient colors for a mood
  static List<Color> getGradientForMood(MoodType mood) {
    return moodGradients[mood] ?? moodGradients[MoodType.neutral]!;
  }

  // Get gradient colors by theme name
  static List<Color> getThemeGradient(String themeName) {
    return themeGradients[themeName] ?? themeGradients['sunset']!;
  }

  // Create LinearGradient from mood
  static LinearGradient getMoodLinearGradient(
    MoodType mood, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: getGradientForMood(mood),
      begin: begin,
      end: end,
    );
  }

  // Create RadialGradient from mood
  static RadialGradient getMoodRadialGradient(MoodType mood) {
    final colors = getGradientForMood(mood);
    return RadialGradient(
      colors: colors,
      center: Alignment.topLeft,
      radius: 1.5,
    );
  }
}
