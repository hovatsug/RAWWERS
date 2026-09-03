import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// Builds the shared type scale (see RType) with theme-specific text
/// colors. Both apps use identical sizes/weights - only text-primary and
/// text-secondary differ between the dark client theme and the light pro
/// theme.
TextTheme buildTextTheme({required Color primary, required Color secondary}) {
  TextStyle style(double size, FontVariation weight, Color color, double height) {
    return TextStyle(
      fontFamily: RType.fontFamily,
      fontSize: size,
      fontVariations: [weight],
      color: color,
      height: height,
    );
  }

  return TextTheme(
    displayLarge: style(RType.displayLg, RType.weightSemibold, primary, RType.lineHeightDisplay),
    displayMedium: style(RType.displayMd, RType.weightSemibold, primary, RType.lineHeightDisplay),
    displaySmall: style(RType.displaySm, RType.weightSemibold, primary, RType.lineHeightDisplay),
    titleLarge: style(RType.title, RType.weightSemibold, primary, RType.lineHeightUi),
    bodyLarge: style(RType.body, RType.weightRegular, primary, RType.lineHeightUi),
    bodyMedium: style(RType.body, RType.weightRegular, secondary, RType.lineHeightUi),
    labelLarge: style(RType.label, RType.weightMedium, primary, RType.lineHeightUi),
    bodySmall: style(RType.caption, RType.weightRegular, secondary, RType.lineHeightUi),
  );
}
