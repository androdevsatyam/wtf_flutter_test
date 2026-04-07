import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers.dart';

class GuruChatScreen extends ConsumerStatefulWidget {
  const GuruChatScreen({super.key});

  @override
  ConsumerState<GuruChatScreen> createState() => _GuruChatScreenState();
}

class _GuruChatScreenState extends ConsumerState<GuruChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserStreamProvider).valueOrNull;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final memberId = user.id;
    final trainerId = user.assignedTrainerId ?? SeedData.trainerAaravId;
    final chatId = '${memberId}_$trainerId';

    final chat = ref.watch(_chatMessagesProvider(chatId));
    final trainerTyping = ref.watch(_typingProvider((chatId, trainerId)));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Aarav (Lead Trainer)'),
            if (trainerTyping.value == true)
              Text(
                'typing…',
                style: Theme.of(context).textTheme.labelSmall,
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chat.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Chat error: $e')),
              data: (messages) {
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, idx) {
                    final m = messages[messages.length - 1 - idx];
                    final isMe = m.senderId == memberId;
                    return _MessageBubble(message: m, isMe: isMe);
                  },
                );
              },
            ),
          ),
          _QuickReplies(
            onPick: (text) async => _send(chatId, memberId, trainerId, text),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (v) async {
                      final t = v.trim();
                      if (t.isEmpty) return;
                      _controller.clear();
                      await _send(chatId, memberId, trainerId, t);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Message your trainer…',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () async {
                    final t = _controller.text.trim();
                    if (t.isEmpty) return;
                    _controller.clear();
                    await _send(chatId, memberId, trainerId, t);
                  },
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send(
    String chatId,
    String senderId,
    String receiverId,
    String text,
  ) async {
    final chatService = ref.read(chatServiceProvider)!;
    await chatService.sendMessage(
      chatId: chatId,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
    );
  }
}

final _chatMessagesProvider =
    StreamProvider.family<List<Message>, String>((ref, chatId) {
  final chat = ref.watch(chatServiceProvider)!;
  return chat.watchChat(chatId);
});

final _typingProvider =
    StreamProvider.family<bool, (String, String)>((ref, args) {
  final chat = ref.watch(chatServiceProvider)!;
  return chat.watchTyping(chatId: args.$1, userId: args.$2);
});

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});

  final Message message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = isMe ? scheme.primaryContainer : scheme.surfaceContainerHighest;
    final fg = isMe ? scheme.onPrimaryContainer : scheme.onSurface;
    final align = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(14),
      topRight: const Radius.circular(14),
      bottomLeft: Radius.circular(isMe ? 14 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 14),
    );

    final status = switch (message.status) {
      MessageStatus.sending => '…',
      MessageStatus.sent => '✓',
      MessageStatus.read => '✓✓',
    };

    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(message.text, style: TextStyle(color: fg)),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _hm(message.createdAt),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: fg.withValues(alpha: 0.75)),
                ),
                if (isMe) ...[
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: fg.withValues(alpha: 0.75)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _hm(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _QuickReplies extends StatelessWidget {
  const _QuickReplies({required this.onPick});

  final Future<void> Function(String) onPick;

  @override
  Widget build(BuildContext context) {
    final chips = const [
      'Can we do a quick check-in?',
      'I’m ready for today’s session.',
      'Can you share a plan for this week?',
    ];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          return ActionChip(
            label: Text(chips[i]),
            onPressed: () => onPick(chips[i]),
          );
        },
      ),
    );
  }
}

