import 'package:hive/hive.dart';
import 'package:shared/src/live/live_store.dart';
import 'package:shared/src/models/message.dart';
import 'package:shared/src/storage/hive_json_kv.dart';

class MessageRepo {
  MessageRepo(Box<String> box)
      : _kv = HiveJsonKv(box),
        _store = LiveStore<Message>();

  final HiveJsonKv _kv;
  final LiveStore<Message> _store;

  Future<void> loadFromHive() async {
    final items = _kv.getAllJson().map(Message.fromJson).toList();
    _store.setAll(items);
  }

  Stream<List<Message>> watchAll() => _store.watch();

  List<Message> getAll() => _store.value;

  List<Message> getForChat(String chatId) {
    final list = _store.value.where((m) => m.chatId == chatId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  Future<void> upsert(Message message) async {
    _store.upsertBy(message, equals: (a, b) => a.id == b.id);
    await _kv.putJson(message.id, message.toJson());
  }

  Future<void> upsertMany(Iterable<Message> messages) async {
    for (final m in messages) {
      await upsert(m);
    }
  }
}

