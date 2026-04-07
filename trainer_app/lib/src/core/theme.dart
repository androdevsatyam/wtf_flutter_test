import 'package:flutter/material.dart';

const Color trainerPrimary = Color(0xFFE50914);

ThemeData buildTrainerTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: trainerPrimary);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
    ),
  );
}

