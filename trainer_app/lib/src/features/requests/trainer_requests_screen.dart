import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers.dart';
import '../call/prejoin_screen.dart';

class TrainerRequestsScreen extends ConsumerWidget {
  const TrainerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserStreamProvider).valueOrNull;
    if (me == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final reqs = ref.watch(_requestsProvider(me.id));
    return Scaffold(
      appBar: AppBar(title: const Text('Requests')),
      body: reqs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (items) {
          final pending = items.where((r) => r.status == CallRequestStatus.pending).toList();
          final approved = items.where((r) => r.status == CallRequestStatus.approved).toList();

          if (pending.isEmpty && approved.isEmpty) {
            return const Center(child: Text('No requests.'));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text('Pending', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (pending.isEmpty) const Text('No pending requests.'),
              for (final r in pending) ...[
                Card(
                  child: ListTile(
                    title: Text(_slotLabel(r.scheduledFor)),
                    subtitle: Text('From: ${r.memberId}'),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            final call = ref.read(callServiceProvider)!;
                            await call.declineRequest(callRequestId: r.id, trainerId: me.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Declined')),
                              );
                            }
                          },
                          child: const Text('Decline'),
                        ),
                        FilledButton(
                          onPressed: () async {
                            final call = ref.read(callServiceProvider)!;
                            await call.approveRequest(callRequestId: r.id, trainerId: me.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Approved (room created)')),
                              );
                            }
                          },
                          child: const Text('Approve'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 8),
              Text('Approved', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (approved.isEmpty) const Text('No approved calls.'),
              for (final r in approved) _ApprovedTile(request: r, trainerId: me.id),
            ],
          );
        },
      ),
    );
  }

  static String _slotLabel(DateTime dt) {
    final y = dt.year;
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$y-$mo-$d $h:$mi';
  }
}

class _ApprovedTile extends ConsumerWidget {
  const _ApprovedTile({required this.request, required this.trainerId});

  final CallRequest request;
  final String trainerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomMeta = ref.watch(_roomMetaProvider(request.id)).valueOrNull;
    final canJoin = roomMeta != null &&
        request.scheduledFor.difference(DateTime.now()).inMinutes <= 10 &&
        request.scheduledFor.isAfter(DateTime.now().subtract(const Duration(minutes: 30)));

    return Card(
      child: ListTile(
        title: Text(TrainerRequestsScreen._slotLabel(request.scheduledFor)),
        subtitle: Text('Member: ${request.memberId}'),
        trailing: canJoin
            ? FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PreJoinScreen(
                        roomId: roomMeta.hmsRoomId,
                        userId: trainerId,
                        userName: 'Aarav (Lead Trainer)',
                        role: roomMeta.hmsRoleTrainer,
                        isTrainer: true,
                      ),
                    ),
                  );
                },
                child: const Text('Join call'),
              )
            : null,
      ),
    );
  }
}

final _requestsProvider =
    StreamProvider.family<List<CallRequest>, String>((ref, trainerId) {
  final call = ref.watch(callServiceProvider)!;
  return call.watchCallRequestsForTrainer(trainerId);
});

final _roomMetaProvider =
    StreamProvider.family<RoomMeta?, String>((ref, callRequestId) {
  final call = ref.watch(callServiceProvider)!;
  return call.watchRoomMetaForCallRequest(callRequestId);
});

