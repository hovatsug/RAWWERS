import 'package:flutter/material.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/core/images/disk_cached_image.dart';

/// A photograph fetched over the network, with all three states handled.
///
/// Sharp corners like [RImageTile] - RRadius.photo is 0 because photography
/// is rectangular in this system, unlike every other surface.
///
/// The URLs this renders are signed and expire (see the backend's
/// MEDIA_URL_BASE_TTL_SECONDS). An app left open past the expiry will fail to
/// load images it has not already cached, so a failure here is an ordinary
/// event rather than an exceptional one: it falls back to the same quiet
/// placeholder as a pro with no photo at all, and a pull-to-refresh fetches
/// freshly signed URLs. A broken-image icon would be the wrong answer - it
/// reads as the photographer's fault.
class RNetworkPhoto extends StatelessWidget {
  const RNetworkPhoto({
    required this.url,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.loading,
    super.key,
  });

  final String? url;
  final BoxFit fit;

  /// Which part of the photo a crop keeps - a banner's focal point.
  final Alignment alignment;
  final String? semanticLabel;

  /// Shown while the photo loads, in place of the skeleton - a banner's
  /// blurred placeholder.
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    final source = url;
    if (source == null || source.isEmpty) {
      return const _PhotoFallback();
    }

    return Image(
      image: DiskCachedImage(source),
      fit: fit,
      alignment: alignment,
      semanticLabel: semanticLabel,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return loading ?? const RSkeleton(height: double.infinity, radius: RRadius.photo);
      },
      errorBuilder: (context, error, stack) => const _PhotoFallback(),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.photo_camera_outlined,
          size: RSpace.s24,
          color: scheme.outline,
        ),
      ),
    );
  }
}
