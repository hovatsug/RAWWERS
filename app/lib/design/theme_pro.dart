import 'package:flutter/material.dart';
import 'package:rawwers/design/color_scheme.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/design/typography.dart';

/// Light - the pro app is used outdoors, on a shoot, in daylight glare,
/// where a dark UI is notoriously hard to read against ambient light.
ThemeData buildProTheme() {
  final textTheme = buildTextTheme(primary: RInk.i950, secondary: RInk.i600);

  return ThemeData(
    useMaterial3: true,
    fontFamily: RType.fontFamily,
    scaffoldBackgroundColor: RInk.i050,
    textTheme: textTheme,
    colorScheme: RColorSchemes.light,
    dividerColor: RInk.i200,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: RAccent.meter700,
        foregroundColor: RInk.i050,
        minimumSize: const Size.fromHeight(rMinTouchTarget),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RRadius.surface)),
        textStyle: TextStyle(
          fontFamily: RType.fontFamily,
          fontSize: RType.label,
          fontVariations: const [RType.weightMedium],
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: RInk.i100,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RRadius.surface),
        side: const BorderSide(color: RInk.i200),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RInk.i100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RRadius.surface),
        borderSide: const BorderSide(color: RInk.i200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RRadius.surface),
        borderSide: const BorderSide(color: RAccent.meter500, width: 2),
      ),
    ),
    navigationBarTheme: buildNavigationBarTheme(isDark: false),
    focusColor: RAccent.meter500,
  );
}
