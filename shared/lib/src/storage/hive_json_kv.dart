import 'dart:convert';

import 'package:hive/hive.dart';

/// A tiny helper that stores JSON-serialized entities into a Hive box.
///
/// It avoids Hive TypeAdapters for fast iteration and keeps the `shared/`
/// package usable from both Flutter apps without codegen.
class HiveJsonKv {
  HiveJsonKv(this._box);

  final Box<String> _box;

  Iterable<String> get keys => _box.keys.cast<String>();

  String? get(String key) => _box.get(key);

  Future<void> putJson(String key, Map<String, Object?> json) {
    return _box.put(key, jsonEncode(json));
  }

  Map<String, Object?>? getJson(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;
    return (jsonDecode(raw) as Map).cast<String, Object?>();
  }

  List<Map<String, Object?>> getAllJson() {
    final out = <Map<String, Object?>>[];
    for (final key in keys) {
      final json = getJson(key);
      if (json != null) out.add(json);
    }
    return out;
  }

  Future<void> delete(String key) => _box.delete(key);
}

