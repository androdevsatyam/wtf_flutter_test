import 'package:meta/meta.dart';

enum CallRequestStatus {
  pending,
  approved,
  declined,
  cancelled;

  static CallRequestStatus fromWire(String value) {
    switch (value) {
      case 'pending':
        return CallRequestStatus.pending;
      case 'approved':
        return CallRequestStatus.approved;
      case 'declined':
        return CallRequestStatus.declined;
      case 'cancelled':
        return CallRequestStatus.cancelled;
      default:
        throw ArgumentError.value(value, 'status', 'Unknown status');
    }
  }

  String toWire() => switch (this) {
        CallRequestStatus.pending => 'pending',
        CallRequestStatus.approved => 'approved',
        CallRequestStatus.declined => 'declined',
        CallRequestStatus.cancelled => 'cancelled',
      };
}

@immutable
class CallRequest {
  const CallRequest({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.requestedAt,
    required this.scheduledFor,
    required this.note,
    required this.status,
  });

  final String id;
  final String memberId;
  final String trainerId;
  final DateTime requestedAt;
  final DateTime scheduledFor;
  final String? note;
  final CallRequestStatus status;

  CallRequest copyWith({
    String? id,
    String? memberId,
    String? trainerId,
    DateTime? requestedAt,
    DateTime? scheduledFor,
    String? note,
    CallRequestStatus? status,
  }) {
    return CallRequest(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      trainerId: trainerId ?? this.trainerId,
      requestedAt: requestedAt ?? this.requestedAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'memberId': memberId,
        'trainerId': trainerId,
        'requestedAt': requestedAt.toIso8601String(),
        'scheduledFor': scheduledFor.toIso8601String(),
        'note': note,
        'status': status.toWire(),
      };

  static CallRequest fromJson(Map<String, Object?> json) {
    return CallRequest(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      trainerId: json['trainerId'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      scheduledFor: DateTime.parse(json['scheduledFor'] as String),
      note: json['note'] as String?,
      status: CallRequestStatus.fromWire(json['status'] as String),
    );
  }
}

