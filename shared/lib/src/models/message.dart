import 'package:meta/meta.dart';

enum MessageStatus {
  sending,
  sent,
  read;

  static MessageStatus fromWire(String value) {
    switch (value) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'read':
        return MessageStatus.read;
      default:
        throw ArgumentError.value(value, 'status', 'Unknown status');
    }
  }

  String toWire() => switch (this) {
        MessageStatus.sending => 'sending',
        MessageStatus.sent => 'sent',
        MessageStatus.read => 'read',
      };
}

@immutable
class Message {
  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime createdAt;
  final MessageStatus status;

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? createdAt,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'chatId': chatId,
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'status': status.toWire(),
      };

  static Message fromJson(Map<String, Object?> json) {
    return Message(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: MessageStatus.fromWire(json['status'] as String),
    );
  }
}

