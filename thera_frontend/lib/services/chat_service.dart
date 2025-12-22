import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/secret.dart';
import 'secure_storage_service.dart';
import '../models/chat_message.dart';

class ChatService {
  /// SEND MESSAGE TO AI
  Future<ChatMessage> sendMessage(String message, String token) async {
    try {
      final url = Uri.parse(ApiConfig.sendMessage);

      final tokenDisplay = (token != null && token.isNotEmpty)
          ? '${token.substring(0, 8)}...'
          : 'NONE';

      debugPrint('ChatService: POST $url');
      debugPrint(
        'ChatService: headers: Content-Type: application/json, Authorization: Bearer $tokenDisplay',
      );
      debugPrint('ChatService: body: ${jsonEncode({'message': message})}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token != null && token.isNotEmpty
              ? 'Bearer $token'
              : '',
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
        final body = utf8.decode(response.bodyBytes);
        // Log detailed server error for debugging
        debugPrint('ChatService: server error ${response.statusCode} - $body');

        // Try external AI fallback (uses FALLBACK_AI_API_KEY from secret.dart)
        try {
          final external = await _callExternalAi(message);
          if (external != null && external.isNotEmpty) {
            return ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch,
              sender: 'assistant',
              message: external,
              timestamp: DateTime.now(),
            );
          }
        } catch (e) {
          debugPrint('ChatService: external AI fallback failed: $e');
        }

        // External failed — use a local rule-based reply so the app always responds.
        final local = _localRuleReply(message);
        if (local.isNotEmpty) {
          return ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch,
            sender: 'assistant',
            message: local,
            timestamp: DateTime.now(),
            isFallback: true,
          );
        }

        // Provide a graceful, helpful offline fallback as last resort
        return ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch,
          sender: 'assistant',
          message:
              'Sorry, I couldn\'t respond. Error: Server error: ${response.statusCode}${body.isNotEmpty ? ': $body' : ''}',
          timestamp: DateTime.now(),
          isFallback: true,
        );
      }
    } catch (e) {
      debugPrint('ChatService exception: $e');

      // Try external AI fallback before giving a local fallback
      try {
        final external = await _callExternalAi(message);
        if (external != null && external.isNotEmpty) {
          return ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch,
            sender: 'assistant',
            message: external,
            timestamp: DateTime.now(),
          );
        }
      } catch (e2) {
        debugPrint('ChatService: external AI fallback failed: $e2');
      }

      // Local fallback reply so the assistant still appears responsive.
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        sender: 'assistant',
        message:
            'I\'m currently offline but heard: "$message". I\'ll reply better once the server is available.',
        timestamp: DateTime.now(),
        isFallback: true,
      );
    }
  }

  /// Call external OpenAI-compatible chat completions as a fallback
  Future<String?> _callExternalAi(String message) async {
    try {
      final url = Uri.parse(FALLBACK_AI_URL);

      // Prefer a key stored securely on-device; fall back to the compiled secret.
      final storedKey = await SecureStorageService.getFallbackApiKey();
      final chosenKey = (storedKey != null && storedKey.isNotEmpty)
          ? storedKey
          : FALLBACK_AI_API_KEY;
      final keyDisplay = (chosenKey != null && chosenKey.length > 8)
          ? '${chosenKey.substring(0, 8)}...'
          : 'NONE';

      debugPrint('ChatService: External AI POST $url');
      debugPrint(
        'ChatService: External headers: Authorization: Bearer $keyDisplay',
      );

      final body = jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': message},
        ],
        'max_tokens': 512,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${chosenKey ?? ''}',
        },
        body: body,
      );

      debugPrint('ChatService: External AI response ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // OpenAI Chat Completions: choices[0].message.content
        final content = data['choices']?[0]?['message']?['content'];
        if (content != null) return content.toString().trim();
      } else {
        debugPrint('ChatService: External AI error body: ${response.body}');
      }
    } catch (e) {
      debugPrint('ChatService: External AI exception: $e');
    }

    return null;
  }

  /// Lightweight local rule-based reply used when both backend and external AI fail.
  String _localRuleReply(String message) {
    final m = message.toLowerCase();

    if (m.contains('hello') || m.contains('hi') || m.contains('hey')) {
      return 'Hi — nice to hear from you! How can I help today?';
    }

    if (m.contains('sad') || m.contains('depress') || m.contains('unhappy')) {
      return 'I\'m sorry you\'re feeling down. Would you like to talk about what\'s been happening?';
    }

    if (m.contains('anx') || m.contains('anxious') || m.contains('worried')) {
      return 'It sounds like you\'re feeling anxious. Try taking a few deep breaths — inhaling slowly for 4 seconds, holding for 4, and exhaling for 6.';
    }

    if (m.contains('help') || m.contains('support')) {
      return 'I can listen and offer suggestions. Tell me more about what you\'re facing.';
    }

    // Default: reflective prompt + small suggestion
    final short = message.length > 120
        ? '${message.substring(0, 117)}...'
        : message;
    return 'You said: "$short". That\'s understandable — one small step you could try is to write down one thing that felt okay today.';
  }
}
