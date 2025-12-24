enum MoodType {
  happy('Happy', '😊', '#FFD700'),
  sad('Sad', '😢', '#4169E1'),
  angry('Angry', '😠', '#DC143C'),
  anxious('Anxious', '😰', '#FF6347'),
  neutral('Neutral', '😐', '#808080'),
  motivated('Motivated', '💪', '#32CD32');

  const MoodType(this.label, this.emoji, this.colorHex);

  final String label;
  final String emoji;
  final String colorHex;

  static MoodType fromString(String value) {
    return MoodType.values.firstWhere(
      (mood) => mood.label.toLowerCase() == value.toLowerCase(),
      orElse: () => MoodType.neutral,
    );
  }
}
