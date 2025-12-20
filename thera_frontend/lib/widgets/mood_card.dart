import 'package:flutter/material.dart';
import '../models/emotion_entry.dart';

class MoodCard extends StatelessWidget {
  final EmotionEntry entry;

  const MoodCard({super.key, required this.entry});

  IconData _iconForMood(String mood) {
    switch (mood) {
      case 'happy':
        return Icons.sentiment_very_satisfied;
      case 'sad':
        return Icons.sentiment_dissatisfied;
      case 'anxious':
        return Icons.mood_bad;
      case 'angry':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: ListTile(
        leading: Icon(_iconForMood(entry.mood), size: 30),
        title: Text(entry.mood.toUpperCase()),
        subtitle: Text(entry.note),
        trailing: Text('⭐ ${entry.intensity}'),
      ),
    );
  }
}
