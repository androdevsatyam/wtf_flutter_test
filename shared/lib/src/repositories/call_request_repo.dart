import 'package:hive/hive.dart';
import 'package:shared/src/live/live_store.dart';
import 'package:shared/src/models/call_request.dart';
import 'package:shared/src/storage/hive_json_kv.dart';

class CallRequestRepo {
  CallRequestRepo(Box<String> box)
      : _kv = HiveJsonKv(box),
        _store = LiveStore<CallRequest>();

  final HiveJsonKv _kv;
  final LiveStore<CallRequest> _store;

  Future<void> loadFromHive() async {
    final items = _kv.getAllJson().map(CallRequest.fromJson).toList();
    _store.setAll(items);
  }

  Stream<List<CallRequest>> watchAll() => _store.watch();

  List<CallRequest> getAll() => _store.value;

  CallRequest? getById(String id) {
    for (final r in _store.value) {
      if (r.id == id) return r;
    }
    return null;
  }

  List<CallRequest> forTrainer(String trainerId) =>
      _store.value.where((r) => r.trainerId == trainerId).toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

  List<CallRequest> forMember(String memberId) =>
      _store.value.where((r) => r.memberId == memberId).toList()
        ..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

  Future<void> upsert(CallRequest request) async {
    _store.upsertBy(request, equals: (a, b) => a.id == b.id);
    await _kv.putJson(request.id, request.toJson());
  }
}

