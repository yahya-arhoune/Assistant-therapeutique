import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/emotion_entry.dart';
import '../services/journal_service.dart';

class JournalProvider with ChangeNotifier {
  final JournalService _journalService = JournalService();

  List<EmotionEntry> _entries = [];
  // Entries created locally when server is unreachable. These persist
  // in memory for the app session (until the app exits).
  final List<EmotionEntry> _pendingEntries = [];
  bool _isLoading = false;

  JournalProvider() {
    _loadPendingFromStorage();
  }

  List<EmotionEntry> get entries => _entries;
  List<EmotionEntry> get pendingEntries => _pendingEntries;
  bool get isLoading => _isLoading;

  static const _kPendingKey = 'pending_journal_entries';

  Future<void> _savePendingToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _pendingEntries
          .map(
            (e) => jsonEncode(
              e.toJson()..addAll({
                'id': e.id,
                'createdAt': e.createdAt.toIso8601String(),
              }),
            ),
          )
          .toList();
      await prefs.setStringList(_kPendingKey, jsonList);
    } catch (e) {
      debugPrint('JournalProvider: failed to save pending to storage: $e');
    }
  }

  Future<void> _loadPendingFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_kPendingKey) ?? [];
      _pendingEntries.clear();
      for (final s in list) {
        try {
          final Map<String, dynamic> m = jsonDecode(s);
          // Ensure createdAt present
          if (m['createdAt'] is String) {
            _pendingEntries.add(EmotionEntry.fromJson(m));
          }
        } catch (err) {
          debugPrint('JournalProvider: failed to parse pending entry: $err');
        }
      }
      // Merge pending into displayed entries if currently loaded
      if (_entries.isNotEmpty) {
        _entries = [..._entries, ..._pendingEntries];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('JournalProvider: failed to load pending from storage: $e');
    }
  }

  /// LOAD JOURNAL ENTRIES
  Future<void> loadEntries(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final serverEntries = await _journalService.getEmotions(token);
      // Merge server entries with any locally pending (unsynced) entries
      _entries = [...serverEntries, ..._pendingEntries];
      // After loading server entries, try to sync any pending entries
      // in the background. This will attempt to send pending entries
      // to the server and refresh entries on success.
      trySyncPending(token);
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
      _pendingEntries.add(fallbackEntry);
      _entries.add(fallbackEntry);
      await _savePendingToStorage();
      notifyListeners();
    }
  }

  /// Try to sync any locally pending entries with the server.
  Future<void> trySyncPending(String token) async {
    if (_pendingEntries.isEmpty) return;
    // Work on a copy to avoid modification during iteration
    final copy = List<EmotionEntry>.from(_pendingEntries);
    for (final e in copy) {
      try {
        await _journalService.createEmotion(e.mood, e.intensity, e.note, token);
        // On success, remove from pending
        _pendingEntries.removeWhere((p) => p.id == e.id);
        await _savePendingToStorage();
      } catch (err) {
        // If any entry still fails, leave it in pending and continue
        debugPrint('JournalProvider: trySyncPending failed for ${e.id}: $err');
      }
    }
    // Refresh the entries list to reflect any newly-synced items
    try {
      final server = await _journalService.getEmotions(token);
      _entries = [...server, ..._pendingEntries];
      notifyListeners();
    } catch (_) {
      // Ignore — we'll keep showing pending entries until next attempt
    }
  }
}
