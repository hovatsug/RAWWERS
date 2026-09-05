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
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    this.maxLines = 1,
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

  /// What the OS should offer to fill here. Leaving this null does not mean
  /// "no autofill" - iOS guesses from surrounding labels, and it guesses
  /// badly: an unhinted email field on a sign-up form was observed being
  /// offered the device's Apple ID. Every text field that could plausibly
  /// be autofilled should say what it is, and the register/login split
  /// matters specifically: `newPassword` is what prompts the OS to offer to
  /// *save* a generated password, `password` is what prompts it to fill an
  /// existing one.
  final List<String>? autofillHints;

  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  /// Grows the field for free-text notes. Kept at 1 by default so every
  /// existing single-line field is unaffected.
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      maxLines: maxLines,
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
