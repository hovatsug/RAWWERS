import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // The floating "Add a package" / "Add photos" button: the primary
    // button's colours and 4px corners, not Material's grey 16px default.
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: RAccent.meter700,
      foregroundColor: RInk.i050,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RRadius.control)),
    ),
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
    // Every screen's title bar is the dark band: the client app's dark,
    // light text, light status bar, actions in meter500 (graphics, 4.45:1),
    // and the band's dark hairline. A screen with a headline number puts it
    // in an RHeaderBand directly under this.
    appBarTheme: AppBarTheme(
      backgroundColor: RInk.i950,
      foregroundColor: RInk.i050,
      surfaceTintColor: const Color(0x00000000),
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(color: RInk.i050),
      actionsIconTheme: const IconThemeData(color: RAccent.meter500),
      titleTextStyle: textTheme.titleLarge?.copyWith(color: RInk.i050),
      shape: const Border(bottom: BorderSide(color: RInk.i800)),
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
    dialogTheme: const DialogThemeData(backgroundColor: RPaper.card, surfaceTintColor: Color(0x00000000)),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: RPaper.card,
      modalBackgroundColor: RPaper.card,
      surfaceTintColor: Color(0x00000000),
    ),
    cardTheme: CardThemeData(
      color: RPaper.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RRadius.surface),
        side: const BorderSide(color: RInk.i200),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RPaper.card,
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
