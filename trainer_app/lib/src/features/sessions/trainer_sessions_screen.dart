import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers.dart';

class TrainerSessionsScreen extends ConsumerWidget {
  const TrainerSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserStreamProvider).valueOrNull;
    if (me == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final logs = ref.watch(_logsProvider(me.id));
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: logs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('No sessions yet.'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final s = items[i];
              return Card(
                child: ListTile(
                  title: Text('Member: ${s.memberId}  •  ${s.durationSec}s'),
                  subtitle: Text('Rating: ${s.rating ?? '-'}  Notes: ${s.notes ?? '-'}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

final _logsProvider =
    StreamProvider.family<List<SessionLog>, String>((ref, trainerId) {
  final s = ref.watch(sessionLogServiceProvider)!;
  return s.watchForTrainer(trainerId);
});

