import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// A rectangular switch for the pro app: no stadium shapes in Contact sheet.
///
/// Behaves as Material's switch does to everyone who cannot see it - a label,
/// a toggled state, an enabled state, a tap - and keeps a 44px target. On is
/// the accent; off is a neutral track with a border that clears 3:1, so an
/// off switch is still visibly a control.
class RSwitch extends StatelessWidget {
  const RSwitch({required this.value, required this.onChanged, this.semanticLabel, super.key});

  final bool value;

  /// Null disables it.
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  static const trackKey = ValueKey('r-switch-track');

  // The control drawn inside the 44px target, on the 8px grid.
  static const _trackWidth = RSpace.s48 - RSpace.s8;
  static const _trackHeight = RSpace.s24;
  static const _thumb = RSpace.s16;
  static const _inset = (RSpace.s24 - RSpace.s16) / 2;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onChanged != null;
    final on = value;
    final track = on ? scheme.primary : RInk.i100;
    final thumb = on ? RInk.i050 : RInk.i500;

    return Semantics(
      label: semanticLabel,
      toggled: value,
      enabled: enabled,
      focusable: enabled,
      onTap: enabled ? () => onChanged!(!value) : null,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged!(!value) : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: rMinTouchTarget + RSpace.s4, minHeight: rMinTouchTarget),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: Opacity(
              opacity: enabled ? 1 : 0.4,
              child: SizedBox(
                width: _trackWidth,
                height: _trackHeight,
                child: DecoratedBox(
                  key: trackKey,
                  decoration: BoxDecoration(
                    color: track,
                    borderRadius: BorderRadius.circular(RRadius.control),
                    border: Border.all(color: on ? scheme.primary : RInk.i500),
                  ),
                  child: Align(
                    alignment: on ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(_inset),
                      child: SizedBox(
                        width: _thumb,
                        height: _thumb,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: thumb, borderRadius: BorderRadius.circular(RRadius.control / 2)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
