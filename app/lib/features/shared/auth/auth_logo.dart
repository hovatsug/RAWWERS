import 'package:flutter/material.dart';
import 'package:rawwers/design/brand.dart';
import 'package:rawwers/design/components/r_logo.dart';
import 'package:rawwers/design/tokens.dart';

/// The logo at the top of a signed-out screen, in the two-colour version
/// for the app's ground: on dark in the client app, on paper in the pro app.
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: RSpace.s24),
        child: RLogo.on(Theme.of(context).brightness, width: RBrand.signInLogoWidth),
      );
}
