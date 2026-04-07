import 'dart:async';

import 'package:collection/collection.dart';

/// Minimal in-memory "live" layer to make the UI reactive even when the
/// persistence layer is local-first (Hive).
///
/// This class is intentionally simple: write methods are handled by higher-level
/// services; this store focuses on fan-out updates to listeners.
class LiveStore<T> {
  LiveStore({List<T> initial = const []}) : _value = List.unmodifiable(initial);

  final StreamController<List<T>> _controller =
      StreamController<List<T>>.broadcast();

  List<T> _value;

  List<T> get value => _value;

  Stream<List<T>> watch() {
    // Ensure immediate emission for new subscribers.
    return Stream.multi((multi) {
      multi.add(_value);
      final sub = _controller.stream.listen(multi.add);
      multi.onCancel = sub.cancel;
    });
  }

  void setAll(List<T> next) {
    _value = List.unmodifiable(next);
    _controller.add(_value);
  }

  void upsertBy(
    T item, {
    required bool Function(T a, T b) equals,
  }) {
    final idx = _value.indexWhere((e) => equals(e, item));
    if (idx == -1) {
      setAll(<T>[..._value, item]);
      return;
    }
    final next = _value.toList(growable: true);
    next[idx] = item;
    setAll(next);
  }

  void removeWhere(bool Function(T) test) {
    setAll(_value.whereNot(test).toList());
  }

  void dispose() {
    _controller.close();
  }
}

