import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../core/devpanel.dart';
import '../core/theme.dart';
import '../features/bootstrap/bootstrap_screen.dart';

class GuruApp extends ConsumerWidget {
  const GuruApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guru',
      theme: buildGuruTheme(),
      home: const BootstrapScreen(),
      // builder: (context, child) =>
      //     DebugBannerOverlay(child: child ?? const SizedBox.shrink()),
    );
  }
}
