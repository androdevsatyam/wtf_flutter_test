import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers.dart';
import '../home/guru_home_shell.dart';

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
            // Guru app: auto sign in as DK on first run.
            if (user == null) {
              Future<void>(() async {
                final auth = ref.read(authServiceProvider)!;
                await auth.signInAsUser(SeedData.memberDkId);
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            requireRole(
              actual: user.role,
              allowed: const {Role.member},
              context: 'GuruApp',
            );

            return const GuruHomeShell();
          },
        );
      },
    );
  }
}

