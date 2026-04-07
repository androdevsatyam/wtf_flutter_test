import 'package:hive/hive.dart';
import 'package:shared/src/live/live_store.dart';
import 'package:shared/src/models/user.dart';
import 'package:shared/src/storage/hive_json_kv.dart';

class UserRepo {
  UserRepo(Box<String> box)
      : _kv = HiveJsonKv(box),
        _store = LiveStore<User>();

  final HiveJsonKv _kv;
  final LiveStore<User> _store;

  Future<void> loadFromHive() async {
    final users = _kv.getAllJson().map(User.fromJson).toList();
    _store.setAll(users);
  }

  Stream<List<User>> watchAll() => _store.watch();

  List<User> getAll() => _store.value;

  User? getById(String id) => _store.value.where((u) => u.id == id).firstOrNull;

  Future<void> upsert(User user) async {
    _store.upsertBy(user, equals: (a, b) => a.id == b.id);
    await _kv.putJson(user.id, user.toJson());
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

