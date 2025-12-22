import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:thera_frontend/config/api_config.dart';
import '../models/emotion_entry.dart';

class JournalService {
  /// CREATE EMOTION ENTRY
  Future<void> createEmotion(
    String mood,
    int intensity,
    String note,
    String token,
  ) async {
    debugPrint('JournalService: Creating emotion $mood'); // DEBUG
    final url = Uri.parse(ApiConfig.createEmotion);

    final tokenDisplay = (token != null && token.isNotEmpty)
        ? '${token.substring(0, 8)}...'
        : 'NONE';

    debugPrint('JournalService: POST $url');
    debugPrint(
      'JournalService: headers: Content-Type: application/json, Authorization: Bearer $tokenDisplay',
    );
    debugPrint(
      'JournalService: body: ${jsonEncode({'mood': mood, 'intensity': intensity, 'note': note})}',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token != null && token.isNotEmpty
              ? 'Bearer $token'
              : '',
        },
        body: jsonEncode({'mood': mood, 'intensity': intensity, 'note': note}),
      );

      debugPrint(
        'JournalService: Create Response ${response.statusCode}',
      ); // DEBUG

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint(
          'JournalService: createEmotion error body: ${response.body}',
        );
        throw Exception(
          'Failed to save emotion: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('JournalService: Create error: $e'); // DEBUG
      rethrow;
    }
  }

  /// GET ALL EMOTIONS
  Future<List<EmotionEntry>> getEmotions(String token) async {
    debugPrint('JournalService: Fetching emotions'); // DEBUG
    final url = Uri.parse(ApiConfig.getEmotions);

    final tokenDisplay = (token != null && token.isNotEmpty)
        ? '${token.substring(0, 8)}...'
        : 'NONE';

    debugPrint('JournalService: GET $url');
    debugPrint('JournalService: headers: Authorization: Bearer $tokenDisplay');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': token != null && token.isNotEmpty
              ? 'Bearer $token'
              : '',
          'Content-Type': 'application/json',
        },
      );

      debugPrint(
        'JournalService: Get Response ${response.statusCode}',
      ); // DEBUG

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => EmotionEntry.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load emotions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('JournalService: Get error: $e'); // DEBUG
      rethrow;
    }
  }
}
