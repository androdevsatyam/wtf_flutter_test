import 'dart:async';
import 'dart:math';

import 'package:shared/src/models/message.dart';
import 'package:shared/src/repositories/message_repo.dart';
import 'package:shared/src/services/chat_service.dart';
import 'package:uuid/uuid.dart';

class MockChatService implements ChatService {
  MockChatService({
    required MessageRepo messageRepo,
    Random? random,
  })  : _messageRepo = messageRepo,
        _random = random ?? Random();

  final MessageRepo _messageRepo;
  final Random _random;
  final Uuid _uuid = const Uuid();

  final Map<String, StreamController<bool>> _typingControllers = {};
  final Map<String, bool> _typingState = {};

  String _typingKey(String chatId, String userId) => '$chatId::$userId';

  void _setTyping(String chatId, String userId, bool isTyping) {
    final key = _typingKey(chatId, userId);
    _typingState[key] = isTyping;
    (_typingControllers[key] ??= StreamController<bool>.broadcast()).add(isTyping);
  }

  @override
  Stream<List<Message>> watchChat(String chatId) {
    return _messageRepo.watchAll().map((_) => _messageRepo.getForChat(chatId));
  }

  @override
  Stream<bool> watchTyping({required String chatId, required String userId}) {
    final key = _typingKey(chatId, userId);
    final controller =
        _typingControllers[key] ??= StreamController<bool>.broadcast();
    return Stream.multi((multi) {
      multi.add(_typingState[key] ?? false);
      final sub = controller.stream.listen(multi.add);
      multi.onCancel = sub.cancel;
    });
  }

  @override
  Future<Message> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final sending = Message(
      id: id,
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      createdAt: now,
      status: MessageStatus.sending,
    );
    await _messageRepo.upsert(sending);

    // Simulate "sent" a bit later.
    await Future<void>.delayed(const Duration(milliseconds: 160));
    await _messageRepo.upsert(sending.copyWith(status: MessageStatus.sent));

    // Simulate receiver typing + read receipt (400-800ms typing).
    final typingMs = 400 + _random.nextInt(401);
    _setTyping(chatId, receiverId, true);
    await Future<void>.delayed(Duration(milliseconds: typingMs));
    _setTyping(chatId, receiverId, false);

    // Mark the message as read after typing finishes.
    await _messageRepo.upsert(sending.copyWith(status: MessageStatus.read));
    return sending;
  }

  @override
  Future<void> markChatRead({
    required String chatId,
    required String readerId,
  }) async {
    final messages = _messageRepo.getForChat(chatId);
    final updates = <Message>[];
    for (final m in messages) {
      if (m.receiverId == readerId && m.status != MessageStatus.read) {
        updates.add(m.copyWith(status: MessageStatus.read));
      }
    }
    await _messageRepo.upsertMany(updates);
  }
}

