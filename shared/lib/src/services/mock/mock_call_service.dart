import 'dart:async';

import 'package:shared/src/models/call_request.dart';
import 'package:shared/src/models/room_meta.dart';
import 'package:shared/src/repositories/call_request_repo.dart';
import 'package:shared/src/repositories/room_meta_repo.dart';
import 'package:shared/src/services/call_service.dart';
import 'package:shared/src/services/room_provisioner.dart';
import 'package:uuid/uuid.dart';

class SchedulingConflict implements Exception {
  SchedulingConflict(this.message);
  final String message;
  @override
  String toString() => 'SchedulingConflict($message)';
}

class MockCallService implements CallService {
  MockCallService({
    required CallRequestRepo callRequestRepo,
    required RoomMetaRepo roomMetaRepo,
    this.roomProvisioner,
  })  : _callRequestRepo = callRequestRepo,
        _roomMetaRepo = roomMetaRepo;

  final CallRequestRepo _callRequestRepo;
  final RoomMetaRepo _roomMetaRepo;
  final RoomProvisioner? roomProvisioner;

  final Uuid _uuid = const Uuid();

  static const Duration _slot = Duration(minutes: 30);

  bool _conflicts(DateTime a, DateTime b) {
    final aEnd = a.add(_slot);
    final bEnd = b.add(_slot);
    return a.isBefore(bEnd) && b.isBefore(aEnd);
  }

  void _ensureNoConflicts({
    required String trainerId,
    required DateTime scheduledFor,
    String? excludingId,
  }) {
    for (final r in _callRequestRepo.forTrainer(trainerId)) {
      if (excludingId != null && r.id == excludingId) continue;
      if (r.status == CallRequestStatus.declined ||
          r.status == CallRequestStatus.cancelled) {
        continue;
      }
      if (_conflicts(r.scheduledFor, scheduledFor)) {
        throw SchedulingConflict('Trainer already has a request in this slot.');
      }
    }
  }

  @override
  Stream<List<CallRequest>> watchCallRequestsForTrainer(String trainerId) {
    return _callRequestRepo.watchAll().map((_) => _callRequestRepo.forTrainer(trainerId));
  }

  @override
  Stream<List<CallRequest>> watchCallRequestsForMember(String memberId) {
    return _callRequestRepo.watchAll().map((_) => _callRequestRepo.forMember(memberId));
  }

  @override
  Stream<RoomMeta?> watchRoomMetaForCallRequest(String callRequestId) {
    return _roomMetaRepo.watchForCallRequest(callRequestId);
  }

  @override
  Future<CallRequest> requestCall({
    required String memberId,
    required String trainerId,
    required DateTime scheduledFor,
    String? note,
  }) async {
    _ensureNoConflicts(trainerId: trainerId, scheduledFor: scheduledFor);
    final req = CallRequest(
      id: _uuid.v4(),
      memberId: memberId,
      trainerId: trainerId,
      requestedAt: DateTime.now(),
      scheduledFor: scheduledFor,
      note: note,
      status: CallRequestStatus.pending,
    );
    await _callRequestRepo.upsert(req);
    return req;
  }

  @override
  Future<void> cancelRequest(String callRequestId) async {
    final existing = _callRequestRepo.getById(callRequestId);
    if (existing == null) return;
    await _callRequestRepo.upsert(existing.copyWith(status: CallRequestStatus.cancelled));
  }

  @override
  Future<RoomMeta> approveRequest({
    required String callRequestId,
    required String trainerId,
  }) async {
    final existing = _callRequestRepo.getById(callRequestId);
    if (existing == null) {
      throw StateError('Unknown callRequestId: $callRequestId');
    }
    if (existing.trainerId != trainerId) {
      throw StateError('Trainer mismatch for approval.');
    }
    _ensureNoConflicts(
      trainerId: trainerId,
      scheduledFor: existing.scheduledFor,
      excludingId: existing.id,
    );

    await _callRequestRepo.upsert(existing.copyWith(status: CallRequestStatus.approved));

    final roomId = roomProvisioner == null
        ? 'dev-room-${existing.id.substring(0, 8)}'
        : await roomProvisioner!.createRoomId(
            callRequestId: existing.id,
            name: 'wtf_call_${existing.id.substring(0, 8)}',
          );

    final meta = RoomMeta(
      id: _uuid.v4(),
      callRequestId: existing.id,
      hmsRoomId: roomId,
      hmsRoleMember: 'member',
      hmsRoleTrainer: 'trainer',
    );
    await _roomMetaRepo.upsert(meta);
    return meta;
  }

  @override
  Future<void> declineRequest({
    required String callRequestId,
    required String trainerId,
  }) async {
    final existing = _callRequestRepo.getById(callRequestId);
    if (existing == null) return;
    if (existing.trainerId != trainerId) {
      throw StateError('Trainer mismatch for decline.');
    }
    await _callRequestRepo.upsert(existing.copyWith(status: CallRequestStatus.declined));
  }
}

