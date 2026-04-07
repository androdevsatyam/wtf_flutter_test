import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'devlog.dart';

class DebugBannerOverlay extends ConsumerWidget {
  const DebugBannerOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) return child;

    return Stack(
      children: [
        child,
        Positioned(
          bottom: kToolbarHeight,
          right: 0,
          child: GestureDetector(
            onTap:
                () => showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (_) => const DevPanel(),
                ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  topLeft: Radius.circular(10),
                ),
              ),
              child: Text(
                'DEV',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DevPanel extends ConsumerWidget {
  const DevPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(devLogProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('DevPanel', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('Env', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _kv(context, 'APP', 'trainer_app'),
            _kv(
              context,
              'TOKEN_SERVER',
              const String.fromEnvironment(
                'TOKEN_SERVER',
                defaultValue: 'http://localhost:8787',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Last 20 logs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: logs.length,
                  itemBuilder: (context, i) {
                    final e = logs[logs.length - 1 - i];
                    return Text(
                      e.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(k, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(
            child: Text(v, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
