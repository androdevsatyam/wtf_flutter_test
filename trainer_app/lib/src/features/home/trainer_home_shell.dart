import 'package:flutter/material.dart';

import '../members/trainer_members_screen.dart';
import '../chats/trainer_chats_screen.dart';
import '../requests/trainer_requests_screen.dart';
import '../sessions/trainer_sessions_screen.dart';

class TrainerHomeShell extends StatefulWidget {
  const TrainerHomeShell({super.key});

  @override
  State<TrainerHomeShell> createState() => _TrainerHomeShellState();
}

class _TrainerHomeShellState extends State<TrainerHomeShell> {
  int _index = 0;

  static const _tabs = <Widget>[
    TrainerMembersScreen(),
    TrainerChatsScreen(),
    TrainerRequestsScreen(),
    TrainerSessionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (v) => setState(() => _index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.group_outlined), label: 'Members'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
          NavigationDestination(icon: Icon(Icons.inbox_outlined), label: 'Requests'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Sessions'),
        ],
      ),
    );
  }
}

