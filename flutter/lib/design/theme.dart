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
  final colorScheme = ColorScheme.dark(
    primary: RTokens.violet,
    onPrimary: Colors.white,
    secondary: RTokens.blue,
    onSecondary: Colors.white,
    surface: RTokens.glassSurface,
    onSurface: RTokens.textOnDark,
    error: const Color(0xFFEF4444),
    onError: Colors.white,
    outline: RTokens.glassCardBorder,
  );

  const textTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: RTokens.textX4l, fontWeight: FontWeight.w800, color: RTokens.textOnDark, letterSpacing: -1),
    headlineMedium: TextStyle(fontSize: RTokens.textX2l, fontWeight: FontWeight.w700, color: RTokens.textOnDark),
    titleLarge: TextStyle(fontSize: RTokens.textXl, fontWeight: FontWeight.w600, color: RTokens.textOnDark),
    titleMedium: TextStyle(fontSize: RTokens.textLg, fontWeight: FontWeight.w600, color: RTokens.textOnDark),
    bodyLarge: TextStyle(fontSize: RTokens.textBase, color: RTokens.textOnDark),
    bodyMedium: TextStyle(fontSize: RTokens.textSm, color: RTokens.textMutedDark),
    bodySmall: TextStyle(fontSize: RTokens.textXs, color: RTokens.textSubtleDark),
    labelSmall: TextStyle(fontSize: RTokens.textXs, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: RTokens.textSubtleDark),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: RTokens.glassBg,
    textTheme: textTheme,
    cardTheme: CardThemeData(
      color: RTokens.glassCardBg,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RTokens.radiusXl),
        side: const BorderSide(color: RTokens.glassCardBorder, width: 1),
      ),
      elevation: 0,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(fontSize: RTokens.textLg, fontWeight: FontWeight.w700, color: RTokens.textOnDark),
      iconTheme: IconThemeData(color: RTokens.textOnDark),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xCC08080F), // glassBg at 80%
      indicatorColor: RTokens.violet.withValues(alpha: 0.25),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: RTokens.violetLight);
        }
        return const IconThemeData(color: RTokens.textSubtleDark);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontSize: RTokens.textXs, fontWeight: FontWeight.w600, color: RTokens.violetLight);
        }
        return const TextStyle(fontSize: RTokens.textXs, color: RTokens.textSubtleDark);
      }),
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RTokens.glassCardBg,
      hintStyle: const TextStyle(color: RTokens.textSubtleDark),
      contentPadding: const EdgeInsets.symmetric(horizontal: RTokens.spacingX4, vertical: RTokens.spacingX3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RTokens.radiusXl),
        borderSide: const BorderSide(color: RTokens.glassCardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RTokens.radiusXl),
        borderSide: const BorderSide(color: RTokens.glassCardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RTokens.radiusXl),
        borderSide: const BorderSide(color: RTokens.violet, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: RTokens.violet,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RTokens.radiusXl)),
        padding: const EdgeInsets.symmetric(horizontal: RTokens.spacingX6, vertical: RTokens.spacingX3),
        elevation: 0,
        shadowColor: RTokens.glowViolet,
      ),
    ),
    dividerTheme: const DividerThemeData(color: RTokens.glassCardBorder, thickness: 1),
  );
}
