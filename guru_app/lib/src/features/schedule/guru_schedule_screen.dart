import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers.dart';
import '../call/prejoin_screen.dart';

class GuruScheduleScreen extends ConsumerWidget {
  const GuruScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final memberId = user.id;
    final trainerId = user.assignedTrainerId ?? SeedData.trainerAaravId;

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            'Pick a 30-min block',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final slot in _nextSlots())
            Card(
              child: ListTile(
                title: Text(_slotLabel(slot)),
                subtitle: const Text('30 minutes'),
                trailing: FilledButton(
                  onPressed: () async {
                    final callService = ref.read(callServiceProvider)!;
                    try {
                      await callService.requestCall(
                        memberId: memberId,
                        trainerId: trainerId,
                        scheduledFor: slot,
                        note: 'Member requested via Guru app',
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request sent')),
                        );
                      }
                    } on SchedulingConflict catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.message)),
                        );
                      }
                    }
                  },
                  child: const Text('Request'),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Your requests',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Consumer(
            builder: (context, ref, _) {
              final reqs = ref.watch(_myRequestsProvider(memberId));
              return reqs.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Error: $e'),
                data: (items) {
                  if (items.isEmpty) {
                    return const Text('No requests yet.');
                  }
                  return Column(
                    children: [
                      for (final r in items)
                        _RequestTile(request: r, memberId: memberId),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  static Iterable<DateTime> _nextSlots() sync* {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, now.hour);
    for (var i = 1; i <= 8; i++) {
      yield start.add(Duration(minutes: 30 * i));
    }
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

final _myRequestsProvider =
    StreamProvider.family<List<CallRequest>, String>((ref, memberId) {
  final call = ref.watch(callServiceProvider)!;
  return call.watchCallRequestsForMember(memberId);
});

class _RequestTile extends ConsumerWidget {
  const _RequestTile({required this.request, required this.memberId});

  final CallRequest request;
  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomMetaAsync = ref.watch(_roomMetaProvider(request.id));
    final roomMeta = roomMetaAsync.valueOrNull;
    final canJoin = request.status == CallRequestStatus.approved &&
        roomMeta != null &&
        request.scheduledFor.difference(DateTime.now()).inMinutes <= 10 &&
        request.scheduledFor.isAfter(DateTime.now().subtract(const Duration(minutes: 30)));

    return ListTile(
      title: Text(GuruScheduleScreen._slotLabel(request.scheduledFor)),
      subtitle: Text('Status: ${request.status.toWire()}'),
      trailing: canJoin
          ? FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PreJoinScreen(
                      roomId: roomMeta.hmsRoomId,
                      userId: memberId,
                      userName: 'DK',
                      role: roomMeta.hmsRoleMember,
                      isTrainer: false,
                    ),
                  ),
                );
              },
              child: const Text('Join call'),
            )
          : null,
    );
  }
}

final _roomMetaProvider = StreamProvider.family<RoomMeta?, String>((ref, callRequestId) {
  final call = ref.watch(callServiceProvider)!;
  return call.watchRoomMetaForCallRequest(callRequestId);
});

