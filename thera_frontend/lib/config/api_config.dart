class ApiConfig {
  static const String baseUrl = 'http://localhost:8080/api';

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
