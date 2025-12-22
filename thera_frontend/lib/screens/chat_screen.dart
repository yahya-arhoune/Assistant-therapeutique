import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';
import '../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final messages = <ChatMessage>[];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final m = messages[index];
                final isUser = m.sender == 'user';
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha((0.2 * 255).round())
                          : (m.isFallback
                                ? Colors.orange.withAlpha((0.12 * 255).round())
                                : Colors.white.withAlpha((0.05 * 255).round())),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 20),
                      ),
                      border: Border.all(
                        color: isUser
                            ? Theme.of(context).colorScheme.primary.withAlpha(
                                (0.3 * 255).round(),
                              )
                            : Colors.white.withAlpha((0.1 * 255).round()),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (m.isFallback && !isUser)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Text(
                              'Offline reply',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange.withAlpha(
                                  (0.95 * 255).round(),
                                ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Text(m.message, style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.05 * 255).round()),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              border: Border.all(
                color: Colors.white.withAlpha((0.1 * 255).round()),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(
                        color: Colors.white.withAlpha((0.3 * 255).round()),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: () async {
                      if (controller.text.isEmpty) return;
                      setState(() {
                        messages.add(
                          ChatMessage(
                            id: DateTime.now().millisecondsSinceEpoch,
                            sender: 'user',
                            message: controller.text,
                            timestamp: DateTime.now(),
                          ),
                        );
                      });
                      final userMessage = controller.text;
                      controller.clear();
                      try {
                        final response = await ChatService().sendMessage(
                          userMessage,
                          auth.token!,
                        );
                        setState(() {
                          messages.add(response);
                        });
                        if (response.isFallback) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Assistant is offline — showing a fallback reply.',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          messages.add(
                            ChatMessage(
                              id: DateTime.now().millisecondsSinceEpoch,
                              sender: 'assistant',
                              message: 'Sorry, I couldn\'t respond. Error: $e',
                              timestamp: DateTime.now(),
                              isFallback: true,
                            ),
                          );
                        });
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Assistant is offline — showing a fallback reply.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
