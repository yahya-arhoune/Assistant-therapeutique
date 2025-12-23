import 'package:flutter/material.dart';
import '../services/secure_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _controller = TextEditingController();
  bool _loading = true;
  bool _preferLocal = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final k = await SecureStorageService.getFallbackApiKey();
    if (k != null) _controller.text = k;
    final p = await SecureStorageService.getPreferLocalAssistant();
    setState(() {
      _loading = false;
      _preferLocal = p;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'External AI Fallback Key',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Paste OpenAI-compatible API key (optional)',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await SecureStorageService.setFallbackApiKey(
                            _controller.text.trim(),
                          );
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Saved')),
                          );
                        },
                  child: const Text('Save'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await SecureStorageService.deleteFallbackApiKey();
                          _controller.clear();
                          if (!mounted) return;
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Removed')),
                          );
                        },
                  child: const Text('Remove'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Prefer Local Assistant'),
              subtitle: const Text(
                'When enabled the app will respond using the built-in assistant before contacting the server or external AI.',
              ),
              value: _preferLocal,
              onChanged: _loading
                  ? null
                  : (v) async {
                      await SecureStorageService.setPreferLocalAssistant(v);
                      if (!mounted) return;
                      setState(() => _preferLocal = v);
                    },
            ),
            const SizedBox(height: 8),
            const Text('Note: Saved keys are stored securely on-device.'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
