import 'package:flutter/material.dart';

class RTextField extends StatelessWidget {
  const RTextField({
    super.key,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(hintText: hintText),
    );
  }
}
