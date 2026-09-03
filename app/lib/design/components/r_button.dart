import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// Primary action. Uses the theme's ElevatedButtonTheme (meter700 fill,
/// i050 label - see theme_client.dart/theme_pro.dart for why the fill is a
/// darker shade than the general accent token).
class RButton extends StatelessWidget {
  const RButton({required this.label, required this.onPressed, this.loading = false, super.key});

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: RInk.i050),
            )
          : Text(label),
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
