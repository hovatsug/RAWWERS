import 'package:flutter/material.dart';
import 'package:rawwers/design/color_scheme.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/design/typography.dart';

/// "Contact sheet": a light paper body - the pro app is used outdoors, on a
/// shoot, in daylight glare, where a dark UI is hard to read - under a dark
/// header band (RHeaderBand) that carries the brand and the money in the
/// client app's dark.
///
/// The accent on this light ground is meter700: links, active marks and
/// buttons clear 4.5:1 on it, which meter500 (4.13:1) does not. Controls are
/// 4px, surfaces 8px.
ThemeData buildProTheme() {
  final textTheme = buildTextTheme(primary: RInk.i950, secondary: RInk.i600);

  return ThemeData(
    useMaterial3: true,
    fontFamily: RType.fontFamily,
    scaffoldBackgroundColor: RPaper.paper,
    textTheme: textTheme,
    colorScheme: RColorSchemes.light,
    dividerColor: RInk.i200,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: RAccent.meter700,
        foregroundColor: RInk.i050,
        minimumSize: const Size.fromHeight(rMinTouchTarget),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RRadius.control)),
        textStyle: TextStyle(
          fontFamily: RType.fontFamily,
          fontSize: RType.label,
          fontVariations: const [RType.weightMedium],
        ),
      ),
    ),
    // Every button is a 4px rectangle - no stadium shapes in Contact sheet -
    // and text-sized accents are meter700.
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: RAccent.meter700,
        minimumSize: const Size(rMinTouchTarget, rMinTouchTarget),
        side: const BorderSide(color: RInk.i500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RRadius.control)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: RAccent.meter700,
        minimumSize: const Size(rMinTouchTarget, rMinTouchTarget),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RRadius.control)),
      ),
    ),
    cardTheme: CardThemeData(
      color: RInk.i050,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RRadius.surface),
        side: const BorderSide(color: RInk.i200),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RInk.i050,
      // A field's edge is a control boundary, so it clears 3:1 (i500 on the
      // card and on paper); i200 did not.
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RRadius.control),
        borderSide: const BorderSide(color: RInk.i500),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RRadius.control),
        borderSide: const BorderSide(color: RInk.i500),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RRadius.control),
        borderSide: const BorderSide(color: RAccent.meter700, width: 2),
      ),
    ),
    navigationBarTheme: buildNavigationBarTheme(isDark: false),
    focusColor: RAccent.meter700,
  );
}
