import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers.dart';
import '../home/trainer_home_shell.dart';
import '../login/trainer_login_screen.dart';

class BootstrapScreen extends ConsumerWidget {
  const BootstrapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boot = ref.watch(bootstrapProvider);
    return boot.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        body: Center(child: Text('Bootstrap error: $e')),
      ),
      data: (_) {
        final userAsync = ref.watch(currentUserStreamProvider);
        return userAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, st) => Scaffold(
            body: Center(child: Text('Auth error: $e')),
          ),
          data: (user) {
            if (user == null) return const TrainerLoginScreen();

            requireRole(
              actual: user.role,
              allowed: const {Role.trainer},
              context: 'TrainerApp',
            );
            return const TrainerHomeShell();
          },
        );
      },
    );
  }
}

