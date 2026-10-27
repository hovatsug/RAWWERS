import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rawwers/design/brand.dart';

/// Which of the four logo files: the two-colour logo for a dark or a light
/// ground, or a one-colour one.
enum RLogoTone { primaryOnDark, primaryOnLight, monoInk, monoWhite }

/// The RAWWERS logo: the word in four viewfinder corners, drawn from the
/// generated SVG files (tools/brand), never retyped as text.
///
/// [width] sets the size; the height follows the logo's own proportions.
/// Below [RBrand.logoMinPrimaryWidth] a two-colour tone gives way to the
/// one-colour logo for the same ground, as the brand rules ask
/// (design/brand/README.md). A screen reader hears "RAWWERS".
class RLogo extends StatelessWidget {
  const RLogo({required this.tone, required this.width, super.key});

  /// The two-colour logo for a ground of [brightness].
  const RLogo.on(Brightness brightness, {required this.width, super.key})
      : tone = brightness == Brightness.dark ? RLogoTone.primaryOnDark : RLogoTone.primaryOnLight;

  final RLogoTone tone;
  final double width;

  static const semanticsLabel = 'RAWWERS';

  double get height => width / RBrand.logoAspectRatio;

  /// The tone actually drawn at [width].
  RLogoTone get drawn => width >= RBrand.logoMinPrimaryWidth
      ? tone
      : switch (tone) {
          RLogoTone.primaryOnDark => RLogoTone.monoWhite,
          RLogoTone.primaryOnLight => RLogoTone.monoInk,
          final mono => mono,
        };

  static String assetFor(RLogoTone tone) => switch (tone) {
        RLogoTone.primaryOnDark => RBrand.primaryOnDark,
        RLogoTone.primaryOnLight => RBrand.primaryOnLight,
        RLogoTone.monoInk => RBrand.monoInk,
        RLogoTone.monoWhite => RBrand.monoWhite,
      };

  static final _pictures = <RLogoTone, PictureInfo>{};

  /// Decodes the four logos once, ahead of time, so a logo paints in the
  /// frame it first appears in. flutter_svg decodes asynchronously: without
  /// this, the first frame of /launch - the one that replaces the native
  /// launch screen - would show the ground without the logo, and the logo
  /// would blink. Called before runApp.
  static Future<void> precache() async {
    for (final tone in RLogoTone.values) {
      if (_pictures.containsKey(tone)) continue;
      _pictures[tone] = await vg.loadPicture(SvgAssetLoader(assetFor(tone)), null);
    }
  }

  /// Whether [tone] is decoded and paints synchronously.
  @visibleForTesting
  static bool isPrecached(RLogoTone tone) => _pictures.containsKey(tone);

  @override
  Widget build(BuildContext context) {
    final picture = _pictures[drawn];
    return Semantics(
      label: semanticsLabel,
      image: true,
      child: SizedBox(
        width: width,
        height: height,
        child: picture != null
            ? CustomPaint(painter: _LogoPainter(picture))
            : SvgPicture.asset(assetFor(drawn), width: width, height: height, excludeFromSemantics: true),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter(this.info);

  final PictureInfo info;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / info.size.width, size.height / info.size.height)
      ..drawPicture(info.picture)
      ..restore();
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.info != info;
}
