import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/journal_provider.dart';
import '../widgets/emotion_selector.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  String selectedMood = 'happy';
  int selectedIntensity = 5;
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final journal = Provider.of<JournalProvider>(context, listen: false);
      journal.loadEntries(auth.token!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final journal = Provider.of<JournalProvider>(context);

    if (auth.token == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to use the journal')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Emotion Journal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            EmotionSelector(
              onSelected: (mood, intensity) {
                setState(() {
                  selectedMood = mood;
                  selectedIntensity = intensity;
                });
              },
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await journal.addEntry(
                    selectedMood,
                    selectedIntensity,
                    noteController.text,
                    auth.token!,
                  );
                  if (!context.mounted) return;
                  noteController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Emotion added!')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add emotion: $e')),
                  );
                }
              },
              child: const Text('Add Emotion'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: journal.entries.length,
                itemBuilder: (_, i) {
                  final e = journal.entries[i];
                  return ListTile(
                    title: Text(e.mood),
                    subtitle: Text('${e.intensity} - ${e.note}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }
}
