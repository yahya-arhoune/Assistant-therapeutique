import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'journal_screen.dart';
import 'chat_screen.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Screens depend on role
    final screens = [
      const JournalScreen(),
      const ChatScreen(),
      if (auth.isAdmin) const DashboardScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome ${auth.user?.username ?? ''}'),
            Text(
              auth.user?.role ?? '',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),

      body: screens[_index],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) {
          setState(() => _index = i);
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Journal',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          if (auth.isAdmin)
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Dashboard',
            ),
        ],
      ),
    );
  }
}
