import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/design/typography.dart';

/// Dark - the client app is browsed at night, in bed, making a purchase
/// decision. Dark chrome also makes photo content (usually brighter than
/// the UI around it) read as the obviously-brightest thing on screen.
ThemeData buildClientTheme() {
  final textTheme = buildTextTheme(primary: RInk.i050, secondary: RInk.i400);

  return ThemeData(
    useMaterial3: true,
    fontFamily: RType.fontFamily,
    scaffoldBackgroundColor: RInk.i950,
    textTheme: textTheme,
    colorScheme: const ColorScheme.dark(
      surface: RInk.i900,
      onSurface: RInk.i050,
      primary: RAccent.meter500,
      onPrimary: RInk.i050,
      outline: RInk.i800,
      error: RShade.shade600,
      onError: RInk.i050,
    ),
    dividerColor: RInk.i800,
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
      color: RInk.i900,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RRadius.surface),
        side: const BorderSide(color: RInk.i800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RInk.i900,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RRadius.surface),
        borderSide: const BorderSide(color: RInk.i800),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RRadius.surface),
        borderSide: const BorderSide(color: RAccent.meter500, width: 2),
      ),
    ),
    focusColor: RAccent.meter500,
  );
}
