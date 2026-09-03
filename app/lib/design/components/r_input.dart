import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

class RInput extends StatelessWidget {
  const RInput({
    required this.label,
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.tabularFigures = false,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;

  /// Set for numeric fields displayed in a table-like context, so digits
  /// stay column-aligned.
  final bool tabularFigures;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(
        fontFeatures: tabularFigures ? RType.tabularFigures : null,
      ),
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        constraints: const BoxConstraints(minHeight: rMinTouchTarget),
      ),
    );
  }
}
