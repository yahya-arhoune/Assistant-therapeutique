import '../models/chat_message.dart';

class ChatService {
  /// SEND MESSAGE TO AI
  Future<ChatMessage> sendMessage(String message, String token) async {
    // Mock implementation - replace with actual API call
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      sender: 'assistant',
      message:
          'This is a mock response to: "$message". Please implement the backend AI service.',
      timestamp: DateTime.now(),
    );
    // final response = await http.post(
    //   Uri.parse(ApiConfig.sendMessage),
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'Authorization': 'Bearer $token',
    //   },
    //   body: jsonEncode({'message': message}),
    // );
    // if (response.statusCode == 200) {
    //   return ChatMessage.fromJson(jsonDecode(response.body));
    // } else {
    //   throw Exception('Failed to send message');
    // }
  }
}
