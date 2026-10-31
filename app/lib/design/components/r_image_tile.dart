import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
///
/// Where tapping the tile selects it, [onExpand] is the other way in: a
/// small button in the corner, and a long press, that open the photo full
/// screen. [selectable] then shows an empty ring on unselected tiles, so it
/// is plain before the first tap that tapping ticks.
class RImageTile extends StatelessWidget {
  const RImageTile({
    required this.image,
    this.selected = false,
    this.selectable = false,
    this.onTap,
    this.onExpand,
    this.semanticLabel,
    super.key,
  });

  final ImageProvider image;
  final bool selected;
  final bool selectable;
  final VoidCallback? onTap;
  final VoidCallback? onExpand;

  /// What a screen reader says for the tile, e.g. "Photo 12, selected".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final expand = onExpand;
    return Semantics(
      selected: selected,
      button: onTap != null,
      label: semanticLabel,
      customSemanticsActions: {const CustomSemanticsAction(label: 'Open full screen'): ?expand},
      child: InkWell(
        onTap: onTap,
        onLongPress: expand,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                border: selected ? Border.all(color: RAccent.meter500, width: 3) : null,
              ),
              child: Image(
                image: image,
                fit: BoxFit.cover,
                // Same stance as RNetworkPhoto: these URLs are signed and
                // expire, so a tile that cannot load is an ordinary event and
                // gets the quiet placeholder. Without this the failure is an
                // uncaught exception rather than a missing photo.
                errorBuilder: (context, error, stack) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: RSpace.s24,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
            if (selected || selectable)
              Positioned(
                top: RSpace.s4,
                right: RSpace.s4,
                child: ExcludeSemantics(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: selected ? RAccent.meter500 : Colors.black26,
                      shape: BoxShape.circle,
                      border: Border.all(color: RInk.i050, width: 2),
                    ),
                    child: selected ? const Icon(Icons.check, size: 16, color: RInk.i050) : null,
                  ),
                ),
              ),
            if (expand != null)
              Positioned(
                left: 0,
                bottom: 0,
                // The visible mark is small; the target is the full minimum,
                // so it is not a mis-tap next to the tap that selects.
                child: ExcludeSemantics(
                  child: SizedBox.square(
                    dimension: rMinTouchTarget,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkResponse(
                        key: const ValueKey('r-image-tile-expand'),
                        onTap: expand,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                            child: const Icon(Icons.open_in_full, size: 16, color: RInk.i050),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
