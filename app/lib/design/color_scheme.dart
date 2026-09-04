import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// Complete `ColorScheme`s built from tokens, with every Material 3 role set.
///
/// Every role is assigned deliberately, because the failure this file exists
/// to prevent is silent: `ColorScheme.light(...)` and `ColorScheme.dark(...)`
/// fill any role you *don't* name from Flutter's baseline Material palette,
/// whose secondary is `#03DAC6`. Widgets that reach for an unnamed role - and
/// `NavigationBar`'s selection indicator reaches for `secondaryContainer` -
/// then render in a bright teal that appears nowhere in the design system and
/// nowhere in this codebase's source. That shipped: the pro app's bottom nav
/// had a teal pill sitting next to meter-blue buttons, two accents in one
/// frame, with no hex to grep for.
///
/// So: one accent, and the accent roles (`primary`, `secondary`, `tertiary`)
/// all resolve to the same meter blue. Nothing that reads a colour role can
/// introduce a second hue, whatever role it happens to reach for.
///
/// The container roles are neutral ink rather than tinted accent. M3 expects
/// tonal containers derived from the primary hue; this system does not have
/// them and should not invent them - RAccent is two hexes on purpose. A
/// neutral container with an accent-coloured icon reads as one accent; a
/// generated tonal fill reads as a second.
abstract final class RColorSchemes {
  /// Pro app - used outdoors, in daylight glare.
  static const light = ColorScheme(
    brightness: Brightness.light,

    primary: RAccent.meter500,
    onPrimary: RInk.i050,
    primaryContainer: RInk.i200,
    onPrimaryContainer: RInk.i950,

    secondary: RAccent.meter500,
    onSecondary: RInk.i050,
    secondaryContainer: RInk.i200,
    onSecondaryContainer: RInk.i950,

    tertiary: RAccent.meter500,
    onTertiary: RInk.i050,
    tertiaryContainer: RInk.i200,
    onTertiaryContainer: RInk.i950,

    error: RShade.shade600,
    onError: RInk.i050,
    errorContainer: RInk.i200,
    onErrorContainer: RShade.shade600,

    surface: RInk.i100,
    onSurface: RInk.i950,
    onSurfaceVariant: RInk.i600,
    surfaceContainerLowest: RInk.i050,
    surfaceContainerLow: RInk.i050,
    surfaceContainer: RInk.i100,
    surfaceContainerHigh: RInk.i200,
    surfaceContainerHighest: RInk.i200,

    outline: RInk.i200,
    outlineVariant: RInk.i200,

    inverseSurface: RInk.i950,
    onInverseSurface: RInk.i050,
    inversePrimary: RAccent.meter500,

    shadow: Color(0x33000000),
    scrim: Color(0x99000000),

    // M3 tints elevated surfaces with the primary hue. This system uses
    // border-based elevation and elevation: 0 everywhere, so a tint would be
    // an accent appearing on surfaces that never asked for one.
    surfaceTint: Color(0x00000000),
  );

  /// Client app - browsed at night, and dark chrome keeps photographs the
  /// brightest thing on screen.
  static const dark = ColorScheme(
    brightness: Brightness.dark,

    primary: RAccent.meter500,
    onPrimary: RInk.i050,
    primaryContainer: RInk.i800,
    onPrimaryContainer: RInk.i050,

    secondary: RAccent.meter500,
    onSecondary: RInk.i050,
    secondaryContainer: RInk.i800,
    onSecondaryContainer: RInk.i050,

    tertiary: RAccent.meter500,
    onTertiary: RInk.i050,
    tertiaryContainer: RInk.i800,
    onTertiaryContainer: RInk.i050,

    error: RShade.shade600,
    onError: RInk.i050,
    errorContainer: RInk.i800,
    onErrorContainer: RInk.i050,

    surface: RInk.i900,
    onSurface: RInk.i050,
    onSurfaceVariant: RInk.i400,
    surfaceContainerLowest: RInk.i950,
    surfaceContainerLow: RInk.i950,
    surfaceContainer: RInk.i900,
    surfaceContainerHigh: RInk.i800,
    surfaceContainerHighest: RInk.i800,

    outline: RInk.i800,
    outlineVariant: RInk.i800,

    inverseSurface: RInk.i050,
    onInverseSurface: RInk.i950,
    inversePrimary: RAccent.meter500,

    shadow: Color(0x33000000),
    scrim: Color(0x99000000),
    surfaceTint: Color(0x00000000),
  );
}

/// The bottom nav, themed explicitly rather than left to Material defaults.
///
/// The indicator is neutral ink and the *icon* carries the accent. That is
/// the one-accent rule applied to navigation: "where you are" is signalled by
/// the accent on the icon, not by a filled pill in a second colour.
NavigationBarThemeData buildNavigationBarTheme({required bool isDark}) {
  final indicator = isDark ? RInk.i800 : RInk.i200;
  final background = isDark ? RInk.i950 : RInk.i050;
  final unselected = isDark ? RInk.i400 : RInk.i600;

  return NavigationBarThemeData(
    backgroundColor: background,
    indicatorColor: indicator,
    elevation: 0,
    surfaceTintColor: const Color(0x00000000),
    indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RRadius.control)),
    iconTheme: WidgetStateProperty.resolveWith((states) {
      final selected = states.contains(WidgetState.selected);
      return IconThemeData(color: selected ? RAccent.meter500 : unselected, size: 24);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      final selected = states.contains(WidgetState.selected);
      return TextStyle(
        fontFamily: RType.fontFamily,
        fontSize: RType.caption,
        fontVariations: [selected ? RType.weightMedium : RType.weightRegular],
        color: selected ? RAccent.meter500 : unselected,
      );
    }),
  );
}
