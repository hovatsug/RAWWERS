import 'package:flutter/material.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/design/tokens.dart';

/// A kind of photography, shown as a photograph of that kind of photography.
///
/// The one place in this product where a streaming-service pattern genuinely
/// does not transfer. A genre tile on Netflix is a word because "Comedy" has
/// no canonical image and the catalogue is bought in. Here the catalogue is
/// made by the people using the app, so a niche tile can be an actual
/// photograph *from that niche, by a photographer you can book* - a live
/// sample of the marketplace's own inventory rather than an illustration of a
/// category.
///
/// That is also why the image is passed in rather than chosen here: the
/// caller knows which photograph is the honest one for its context, and the
/// rule "the top-ranked photographer in this niche, in this city" belongs
/// near the data that establishes ranking, not in a widget.
class RNicheTile extends StatelessWidget {
  const RNicheTile({
    required this.label,
    required this.imageUrl,
    this.onTap,
    this.width = 168,
    this.height = 112,
    super.key,
  });

  final String label;

  /// Null renders the neutral ground rather than a broken frame. A niche with
  /// no photographer in this city yet is an ordinary state - the marketplace
  /// is young - and it must not look like a failure.
  final String? imageUrl;

  final VoidCallback? onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: onTap != null,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl != null)
                RNetworkPhoto(url: imageUrl)
              else
                ColoredBox(color: theme.colorScheme.surfaceContainerHighest),

              // A scrim rather than a flat overlay: photographs vary, and a
              // fixed tint that keeps text legible on a dark frame washes out
              // a bright one. Weighted to the bottom, where the label sits, so
              // the top of the photograph stays as the photographer shot it.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0x99000000)],
                    stops: [0.45, 1.0],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(RSpace.s8),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: RInk.i050,
                      // The scrim handles most frames; this covers the bright
                      // ones it does not, without darkening the photograph
                      // further for every other tile.
                      shadows: const [Shadow(color: Color(0xCC000000), blurRadius: 6)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
