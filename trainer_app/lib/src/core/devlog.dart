import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final devLogProvider =
    NotifierProvider<DevLogNotifier, List<DevLogEntry>>(DevLogNotifier.new);

@immutable
class DevLogEntry {
  const DevLogEntry({
    required this.ts,
    required this.level,
    required this.message,
  });

  final DateTime ts;
  final String level;
  final String message;

  @override
  String toString() => '[${ts.toIso8601String()}][$level] $message';
}

class DevLogNotifier extends Notifier<List<DevLogEntry>> {
  static const int _cap = 20;

  @override
  List<DevLogEntry> build() => const [];

  void info(String message) => _add('INFO', message);
  void warn(String message) => _add('WARN', message);
  void error(String message) => _add('ERROR', message);

  void _add(String level, String message) {
    final next = <DevLogEntry>[
      ...state,
      DevLogEntry(ts: DateTime.now(), level: level, message: message),
    ];
    state = next.length <= _cap ? next : next.sublist(next.length - _cap);
  }
}

