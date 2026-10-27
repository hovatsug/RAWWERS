import 'package:flutter/material.dart';
import 'package:rawwers/design/components/r_switch.dart';
import 'package:rawwers/design/tokens.dart';

/// A setting with a title, an optional line under it, and the pro app's
/// rectangular switch - in place of Material's SwitchListTile, which draws a
/// stadium. The switch is named by the title for a screen reader, and the
/// whole row toggles it, as Material's does.
class RSwitchTile extends StatelessWidget {
  const RSwitchTile({required this.title, required this.value, required this.onChanged, this.subtitle, super.key});

  final String title;
  final Widget? subtitle;
  final bool value;

  /// Null disables it.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sub = subtitle;
    final changed = onChanged;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // The switch already says what it is and does to a screen reader.
      excludeFromSemantics: true,
      onTap: changed == null ? null : () => changed(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: RSpace.s4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Read once, as the switch's label, not again as text.
                  ExcludeSemantics(child: Text(title, style: theme.textTheme.bodyLarge)),
                  if (sub != null) ...[
                    const SizedBox(height: RSpace.s2),
                    DefaultTextStyle.merge(style: theme.textTheme.bodySmall, child: sub),
                  ],
                ],
              ),
            ),
            const SizedBox(width: RSpace.s8),
            RSwitch(value: value, onChanged: onChanged, semanticLabel: title),
          ],
        ),
      ),
    );
  }
}
