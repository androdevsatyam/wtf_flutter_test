import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers.dart';

class TrainerChatsScreen extends ConsumerWidget {
  const TrainerChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserStreamProvider).valueOrNull;
    if (me == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final users = ref.watch(_usersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: users.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (items) {
          final members = items.where((u) => u.role == Role.member && u.assignedTrainerId == me.id).toList();
          if (members.isEmpty) return const Center(child: Text('No members yet.'));
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: members.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final m = members[i];
              return Card(
                child: ListTile(
                  title: Text(m.name),
                  subtitle: Text('Tap to open chat'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TrainerChatThreadScreen(member: m),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TrainerChatThreadScreen extends ConsumerStatefulWidget {
  const TrainerChatThreadScreen({super.key, required this.member});
  final User member;

  @override
  ConsumerState<TrainerChatThreadScreen> createState() => _TrainerChatThreadScreenState();
}

class _TrainerChatThreadScreenState extends ConsumerState<TrainerChatThreadScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(currentUserStreamProvider).valueOrNull;
    if (me == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final chatId = '${widget.member.id}_${me.id}';
    final chat = ref.watch(_chatProvider(chatId));
    final memberTyping = ref.watch(_typingProvider((chatId, widget.member.id)));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.member.name),
            if (memberTyping.value == true)
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
              error: (e, st) => Center(child: Text('Error: $e')),
              data: (messages) => ListView.builder(
                padding: const EdgeInsets.all(12),
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, idx) {
                  final m = messages[messages.length - 1 - idx];
                  final isMe = m.senderId == me.id;
                  return _Bubble(message: m, isMe: isMe);
                },
              ),
            ),
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
                      await _send(chatId, me.id, widget.member.id, t);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Send a message…',
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
                    await _send(chatId, me.id, widget.member.id, t);
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

  Future<void> _send(String chatId, String senderId, String receiverId, String text) async {
    final chat = ref.read(chatServiceProvider)!;
    await chat.sendMessage(chatId: chatId, senderId: senderId, receiverId: receiverId, text: text);
  }
}

final _chatProvider = StreamProvider.family<List<Message>, String>((ref, chatId) {
  final chat = ref.watch(chatServiceProvider)!;
  return chat.watchChat(chatId);
});

final _typingProvider = StreamProvider.family<bool, (String, String)>((ref, args) {
  final chat = ref.watch(chatServiceProvider)!;
  return chat.watchTyping(chatId: args.$1, userId: args.$2);
});

final _usersProvider = StreamProvider<List<User>>((ref) {
  final repo = ref.watch(userRepoProvider)!;
  return repo.watchAll();
});

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.isMe});

  final Message message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = isMe ? scheme.primaryContainer : scheme.surfaceContainerHighest;
    final fg = isMe ? scheme.onPrimaryContainer : scheme.onSurface;
    final align = isMe ? Alignment.centerRight : Alignment.centerLeft;
    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(message.text, style: TextStyle(color: fg)),
      ),
    );
  }
}

