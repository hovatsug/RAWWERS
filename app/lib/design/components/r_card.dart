import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// Border-based elevation (the theme's CardTheme has elevation: 0 and a
/// hairline side) - not a shadow. Shadows are reserved for genuinely
/// floating surfaces (see RElevation.shadowFloat), which a card is not.
class RCard extends StatelessWidget {
  const RCard({required this.child, this.padding = const EdgeInsets.all(RSpace.s16), super.key});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(padding: padding, child: child),
    );
  }
}
