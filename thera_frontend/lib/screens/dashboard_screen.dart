import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final journal = Provider.of<JournalProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: Text(
          'Total entries: ${journal.entries.length}',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
