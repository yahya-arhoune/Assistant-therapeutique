import 'package:flutter/material.dart';
import '../models/emotion_entry.dart';
import '../services/journal_service.dart';

class JournalProvider with ChangeNotifier {
  final JournalService _journalService = JournalService();

  List<EmotionEntry> _entries = [];
  bool _isLoading = false;

  List<EmotionEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  /// LOAD JOURNAL ENTRIES
  Future<void> loadEntries(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _journalService.getEmotions(token);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ADD NEW EMOTION
  Future<void> addEntry(
    String mood,
    int intensity,
    String note,
    String token,
  ) async {
    try {
      await _journalService.createEmotion(mood, intensity, note, token);
      // Refresh list after adding
      await loadEntries(token);
    } catch (e) {
      // Fallback: add entry locally if server fails
      debugPrint('JournalProvider: addEntry fallback due to $e');
      final fallbackEntry = EmotionEntry(
        id: DateTime.now().millisecondsSinceEpoch,
        mood: mood,
        intensity: intensity,
        note: note,
        createdAt: DateTime.now(),
      );
      _entries.add(fallbackEntry);
      notifyListeners();
    }
  }
}
