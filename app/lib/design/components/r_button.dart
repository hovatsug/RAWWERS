import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

enum RButtonVariant {
  /// Filled. The one obvious action on a screen.
  primary,

  /// Outlined. For an action offered *alongside* a primary one - Decline
  /// next to Accept, "Load more" under a list. Deliberately not a third
  /// colour: a decline is a normal outcome of reviewing a request, not a
  /// destructive one, and painting it red would push photographers toward
  /// accepting work they should turn down.
  secondary,
}

/// Primary action. Uses the theme's ElevatedButtonTheme (meter700 fill,
/// i050 label - see theme_client.dart/theme_pro.dart for why the fill is a
/// darker shade than the general accent token).
class RButton extends StatelessWidget {
  const RButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.variant = RButtonVariant.primary,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final RButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final spinnerColor = variant == RButtonVariant.primary ? RInk.i050 : RAccent.meter500;
    final child = loading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: spinnerColor),
          )
        : Text(label);

    return switch (variant) {
      RButtonVariant.primary => ElevatedButton(onPressed: loading ? null : onPressed, child: child),
      RButtonVariant.secondary => OutlinedButton(onPressed: loading ? null : onPressed, child: child),
    };
  }
}

/// A selectable filter chip - "Pending", "Accepted", and so on.
///
/// Distinct from [RStatusChip], which *reports* a booking's state and is
/// never tappable. Keeping them separate stops a status colour (develop500
/// for done, shade600 for stopped) from leaking onto a control, where it
/// would read as state rather than selection.
class RFilterChip extends StatelessWidget {
  const RFilterChip({required this.label, required this.selected, required this.onPressed, super.key});

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: rMinTouchTarget),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(RRadius.control),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: RSpace.s16, vertical: RSpace.s8),
          decoration: BoxDecoration(
            // Selection reads as a filled ground, not just a colour shift -
            // colour alone would carry the state for anyone who can't
            // distinguish the accent from the border.
            color: selected ? RAccent.meter700 : Colors.transparent,
            border: Border.all(color: selected ? RAccent.meter700 : onSurface.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(RRadius.control),
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(color: selected ? RInk.i050 : onSurface),
            ),
          ),
        ),
      ),
    );
  }
}

/// A tappable inline text link. Always underlined - the accent color alone
/// (~4.1-4.5:1 against the two theme backgrounds, see RAccent doc comment)
/// isn't reliably AA-compliant for body-sized text on its own.
class RTextLink extends StatelessWidget {
  const RTextLink({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: rMinTouchTarget),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: RAccent.meter500,
                  decoration: TextDecoration.underline,
                ),
          ),
        ),
      ),
    );
  }
}
