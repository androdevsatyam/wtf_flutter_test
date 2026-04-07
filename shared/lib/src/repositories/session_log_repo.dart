import 'package:hive/hive.dart';
import 'package:shared/src/live/live_store.dart';
import 'package:shared/src/models/session_log.dart';
import 'package:shared/src/storage/hive_json_kv.dart';

class SessionLogRepo {
  SessionLogRepo(Box<String> box)
      : _kv = HiveJsonKv(box),
        _store = LiveStore<SessionLog>();

  final HiveJsonKv _kv;
  final LiveStore<SessionLog> _store;

  Future<void> loadFromHive() async {
    final items = _kv.getAllJson().map(SessionLog.fromJson).toList();
    _store.setAll(items);
  }

  Stream<List<SessionLog>> watchAll() => _store.watch();

  List<SessionLog> forTrainer(String trainerId) =>
      _store.value.where((s) => s.trainerId == trainerId).toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  List<SessionLog> forMember(String memberId) =>
      _store.value.where((s) => s.memberId == memberId).toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

  Future<void> upsert(SessionLog log) async {
    _store.upsertBy(log, equals: (a, b) => a.id == b.id);
    await _kv.putJson(log.id, log.toJson());
  }
}

