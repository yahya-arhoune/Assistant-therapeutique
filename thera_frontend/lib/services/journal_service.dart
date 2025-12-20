import 'dart:convert';
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
    print('JournalService: Creating emotion $mood'); // DEBUG
    final url = Uri.parse(ApiConfig.createEmotion);
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'mood': mood,
          'intensity': intensity,
          'note': note
        }),
      );

      print('JournalService: Create Response ${response.statusCode}'); // DEBUG

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to save emotion: ${response.statusCode}');
      }
    } catch (e) {
      print('JournalService: Create error: $e'); // DEBUG
      rethrow;
    }
  }

  /// GET ALL EMOTIONS
  Future<List<EmotionEntry>> getEmotions(String token) async {
    print('JournalService: Fetching emotions'); // DEBUG
    final url = Uri.parse(ApiConfig.getEmotions);

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('JournalService: Get Response ${response.statusCode}'); // DEBUG

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => EmotionEntry.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load emotions: ${response.statusCode}');
      }
    } catch (e) {
      print('JournalService: Get error: $e'); // DEBUG
      rethrow;
    }
  }
}
