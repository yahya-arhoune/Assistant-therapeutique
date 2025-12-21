import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api';
    // For physical device, use computer's LAN IP. 
    // For emulator, 10.0.2.2 works, but LAN IP usually works for both.
    if (Platform.isAndroid) return 'http://192.168.110.104:8080/api';
    return 'http://localhost:8080/api';
  }

  /// Authentication
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';

  /// Emotional Journal
  static String get createEmotion => '$baseUrl/journal/create';
  static String get getEmotions => '$baseUrl/journal/all';

  /// AI Chat
  static String get sendMessage => '$baseUrl/chat/send';

  /// User profile (optional)
  static String get profile => '$baseUrl/user/profile';
}
