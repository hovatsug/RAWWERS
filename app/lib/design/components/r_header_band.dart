import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/design/typography.dart';

/// The pro app's dark header band ("Contact sheet"): the client app's dark,
/// carrying the brand and the money, above the light paper body.
///
/// It reaches under the status bar (and asks for light status icons) while
/// keeping its content below it, and ends in the dark hairline. Everything
/// inside is themed for the dark: light text, the meter500 accent for
/// brackets and needles, and the band's own primary button - meter500Band
/// with a dark label, because meter700 all but disappears on this ground.
class RHeaderBand extends StatelessWidget {
  const RHeaderBand({required this.child, this.padding = const EdgeInsets.fromLTRB(RSpace.s16, RSpace.s16, RSpace.s16, RSpace.s24), super.key});

  final Widget child;
  final EdgeInsetsGeometry padding;

  static const groundKey = ValueKey('header-band-ground');
  static const hairlineKey = ValueKey('header-band-hairline');

  /// The theme inside the band, from the screen's own.
  static ThemeData themeFor(ThemeData base) {
    final text = buildTextTheme(primary: RInk.i050, secondary: RInk.i400);
    return base.copyWith(
      textTheme: text,
      iconTheme: const IconThemeData(color: RInk.i050),
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: RAccent.meter500,
        onPrimary: RInk.i950,
        surface: RInk.i950,
        onSurface: RInk.i050,
        onSurfaceVariant: RInk.i400,
        outline: RInk.i800,
        outlineVariant: RInk.i800,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RAccent.meter500Band,
          foregroundColor: RInk.i950,
          disabledBackgroundColor: RInk.i800,
          disabledForegroundColor: RInk.i400,
          minimumSize: const Size.fromHeight(rMinTouchTarget),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RRadius.control)),
          textStyle: TextStyle(fontFamily: RType.fontFamily, fontSize: RType.label, fontVariations: const [RType.weightMedium]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = themeFor(Theme.of(context));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Theme(
        data: theme,
        child: DefaultTextStyle.merge(
          style: theme.textTheme.bodyLarge,
          child: ColoredBox(
            key: groundKey,
            color: RInk.i950,
            child: DecoratedBox(
              key: hairlineKey,
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: RInk.i800))),
              child: SafeArea(bottom: false, child: Padding(padding: padding, child: child)),
            ),
          ),
        ),
      ),
    );
  }
}
