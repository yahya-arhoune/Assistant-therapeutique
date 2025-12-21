import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chat_message.dart';

class ChatService {
  /// SEND MESSAGE TO AI
  Future<ChatMessage> sendMessage(String message, String token) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.sendMessage),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // Handle both 'reply' (user's backend) and 'message' (standard) keys
        final replyText = data['reply'] ?? data['message'] ?? 'No response';
        
        return ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch,
          sender: 'assistant',
          message: replyText,
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }
}
