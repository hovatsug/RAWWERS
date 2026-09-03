import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// A single photo in a grid (the selection gallery, portfolio, etc.).
/// Sharp corners (RRadius.photo = 0) - photography is rectangular, unlike
/// every other surface in this system, which gets RRadius.surface.
///
/// Selection is the one place the accent touches photo content directly:
/// a border + checkmark badge, nothing else. Callers are responsible for
/// keeping the tile itself >= rMinTouchTarget in grid layouts with tight
/// columns - this widget doesn't enforce a minimum size since its size is
/// inherently determined by the grid, not the widget.
class RImageTile extends StatelessWidget {
  const RImageTile({
    required this.image,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final ImageProvider image;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                border: selected ? Border.all(color: RAccent.meter500, width: 2) : null,
              ),
              child: Image(image: image, fit: BoxFit.cover),
            ),
            if (selected)
              Positioned(
                top: RSpace.s4,
                right: RSpace.s4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(color: RAccent.meter500, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 14, color: RInk.i050),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
