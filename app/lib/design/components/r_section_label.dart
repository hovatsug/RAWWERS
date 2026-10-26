import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// A section's label: 11px, medium, tracked, in capitals - the small print on
/// a contact sheet. Written in sentence case and shown in capitals, so a
/// screen reader says the words rather than spelling the letters.
class RSectionLabel extends StatelessWidget {
  const RSectionLabel(this.text, {this.color, super.key});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      semanticsLabel: text,
      style: TextStyle(
        fontFamily: RType.fontFamily,
        fontSize: RType.caption,
        fontVariations: const [RType.weightMedium],
        letterSpacing: RType.caption * RType.trackingSection,
        height: RType.lineHeightUi,
        color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
