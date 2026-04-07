import 'package:flutter/material.dart';

import '../chat/guru_chat_screen.dart';
import '../schedule/guru_schedule_screen.dart';
import '../sessions/guru_sessions_screen.dart';

class GuruHomeShell extends StatefulWidget {
  const GuruHomeShell({super.key});

  @override
  State<GuruHomeShell> createState() => _GuruHomeShellState();
}

class _GuruHomeShellState extends State<GuruHomeShell> {
  int _index = 0;

  late final List<Widget> _tabs = <Widget>[
    _HomeDashboard(onGo: (i) => setState(() => _index = i)),
    const GuruChatScreen(),
    const GuruScheduleScreen(),
    const GuruSessionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (v) => setState(() => _index = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'My Sessions',
          ),
        ],
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard({required this.onGo});

  final void Function(int index) onGo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guru')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Chat with Trainer'),
              subtitle: const Text('Message Aarav'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onGo(1),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Schedule Call'),
              subtitle: const Text('Pick a 30-min slot'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onGo(2),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('My Sessions'),
              subtitle: const Text('Review past sessions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onGo(3),
            ),
          ),
        ],
      ),
    );
  }
}

