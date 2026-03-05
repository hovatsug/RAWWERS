// GENERATED FILE. DO NOT EDIT.
import 'package:flutter/material.dart';
import 'tokens.dart';

ThemeData buildLightTheme() {
  final colorScheme = const ColorScheme.light(
    primary: RTokens.brandPrimary,
    onPrimary: Colors.white,
    secondary: RTokens.brandPrimaryDark,
    surface: RTokens.neutralCard,
    onSurface: RTokens.neutralText,
    error: RTokens.statusDanger,
    onError: Colors.white,
  );

  final textTheme = const TextTheme(
    headlineMedium: TextStyle(fontSize: RTokens.textX2l, fontWeight: FontWeight.w700, color: RTokens.neutralText),
    titleLarge: TextStyle(fontSize: RTokens.textXl, fontWeight: FontWeight.w600, color: RTokens.neutralText),
    titleMedium: TextStyle(fontSize: RTokens.textLg, fontWeight: FontWeight.w600, color: RTokens.neutralText),
    bodyLarge: TextStyle(fontSize: RTokens.textBase, color: RTokens.neutralText),
    bodyMedium: TextStyle(fontSize: RTokens.textSm, color: RTokens.neutralText),
    bodySmall: TextStyle(fontSize: RTokens.textXs, color: RTokens.neutralMuted),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: RTokens.neutralBg,
    textTheme: textTheme,
    cardTheme: CardThemeData(
      color: RTokens.neutralCard,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RTokens.radiusLg)),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RTokens.neutralCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: RTokens.spacingX3, vertical: RTokens.spacingX2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RTokens.radiusMd),
        borderSide: const BorderSide(color: RTokens.neutralBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RTokens.radiusMd),
        borderSide: const BorderSide(color: RTokens.neutralBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RTokens.radiusMd),
        borderSide: const BorderSide(color: RTokens.brandPrimary),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: RTokens.brandPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RTokens.radiusMd)),
        padding: const EdgeInsets.symmetric(horizontal: RTokens.spacingX4, vertical: RTokens.spacingX2),
      ),
    ),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(primary: RTokens.brandPrimary),
  );
}
