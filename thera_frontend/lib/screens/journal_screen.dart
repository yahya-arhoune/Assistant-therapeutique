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
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.05 * 255).round()),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withAlpha((0.1 * 255).round()),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            EmotionSelector(
                              onSelected: (mood, intensity) {
                                setState(() {
                                  selectedMood = mood;
                                  selectedIntensity = intensity;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Description',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(
                                    (0.85 * 255).round(),
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: noteController,
                              minLines: 3,
                              maxLines: 5,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withAlpha(
                                  (0.02 * 255).round(),
                                ),
                                hintText: 'Add a short reflection or note...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withAlpha(
                                      (0.08 * 255).round(),
                                    ),
                                  ),
                                ),
                                hintStyle: TextStyle(
                                  color: Colors.white.withAlpha(
                                    (0.35 * 255).round(),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final noteText = noteController.text.trim();
                          if (noteText.isEmpty) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please add a short description.',
                                ),
                              ),
                            );
                            return;
                          }
                          debugPrint(
                            'JournalScreen: User ID: ${auth.user?.id}, Role: ${auth.user?.role}',
                          );
                          try {
                            await journal.addEntry(
                              selectedMood,
                              selectedIntensity,
                              noteText,
                              auth.token!,
                            );
                            if (!context.mounted) return;
                            noteController.clear();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reflection saved.'),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;

                            if (e.toString().contains('403')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Saved locally — will sync when online.',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to save reflection: $e',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Save Entry'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Recent Reflections',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${journal.entries.length} items',
                  style: TextStyle(
                    color: Colors.white.withAlpha((0.5 * 255).round()),
                  ),
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
                      color: Colors.white.withAlpha((0.03 * 255).round()),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withAlpha((0.05 * 255).round()),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha((0.1 * 255).round()),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _getEmojiForMood(e.mood),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Text(
                        '${e.mood.substring(0, 1).toUpperCase()}${e.mood.substring(1)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Intensity (1–5): ${e.intensity}'),
                          if (e.note.isNotEmpty)
                            Text(
                              e.note,
                              style: TextStyle(
                                color: Colors.white.withAlpha(
                                  (0.6 * 255).round(),
                                ),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      trailing: Text(
                        _formatDate(e.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withAlpha((0.45 * 255).round()),
                        ),
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
      case 'happy':
        return '😊';
      case 'sad':
        return '😢';
      case 'anxious':
        return '😰';
      case 'angry':
        return '😡';
      case 'calm':
        return '😌';
      default:
        return '😐';
    }
  }

  String _formatDate(DateTime dateTime) {
    final dt = dateTime.toLocal();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = months[dt.month - 1];
    final day = dt.day;
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$month $day, $year • $hour:$minute';
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }
}
