import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rawwers/api/models/niche_banner_view.dart';
import 'package:rawwers/api/models/niche_banner_style.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/design/tokens.dart';

/// Where a banner sits: a Discover tile (a niche row's heading) or the hero at
/// the top of the niche's own page. The tile shows the tile-sized image and
/// the name; the hero the large image, the name and the tagline.
enum RNicheBannerShape { tile, hero }

/// A niche's banner - the one component every screen draws it with.
///
/// Draws what the server sends and decides nothing about it:
///
///   - **Text only**: a designed typographic banner - the meter-blue ground,
///     a short rule, the name and tagline. Deliberate, not a missing image,
///     and it makes no image request at all.
///   - **Image**: the admin's image, cropped around their focal point on
///     every shape, its blurred placeholder underneath while it loads, and a
///     scrim as dark as the server measured this image needs for the white
///     title to keep its contrast.
///   - **Image, none uploaded**: the neutral ground with the name - an
///     ordinary state, never a broken frame.
class RNicheBanner extends StatelessWidget {
  const RNicheBanner({
    required this.title,
    required this.banner,
    this.shape = RNicheBannerShape.tile,
    this.onTap,
    this.width = double.infinity,
    this.height,
    super.key,
  });

  /// What the banner says: the row's own title on Discover ("Weddings in
  /// Lisbon"), the niche's name on its page.
  final String title;

  /// Null draws the neutral ground: a response from before banners existed.
  final NicheBannerView? banner;
  final RNicheBannerShape shape;
  final VoidCallback? onTap;
  final double width;

  /// Defaults to 96 for a tile and 200 for a hero.
  final double? height;

  bool get _hero => shape == RNicheBannerShape.hero;

  @override
  Widget build(BuildContext context) {
    final view = banner;
    final image = view?.style == NicheBannerStyle.image ? view?.image : null;
    final Widget body;
    if (view?.style == NicheBannerStyle.text) {
      body = _TextOnly(title: title, tagline: _hero ? view?.tagline : null, hero: _hero);
    } else if (image != null) {
      body = _ImageBanner(
        title: title,
        tagline: _hero ? view?.tagline : null,
        hero: _hero,
        url: _hero ? image.heroUrl : image.tileUrl,
        alt: image.altText,
        alignment: Alignment(image.focalX * 2 - 1, image.focalY * 2 - 1),
        scrimOpacity: image.scrimOpacity,
        placeholder: _placeholderBytes(image.placeholder),
      );
    } else {
      body = _Neutral(title: title, hero: _hero);
    }

    return Semantics(
      button: onTap != null,
      label: title,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(width: width, height: height ?? (_hero ? 200 : 96), child: body),
      ),
    );
  }
}

/// The inline placeholder, or nothing if it cannot be read.
Uint8List? _placeholderBytes(String dataUri) {
  try {
    return UriData.parse(dataUri).contentAsBytes();
  } on FormatException {
    return null;
  }
}

TextStyle? _titleStyle(BuildContext context, {required bool hero, required Color color}) {
  final theme = Theme.of(context).textTheme;
  return (hero ? theme.displaySmall : theme.titleSmall)?.copyWith(color: color);
}

class _TextOnly extends StatelessWidget {
  const _TextOnly({required this.title, required this.tagline, required this.hero});

  final String title;
  final String? tagline;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final line = tagline;
    return ColoredBox(
      key: const ValueKey('niche-banner-text'),
      color: RBanner.textGround,
      child: Padding(
        padding: EdgeInsets.all(hero ? RSpace.s24 : RSpace.s12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: RSpace.s24, height: 2, child: ColoredBox(color: RBanner.textRule)),
            const SizedBox(height: RSpace.s8),
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: _titleStyle(context, hero: hero, color: RBanner.textName)),
            if (line != null && line.isNotEmpty) ...[
              const SizedBox(height: RSpace.s4),
              Text(
                line,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: RBanner.textTagline),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ImageBanner extends StatelessWidget {
  const _ImageBanner({
    required this.title,
    required this.tagline,
    required this.hero,
    required this.url,
    required this.alt,
    required this.alignment,
    required this.scrimOpacity,
    required this.placeholder,
  });

  final String title;
  final String? tagline;
  final bool hero;
  final String url;
  final String alt;
  final Alignment alignment;
  final double scrimOpacity;
  final Uint8List? placeholder;

  @override
  Widget build(BuildContext context) {
    final bytes = placeholder;
    final line = tagline;
    return Stack(
      key: const ValueKey('niche-banner-image'),
      fit: StackFit.expand,
      children: [
        RNetworkPhoto(
          url: url,
          alignment: alignment,
          semanticLabel: alt,
          loading: bytes == null
              ? null
              : Image.memory(bytes, fit: BoxFit.cover, alignment: alignment, excludeFromSemantics: true, gaplessPlayback: true),
        ),
        // Weighted to the bottom, where the title sits, so the top of the
        // photograph stays as it was taken; its strength is this image's.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [RBanner.scrim.withValues(alpha: 0), RBanner.scrim.withValues(alpha: scrimOpacity)],
              stops: const [0.35, 1.0],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(hero ? RSpace.s24 : RSpace.s8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: _titleStyle(context, hero: hero, color: RBanner.title)),
              if (line != null && line.isNotEmpty) ...[
                const SizedBox(height: RSpace.s4),
                Text(
                  line,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: RBanner.title),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Neutral extends StatelessWidget {
  const _Neutral({required this.title, required this.hero});

  final String title;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      key: const ValueKey('niche-banner-neutral'),
      color: scheme.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsets.all(hero ? RSpace.s24 : RSpace.s8),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: _titleStyle(context, hero: hero, color: scheme.onSurface)),
        ),
      ),
    );
  }
}
