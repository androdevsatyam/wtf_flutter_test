import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers.dart';

class TrainerLoginScreen extends ConsumerWidget {
  const TrainerLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trainer Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sign in as',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Text('A')),
                title: const Text('Aarav (Lead Trainer)'),
                subtitle: const Text('Pre-seeded trainer profile'),
                trailing: FilledButton(
                  onPressed: () async {
                    final auth = ref.read(authServiceProvider)!;
                    await auth.signInAsUser(SeedData.trainerAaravId);
                  },
                  child: const Text('Login'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

