import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers.dart';

class TrainerMembersScreen extends ConsumerWidget {
  const TrainerMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserStreamProvider).valueOrNull;
    if (me == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final users = ref.watch(_usersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (items) {
          final members = items.where((u) => u.role == Role.member && u.assignedTrainerId == me.id).toList();
          if (members.isEmpty) return const Center(child: Text('No members assigned.'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final m = members[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(m.name.substring(0, 1))),
                  title: Text(m.name),
                  subtitle: Text(m.email),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

final _usersProvider = StreamProvider<List<User>>((ref) {
  final repo = ref.watch(userRepoProvider)!;
  return repo.watchAll();
});

