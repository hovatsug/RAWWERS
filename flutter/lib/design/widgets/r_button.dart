import 'package:flutter/material.dart';
import '../tokens.dart';

enum RButtonVariant { primary, glass, ghost, secondary }

class RButton extends StatelessWidget {
  const RButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = RButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final RButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final Widget labelWidget = isLoading
        ? const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(icon, size: 16), const SizedBox(width: 6), Text(label)],
              )
            : Text(label);

    switch (variant) {
      case RButtonVariant.primary:
        return _GradientButton(onPressed: enabled ? onPressed : null, child: labelWidget);

      case RButtonVariant.glass:
      case RButtonVariant.secondary:
        return _GlassButton(onPressed: enabled ? onPressed : null, child: labelWidget);

      case RButtonVariant.ghost:
        return TextButton(
          onPressed: enabled ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: RTokens.textMutedDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RTokens.radiusXl)),
            padding: const EdgeInsets.symmetric(horizontal: RTokens.spacingX4, vertical: RTokens.spacingX2),
          ),
          child: labelWidget,
        );
    }
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [RTokens.violet, RTokens.blue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(RTokens.radiusXl),
        boxShadow: RTokens.glowShadow(RTokens.glowVioletSm),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RTokens.radiusXl)),
          padding: const EdgeInsets.symmetric(horizontal: RTokens.spacingX6, vertical: RTokens.spacingX3),
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: RTokens.textSm),
          child: child,
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: RTokens.textOnDark,
        backgroundColor: RTokens.glassCardBg,
        side: const BorderSide(color: RTokens.glassCardBorder, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RTokens.radiusXl)),
        padding: const EdgeInsets.symmetric(horizontal: RTokens.spacingX6, vertical: RTokens.spacingX3),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: RTokens.textSm),
        child: child,
      ),
    );
  }
}
