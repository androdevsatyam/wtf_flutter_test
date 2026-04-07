import 'package:shared/src/models/call_request.dart';
import 'package:shared/src/models/room_meta.dart';

abstract interface class CallService {
  Stream<List<CallRequest>> watchCallRequestsForTrainer(String trainerId);

  Stream<List<CallRequest>> watchCallRequestsForMember(String memberId);

  Stream<RoomMeta?> watchRoomMetaForCallRequest(String callRequestId);

  Future<CallRequest> requestCall({
    required String memberId,
    required String trainerId,
    required DateTime scheduledFor,
    String? note,
  });

  Future<void> cancelRequest(String callRequestId);

  Future<RoomMeta> approveRequest({
    required String callRequestId,
    required String trainerId,
  });

  Future<void> declineRequest({
    required String callRequestId,
    required String trainerId,
  });
}

