abstract interface class RoomProvisioner {
  Future<String> createRoomId({
    required String callRequestId,
    required String name,
  });
}

