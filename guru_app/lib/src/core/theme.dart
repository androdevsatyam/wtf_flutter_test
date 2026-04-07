import 'package:flutter/material.dart';

const Color guruPrimary = Color(0xFF1769E0);

ThemeData buildGuruTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: guruPrimary);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
    ),
  );
}

