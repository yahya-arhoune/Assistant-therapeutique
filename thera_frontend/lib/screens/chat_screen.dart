import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final messages = <String>[];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Therapeutic Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: messages.map((m) => ListTile(title: Text(m))).toList(),
            ),
          ),
          Row(
            children: [
              Expanded(child: TextField(controller: controller)),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  if (controller.text.isEmpty) return;
                  setState(() {
                    messages.add('You: ${controller.text}');
                  });
                  final userMessage = controller.text;
                  controller.clear();
                  try {
                    final response = await ChatService().sendMessage(
                      userMessage,
                      auth.token!,
                    );
                    setState(() {
                      messages.add('Assistant: ${response.message}');
                    });
                  } catch (e) {
                    setState(() {
                      messages.add(
                        'Assistant: Sorry, I couldn\'t respond. Error: $e',
                      );
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
