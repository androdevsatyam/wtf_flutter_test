import 'package:flutter/material.dart';
import 'call_screen.dart';
import 'permissions.dart';
import 'token_api.dart';

class PreJoinScreen extends StatefulWidget {
  const PreJoinScreen({
    super.key,
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.role,
    required this.isTrainer,
  });

  final String roomId;
  final String userId;
  final String userName;
  final String role;
  final bool isTrainer;

  @override
  State<PreJoinScreen> createState() => _PreJoinScreenState();
}

class _PreJoinScreenState extends State<PreJoinScreen> {
  bool _busy = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device check')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Before joining, we need camera and microphone permission.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const Spacer(),
            FilledButton.icon(
              onPressed: _busy ? null : _join,
              icon: _busy
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.videocam),
              label: const Text('Join call'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _join() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      // Requirement: check permissions every time before starting a call.
      await CallPermissions.ensure();

      const baseUrl = String.fromEnvironment(
        'TOKEN_SERVER',
        defaultValue: 'http://localhost:8787',
      );
      final api = TokenApi(baseUrl);
      final token = await api.fetchToken(
        roomId: widget.roomId,
        userId: widget.userId,
        role: widget.role,
      );

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CallScreen(
            authToken: token,
            userName: widget.userName,
            isTrainer: widget.isTrainer,
          ),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

