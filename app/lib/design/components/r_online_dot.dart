import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// A photographer whose app is open right now. Only ever shown from the
/// server's `online` flag - never worked out from a time on the device - and
/// never accompanied by a "last seen".
class ROnlineDot extends StatelessWidget {
  const ROnlineDot({this.showLabel = false, super.key});

  /// "Online" next to the dot, for a profile; a card has no room for it.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    const dot = DecoratedBox(
      decoration: BoxDecoration(color: RDevelop.develop500, shape: BoxShape.circle),
      child: SizedBox(width: 10, height: 10),
    );
    return Semantics(
      label: 'Online now',
      excludeSemantics: true,
      child: showLabel
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                dot,
                const SizedBox(width: 6),
                Text('Online', style: Theme.of(context).textTheme.bodySmall),
              ],
            )
          : dot,
    );
  }
}
