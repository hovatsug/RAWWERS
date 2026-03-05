import 'package:flutter/material.dart';

import '../tokens.dart';

enum RButtonVariant { primary, secondary, ghost }

class RButton extends StatelessWidget {
  const RButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = RButtonVariant.primary,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final RButtonVariant variant;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final Widget child = isLoading
        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
        : Text(label);

    switch (variant) {
      case RButtonVariant.primary:
        return ElevatedButton(onPressed: enabled ? onPressed : null, child: child);
      case RButtonVariant.secondary:
        return OutlinedButton(onPressed: enabled ? onPressed : null, child: child);
      case RButtonVariant.ghost:
        return TextButton(
          onPressed: enabled ? onPressed : null,
          style: TextButton.styleFrom(foregroundColor: RTokens.neutralMuted),
          child: child,
        );
    }
  }
}
