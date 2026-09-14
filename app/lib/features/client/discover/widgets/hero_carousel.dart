import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/discover/hero_slides.dart';

/// The hero at the top of Discover: one slide per niche, showing whoever
/// currently leads it.
///
/// Nothing here is curated. Slides come from the rows the screen already
/// has, ordered by the same ranking everything else uses, so nobody chooses
/// favourites and there is no second opinion about who is best at what. See
/// `heroSlidesFrom` for the selection and deduplication rules.
///
/// Renders nothing at all when there are no slides. A city with too few
/// photographers gets rows and no hero rather than a hero with a placeholder
/// in it.
class HeroCarousel extends StatefulWidget {
  const HeroCarousel({
    required this.slides,
    required this.onOpen,
    this.height = 320,
    super.key,
  });

  final List<HeroSlide> slides;

  /// Opens the slide. Currently the photographer's profile: the niche's own
  /// page does not exist yet, and sending someone to a route that is not
  /// built is worse than sending them to the photographer the slide is
  /// actually showing. When that page lands this is where it hooks in - the
  /// slide already carries its `nicheSlug` for exactly that.
  final void Function(HeroSlide slide) onOpen;

  final double height;

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

/// How long a slide holds before the carousel moves on.
const _slideDuration = Duration(seconds: 6);

/// One full Ken Burns pass, deliberately longer than a slide's turn so the
/// movement never visibly restarts while anyone is looking at it.
const _panDuration = Duration(seconds: 14);

class _HeroCarouselState extends State<HeroCarousel> with SingleTickerProviderStateMixin {
  final PageController _pages = PageController();

  // Created in initState, not as a `late final` initialiser. Lazily building
  // it meant that with no slides - where build returns before touching it -
  // dispose() was its first read, and creating a ticker while the element is
  // deactivating throws. The empty case is the one a thin city hits.
  late final AnimationController _pan;

  Timer? _advance;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pan = AnimationController(vsync: this, duration: _panDuration);
  }

  @override
  void dispose() {
    _advance?.cancel();
    _pan.dispose();
    _pages.dispose();
    super.dispose();
  }

  /// Motion is decided here rather than in initState because
  /// MediaQuery is not available that early, and because the setting can
  /// change while the app is open.
  void _syncMotion({required bool reduced}) {
    if (reduced) {
      _advance?.cancel();
      _advance = null;
      if (_pan.isAnimating) _pan.stop();
      _pan.value = 0;
      return;
    }
    if (!_pan.isAnimating) _pan.repeat(reverse: true);
    _advance ??= Timer.periodic(_slideDuration, (_) => _step());
  }

  void _step() {
    if (!mounted || !_pages.hasClients || widget.slides.length < 2) return;
    final next = (_index + 1) % widget.slides.length;
    _pages.animateToPage(next, duration: const Duration(milliseconds: 520), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final reduced = MediaQuery.disableAnimationsOf(context);
    _syncMotion(reduced: reduced);

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pages,
            itemCount: widget.slides.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, index) {
              final slide = widget.slides[index];
              return GestureDetector(
                onTap: () => widget.onOpen(slide),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _KenBurns(
                      animation: _pan,
                      enabled: !reduced,
                      // Alternating direction, so consecutive slides do not
                      // drift the same way and read as one long pan.
                      reverse: index.isOdd,
                      child: RNetworkPhoto(
                        url: slide.card.coverUrl,
                        semanticLabel: '${slide.card.displayName ?? 'Photographer'}, ${slide.title}',
                      ),
                    ),
                    // The photograph is the point, so the scrim is only as
                    // dark as the text needs and only where the text is.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0xCC000000)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: RSpace.s16,
                      right: RSpace.s16,
                      bottom: RSpace.s24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            slide.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(color: RInk.i200),
                          ),
                          const SizedBox(height: RSpace.s4),
                          Text(
                            slide.card.displayName ?? 'Photographer',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineSmall?.copyWith(color: RInk.i050),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (widget.slides.length > 1)
            Positioned(
              right: RSpace.s16,
              bottom: RSpace.s24,
              child: Row(
                children: [
                  for (var i = 0; i < widget.slides.length; i++) ...[
                    if (i > 0) const SizedBox(width: RSpace.s4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _index ? RInk.i050 : RInk.i050.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Identifies the Ken Burns transform specifically. PageView builds
/// transforms of its own while scrolling, so a test asserting "no transform"
/// would pass or fail for reasons having nothing to do with this effect.
const kenBurnsTransformKey = ValueKey('hero-ken-burns');


/// A slow scale and drift across a still photograph.
///
/// Built from an AnimationController and a Transform rather than a package:
/// the whole effect is one scale and one offset driven by a repeating
/// controller, and the photo viewer already establishes that animation here
/// is hand-rolled.
///
/// When disabled it returns the child untouched - not a zero-duration
/// animation, which still rebuilds on every tick for no visible result.
class _KenBurns extends StatelessWidget {
  const _KenBurns({
    required this.animation,
    required this.enabled,
    required this.reverse,
    required this.child,
  });

  final Animation<double> animation;
  final bool enabled;
  final bool reverse;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = reverse ? 1 - animation.value : animation.value;
        // Small numbers on purpose. A hero that visibly zooms competes with
        // the photograph it is meant to present.
        final scale = 1.06 + (t * 0.06);
        return ClipRect(
          child: Transform.scale(
            key: kenBurnsTransformKey,
            scale: scale,
            alignment: Alignment(-0.15 + (t * 0.3), -0.1 + (t * 0.2)),
            child: child,
          ),
        );
      },
    );
  }
}
