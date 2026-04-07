import 'package:meta/meta.dart';

@immutable
class SessionLog {
  const SessionLog({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.startedAt,
    required this.endedAt,
    required this.durationSec,
    required this.rating,
    required this.notes,
  });

  final String id;
  final String memberId;
  final String trainerId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSec;

  /// Member rating 1-5 (nullable until member submits).
  final int? rating;

  /// Notes for both sides (nullable until submitted).
  final String? notes;

  SessionLog copyWith({
    String? id,
    String? memberId,
    String? trainerId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSec,
    int? rating,
    String? notes,
  }) {
    return SessionLog(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      trainerId: trainerId ?? this.trainerId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSec: durationSec ?? this.durationSec,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'memberId': memberId,
        'trainerId': trainerId,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'durationSec': durationSec,
        'rating': rating,
        'notes': notes,
      };

  static SessionLog fromJson(Map<String, Object?> json) {
    return SessionLog(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      trainerId: json['trainerId'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      durationSec: json['durationSec'] as int,
      rating: json['rating'] as int?,
      notes: json['notes'] as String?,
    );
  }
}

