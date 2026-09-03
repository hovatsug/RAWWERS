import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// No illustration, no accent - both are on the forbidden list for empty
/// states (decoration competing with the fact that there's genuinely
/// nothing to show yet). Icon + two lines of plain text.
class REmptyState extends StatelessWidget {
  const REmptyState({required this.title, this.body, this.icon = Icons.inbox_outlined, super.key});

  final String title;
  final String? body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RSpace.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.outline),
            const SizedBox(height: RSpace.s12),
            Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            if (body != null) ...[
              const SizedBox(height: RSpace.s4),
              Text(body!, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
