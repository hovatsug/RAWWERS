import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rawwers/design/brand.dart';
import 'package:rawwers/design/components/r_logo.dart';
import 'package:rawwers/design/tokens.dart';

/// Shown for AuthState.Unknown - the window between reading session storage
/// and GET /v1/me returning is real and visible on a slow connection.
/// Deliberate, not a flash of whatever the router would otherwise render.
///
/// Always dark, in both flavors: it is the first Flutter frame, and it takes
/// over from the native launch screen without a visible change. Same ground
/// (Ink 950), and the logo in the same rectangle - centred on the screen,
/// not the safe area, at the width tools/brand gives the storyboards and
/// Android's launch drawable. The spinner stays under the logo: on a slow
/// connection it is the only sign that something is happening. It hangs
/// below the logo's box rather than sharing a column with it, so it can
/// never move the logo.
class LaunchScreen extends StatelessWidget {
  const LaunchScreen({super.key});

  /// The ground both native launch screens paint (tools/brand writes the
  /// same token into the storyboards and the Android launch_ground).
  static const ground = RInk.i950;

  @override
  Widget build(BuildContext context) {
    const width = RBrand.launchLogoWidth;
    const height = width / RBrand.logoAspectRatio;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ground,
        body: Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const RLogo(tone: RLogoTone.primaryOnDark, width: width),
                Positioned(
                  top: height + RSpace.s24,
                  left: 0,
                  right: 0,
                  child: const Center(
                    child: SizedBox.square(
                      dimension: RIcon.control,
                      child: CircularProgressIndicator(strokeWidth: 2, color: RAccent.meter500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
