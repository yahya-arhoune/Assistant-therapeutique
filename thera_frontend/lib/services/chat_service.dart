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

      final tokenDisplay = (token.isNotEmpty)
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
          'Authorization': token.isNotEmpty ? 'Bearer $token' : '',
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

        // Try external AI fallback (Gemini) if backend fails
        try {
          final external = await _callExternalAi(message);
          if (external != null && external.isNotEmpty) {
            return ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch,
              sender: 'assistant',
              message: external,
              timestamp: DateTime.now(),
              isFallback: true,
            );
          }
        } catch (e) {
          debugPrint('ChatService: external AI fallback failed: $e');
        }

        // No offline/local chat: return an error message.
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

      // Try external AI fallback before giving up
      try {
        final external = await _callExternalAi(message);
        if (external != null && external.isNotEmpty) {
          return ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch,
            sender: 'assistant',
            message: external,
            timestamp: DateTime.now(),
            isFallback: true,
          );
        }
      } catch (e2) {
        debugPrint('ChatService: external AI fallback failed: $e2');
      }

      // No offline/local chat: return an error message.
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        sender: 'assistant',
        message: 'Sorry, I couldn\'t respond. Please check your connection.',
        timestamp: DateTime.now(),
        isFallback: true,
      );
    }
  }

  /// Call external Gemini generateContent as a fallback
  Future<String?> _callExternalAi(String message) async {
    try {
      // Prefer a key stored securely on-device; fall back to the compiled secret.
      final storedKey = await SecureStorageService.getFallbackApiKey();
      final chosenKey = (storedKey != null && storedKey.isNotEmpty)
          ? storedKey
          : FALLBACK_AI_API_KEY;

      if (chosenKey.isEmpty) return null;

      final keyDisplay = chosenKey.length > 8
          ? '${chosenKey.substring(0, 8)}...'
          : '***';

      final systemPrompt =
          'You are a compassionate therapeutic assistant. Use empathic, non-judgmental language, validate emotions, offer brief reflective listening, and when appropriate suggest one or two small, practical coping strategies. Do not provide medical or legal advice. Keep responses supportive and concise.';

      // Gemini generateContent request
      final body = jsonEncode({
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt},
          ],
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': message},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topP': 0.9,
          'maxOutputTokens': 512,
        },
      });

      String? extractTextFromGeminiResponse(Object? decoded) {
        if (decoded is! Map) return null;
        final candidates = decoded['candidates'];
        if (candidates is List && candidates.isNotEmpty) {
          final content = (candidates[0] as Map?)?['content'];
          final parts = (content as Map?)?['parts'];
          if (parts is List && parts.isNotEmpty) {
            final text = (parts[0] as Map?)?['text'];
            return text?.toString().trim();
          }
        }
        return null;
      }

      Future<String?> tryGenerateContent(Uri endpoint) async {
        final safeEndpoint = endpoint.replace(
          queryParameters: {'key': keyDisplay},
        );
        debugPrint('ChatService: External AI POST $safeEndpoint');

        final response = await http.post(
          endpoint,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        debugPrint('ChatService: External AI response ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          return extractTextFromGeminiResponse(data);
        }

        // Bubble up helpful context in logs, but keep it short.
        final errBody = utf8.decode(response.bodyBytes);
        debugPrint(
          'ChatService: External AI error ${response.statusCode}: ${errBody.length > 500 ? '${errBody.substring(0, 500)}...' : errBody}',
        );
        return null;
      }

      Future<List<String>> listModels({
        required Uri base,
        required String version,
      }) async {
        final url = Uri(
          scheme: base.scheme,
          host: base.host,
          port: base.hasPort ? base.port : null,
          path: '/$version/models',
          queryParameters: {'key': chosenKey},
        );
        final safeUrl = url.replace(queryParameters: {'key': keyDisplay});
        debugPrint('ChatService: External AI ListModels GET $safeUrl');

        final resp = await http.get(url);
        if (resp.statusCode != 200) {
          final body = utf8.decode(resp.bodyBytes);
          debugPrint(
            'ChatService: External AI ListModels error ${resp.statusCode}: ${body.length > 300 ? '${body.substring(0, 300)}...' : body}',
          );
          return const [];
        }
        final decoded = jsonDecode(utf8.decode(resp.bodyBytes));
        if (decoded is! Map) return const [];
        final models = decoded['models'];
        if (models is! List) return const [];

        final names = <String>[];
        for (final m in models) {
          if (m is! Map) continue;
          final name = m['name']?.toString();
          if (name == null || name.isEmpty) continue;
          final methods = m['supportedGenerationMethods'];
          final supportsGenerate =
              methods is List &&
              methods.any((x) => x.toString() == 'generateContent');
          if (!supportsGenerate) continue;
          names.add(name);
        }
        return names;
      }

      // First try the configured endpoint directly.
      final configured = Uri.parse(
        FALLBACK_AI_URL,
      ).replace(queryParameters: {'key': chosenKey});
      final configuredText = await tryGenerateContent(configured);
      if (configuredText != null && configuredText.isNotEmpty) {
        return configuredText;
      }

      // If that fails (often due to model/version mismatch), try discovering
      // a supported model via ListModels and retry.
      final base = Uri.parse(FALLBACK_AI_URL);
      final pathSegments = base.pathSegments;
      final versionFromUrl = pathSegments.isNotEmpty
          ? pathSegments.first
          : 'v1beta';

      for (final version in <String>[versionFromUrl, 'v1beta', 'v1'].toSet()) {
        final modelNames = await listModels(base: base, version: version);
        if (modelNames.isEmpty) continue;

        // Prefer gemini models if available.
        String pickModel(List<String> names) {
          for (final n in names) {
            if (n.toLowerCase().contains('gemini')) return n;
          }
          return names.first;
        }

        final selected = pickModel(modelNames);
        final endpoint = Uri(
          scheme: base.scheme,
          host: base.host,
          port: base.hasPort ? base.port : null,
          path: '/$version/$selected:generateContent',
          queryParameters: {'key': chosenKey},
        );

        final text = await tryGenerateContent(endpoint);
        if (text != null && text.isNotEmpty) return text;
      }
    } catch (e) {
      debugPrint('ChatService: External AI exception: $e');
    }

    return null;
  }
}
