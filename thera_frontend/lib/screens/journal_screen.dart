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
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      hintText: 'Add a note...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        debugPrint('JournalScreen: User ID: ${auth.user?.id}, Role: ${auth.user?.role}');
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
                          
                          if (e.toString().contains('403')) {
                               // Server rejected request (e.g., offline or auth issue).
                               // Show a friendly message but keep the user logged in.
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Could not sync with server, saved locally.')),
                               );
                             } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to add emotion: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Save Reflection'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Recent Entries',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${journal.entries.length} items',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: journal.entries.length,
                itemBuilder: (_, i) {
                  final e = journal.entries[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _getEmojiForMood(e.mood),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Text(
                        e.mood.substring(0, 1).toUpperCase() + e.mood.substring(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Intensity: ${e.intensity}/5'),
                          if (e.note != null && e.note!.isNotEmpty)
                            Text(
                              e.note!,
                              style: TextStyle(color: Colors.white.withOpacity(0.6)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      trailing: Text(
                        'Fixed', // Placeholder for date or status
                        style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.3)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmojiForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy': return '😊';
      case 'sad': return '😢';
      case 'anxious': return '😰';
      case 'angry': return '😡';
      case 'calm': return '😌';
      default: return '😐';
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }
}
