import 'package:flutter/material.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/tokens.dart';

/// Uses RShade (the same stopped-state color as CANCELLED/DISPUTED chips) -
/// not the accent, which is reserved for things that are actionable in a
/// forward direction. An error is stopped, not a call to action, even
/// though the retry button beside it is.
class RErrorState extends StatelessWidget {
  const RErrorState({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RSpace.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 32, color: RShade.shade600),
            const SizedBox(height: RSpace.s12),
            Text(message, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: RSpace.s16),
              RButton(label: 'Retry', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
