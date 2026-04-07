import 'package:shared/src/models/session_log.dart';

abstract interface class SessionLogService {
  Stream<List<SessionLog>> watchForTrainer(String trainerId);

  Stream<List<SessionLog>> watchForMember(String memberId);

  Future<SessionLog> addOrUpdate(SessionLog log);
}

