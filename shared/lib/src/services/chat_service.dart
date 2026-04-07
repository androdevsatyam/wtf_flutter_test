import 'package:shared/src/models/message.dart';

abstract interface class ChatService {
  Stream<List<Message>> watchChat(String chatId);

  Stream<bool> watchTyping({
    required String chatId,
    required String userId,
  });

  Future<Message> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  });

  Future<void> markChatRead({
    required String chatId,
    required String readerId,
  });
}

