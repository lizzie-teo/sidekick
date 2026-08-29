import 'package:flutter/material.dart';

const Color _seed = Color(0xFF1F6FEB);

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: _seed),
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
  );
}

ThemeData appDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    ),
  );
}
