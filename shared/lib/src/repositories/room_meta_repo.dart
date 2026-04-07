import 'package:hive/hive.dart';
import 'package:shared/src/live/live_store.dart';
import 'package:shared/src/models/room_meta.dart';
import 'package:shared/src/storage/hive_json_kv.dart';

class RoomMetaRepo {
  RoomMetaRepo(Box<String> box)
      : _kv = HiveJsonKv(box),
        _store = LiveStore<RoomMeta>();

  final HiveJsonKv _kv;
  final LiveStore<RoomMeta> _store;

  Future<void> loadFromHive() async {
    final items = _kv.getAllJson().map(RoomMeta.fromJson).toList();
    _store.setAll(items);
  }

  Stream<List<RoomMeta>> watchAll() => _store.watch();

  RoomMeta? getForCallRequest(String callRequestId) {
    for (final r in _store.value) {
      if (r.callRequestId == callRequestId) return r;
    }
    return null;
  }

  Stream<RoomMeta?> watchForCallRequest(String callRequestId) {
    return _store.watch().map((all) {
      for (final r in all) {
        if (r.callRequestId == callRequestId) return r;
      }
      return null;
    });
  }

  Future<void> upsert(RoomMeta meta) async {
    _store.upsertBy(meta, equals: (a, b) => a.id == b.id);
    await _kv.putJson(meta.id, meta.toJson());
  }
}

