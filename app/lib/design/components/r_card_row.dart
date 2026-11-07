import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// A heading over a horizontally scrolling row of cards, bleeding to the
/// screen's edges: the client's photographer rows and the pro's Shelf
/// levels. One layout, so the two cannot drift in spacing.
class RCardRow extends StatelessWidget {
  const RCardRow({
    required this.heading,
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
    this.footer,
    super.key,
  });

  final Widget heading;

  /// The cards' height, the same while loading and loaded.
  final double height;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// A line under the row, when it needs one.
  final Widget? footer;

  static const gap = RSpace.s12;
  static const sidePadding = EdgeInsets.symmetric(horizontal: RSpace.s16);
  static const headingPadding = EdgeInsets.fromLTRB(RSpace.s16, RSpace.s24, RSpace.s16, RSpace.s8);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: headingPadding, child: heading),
        SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: sidePadding,
            itemCount: itemCount,
            separatorBuilder: (context, index) => const SizedBox(width: gap),
            itemBuilder: itemBuilder,
          ),
        ),
        if (footer != null) Padding(padding: const EdgeInsets.fromLTRB(RSpace.s16, RSpace.s8, RSpace.s16, 0), child: footer),
      ],
    );
  }
}
