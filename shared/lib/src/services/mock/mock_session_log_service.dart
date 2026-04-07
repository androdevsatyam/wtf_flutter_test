import 'package:shared/src/models/session_log.dart';
import 'package:shared/src/repositories/session_log_repo.dart';
import 'package:shared/src/services/session_log_service.dart';

class MockSessionLogService implements SessionLogService {
  MockSessionLogService({required SessionLogRepo sessionLogRepo})
      : _sessionLogRepo = sessionLogRepo;

  final SessionLogRepo _sessionLogRepo;

  @override
  Stream<List<SessionLog>> watchForTrainer(String trainerId) {
    return _sessionLogRepo.watchAll().map((_) => _sessionLogRepo.forTrainer(trainerId));
  }

  @override
  Stream<List<SessionLog>> watchForMember(String memberId) {
    return _sessionLogRepo.watchAll().map((_) => _sessionLogRepo.forMember(memberId));
  }

  @override
  Future<SessionLog> addOrUpdate(SessionLog log) async {
    await _sessionLogRepo.upsert(log);
    return log;
  }
}

