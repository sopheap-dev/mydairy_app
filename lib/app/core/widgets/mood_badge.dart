import 'package:flutter/material.dart';
import 'package:mydairy/app/core/enums/mood_enum.dart';

class MoodBadge extends StatelessWidget {
  final MoodType mood;
  final bool showLabel;
  final double size;

  const MoodBadge({
    required this.mood,
    this.showLabel = true,
    this.size = 40,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(
      int.parse(mood.colorHex.replaceAll('#', '0xFF')),
    );

    if (!showLabel) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            mood.emoji,
            style: TextStyle(fontSize: size * 0.5),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            mood.emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
          Text(
            mood.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
