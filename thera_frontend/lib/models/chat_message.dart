class ChatMessage {
  final int id;
  final String sender; // "user" or "assistant"
  final String message;
  final DateTime timestamp;
  final bool isFallback;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.message,
    required this.timestamp,
    this.isFallback = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      sender: json['sender'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isFallback: json['isFallback'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'sender': sender, 'message': message};
  }
}
