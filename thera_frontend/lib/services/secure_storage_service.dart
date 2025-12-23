import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _fallbackKey = 'fallback_api_key_v1';
  static final _storage = const FlutterSecureStorage();

  static Future<void> setFallbackApiKey(String key) async {
    if (kIsWeb) {
      return; // flutter_secure_storage not supported on web by default
    }
    await _storage.write(key: _fallbackKey, value: key);
  }

  static Future<String?> getFallbackApiKey() async {
    if (kIsWeb) {
      return null;
    }
    return await _storage.read(key: _fallbackKey);
  }

  static Future<void> deleteFallbackApiKey() async {
    if (kIsWeb) {
      return;
    }
    await _storage.delete(key: _fallbackKey);
  }

  // Preference: whether to prefer local assistant responses
  static const _preferLocalKey = 'prefer_local_assistant_v1';

  static Future<void> setPreferLocalAssistant(bool prefer) async {
    if (kIsWeb) return;
    await _storage.write(key: _preferLocalKey, value: prefer ? '1' : '0');
  }

  static Future<bool> getPreferLocalAssistant() async {
    if (kIsWeb) return false;
    final v = await _storage.read(key: _preferLocalKey);
    return v == '1';
  }
}
