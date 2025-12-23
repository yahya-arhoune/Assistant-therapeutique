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
    // If user prefers the local assistant, return that immediately.
    try {
      final preferLocal = await SecureStorageService.getPreferLocalAssistant();
      if (preferLocal) {
        final local = _localRuleReply(message);
        return ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch,
          sender: 'assistant',
          message: local,
          timestamp: DateTime.now(),
          isFallback: true,
        );
      }
    } catch (e) {
      // ignore preference errors and continue with normal flow
    }
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

      // System prompt to guide the external model to behave as a
      // compassionate therapeutic assistant (empathic, non-judgmental,
      // and focused on brief, actionable support and reflective listening).
      final systemPrompt =
          'You are a compassionate therapeutic assistant. Use empathic, non-judgmental language, validate emotions, offer brief reflective listening, and when appropriate suggest one or two small, practical coping strategies. Do not provide medical or legal advice. Keep responses supportive and concise.';

      final body = jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': message},
        ],
        'max_tokens': 512,
        'temperature': 0.7,
        'top_p': 0.9,
        'presence_penalty': 0.3,
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
      return 'I\'m sorry you\'re feeling down. Would you like to tell me more about what\'s been happening? I can listen or suggest small steps to help.';
    }

    if (m.contains('anx') || m.contains('anxious') || m.contains('worried')) {
      return 'It sounds like you\'re feeling anxious. Try grounding: take a slow breath in for 4 seconds, hold 4, and breathe out for 6. If you want, tell me what\'s on your mind.';
    }

    if (m.contains('help') || m.contains('support')) {
      return 'I can listen and offer suggestions. Tell me more about what you\'re facing, or say "small step" for one simple idea to try now.';
    }

    // If the user asked for a small actionable step
    if (m.contains('small step') || m.contains('one step')) {
      return 'One small step: take 5 minutes to notice one thing that felt neutral or slightly positive today — write it down. Small consistent actions add up.';
    }

    // Default: reflective prompt + suggestion
    final short = message.length > 120
        ? '${message.substring(0, 117)}...'
        : message;
    return 'I heard: "$short". That makes sense. If you\'d like, I can help break this down into a small next step or just listen.';
  }
}
