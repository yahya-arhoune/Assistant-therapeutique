class EmotionEntry {
  final int id;
  final String mood; // ex: happy, sad, anxious
  final int intensity; // 1 → 5
  final String note;
  final DateTime createdAt;

  EmotionEntry({
    required this.id,
    required this.mood,
    required this.intensity,
    required this.note,
    required this.createdAt,
  });

  factory EmotionEntry.fromJson(Map<String, dynamic> json) {
    return EmotionEntry(
      id: json['id'],
      mood: json['mood'],
      intensity: json['intensity'],
      note: json['note'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'mood': mood, 'intensity': intensity, 'note': note};
  }
}
