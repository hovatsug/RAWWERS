import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/core/images/disk_cached_image.dart';

/// A photograph, full screen, with the gestures people already expect.
///
/// Every gallery in both apps opens into this one widget rather than each
/// growing its own: a client judging whether a photo is sharp enough to buy
/// and a photographer checking what they are about to deliver are the same
/// interaction, and they must not drift apart.
///
/// Three gestures, and the interactions between them are the whole design:
///
///   - Horizontal swipe pages between photos.
///   - Pinch, or double-tap, zooms.
///   - A downward drag dismisses.
///
/// Zoom is what makes those conflict. While a photo is zoomed in, paging is
/// disabled so a horizontal pan moves *within* the photo instead of skipping
/// to the next one, and the drag-to-dismiss is disabled too - otherwise
/// panning down to look at the bottom of a frame throws the viewer away. Both
/// come back the moment the photo is back at 1x.
///
/// None of the three is the only way: every gesture has a labelled button
/// beside it (close, previous, next, zoom), and each change of photo is
/// announced, so the viewer works with a screen reader or a switch.
///
/// No package for any of this: PageView, InteractiveViewer and a drag
/// recogniser are all core Flutter, and a dependency here would be one more
/// thing to keep current for gestures the framework already has.
class RPhotoViewer extends StatefulWidget {
  const RPhotoViewer({
    required this.urls,
    required this.initialIndex,
    this.title,
    this.captions,
    this.actionsBuilder,
    this.prefetchNeighbours = true,
    super.key,
  });

  /// One entry per photo. A null or empty entry renders the same quiet
  /// placeholder the grid uses rather than a broken-image icon: a signed URL
  /// that has expired is an ordinary event, not the photographer's fault.
  final List<String?> urls;

  final int initialIndex;

  /// Shown above the counter. The gallery's own name, usually.
  final String? title;

  /// One line under each photo - the niche it was taken in, on a profile.
  /// Aligned with [urls]; a null entry, or no list at all, shows nothing.
  final List<String?>? captions;

  /// Lets a caller put controls over the photo - selection, in the client
  /// galleries - without this widget knowing what they mean.
  final Widget Function(BuildContext context, int index)? actionsBuilder;

  /// Decode the next and previous photo ahead of the swipe.
  ///
  /// Right for previews, wrong for full-size originals: a 4288px frame
  /// decodes to roughly 48MB, so holding three of them is ~145MB and an
  /// older device kills the app. Callers showing originals turn this off and
  /// accept a brief spinner on the photo the person actually asked for.
  final bool prefetchNeighbours;

  @override
  State<RPhotoViewer> createState() => _RPhotoViewerState();
}

class _RPhotoViewerState extends State<RPhotoViewer> {
  late final PageController _pages = PageController(initialPage: widget.initialIndex);
  final TransformationController _transform = TransformationController();

  late int _index = widget.initialIndex;
  bool _zoomed = false;
  double _dragOffset = 0;
  bool _chromeVisible = true;

  /// Where a double-tap started, so the zoom lands on what was tapped rather
  /// than always on the middle of the frame.
  TapDownDetails? _doubleTapAt;

  static const double _doubleTapScale = 2.5;
  static const double _dismissAt = 120;

  @override
  void initState() {
    super.initState();
    _transform.addListener(_onTransform);
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefetchNeighbours());
  }

  @override
  void dispose() {
    // Nothing decoded here outlives the viewer.
    for (final url in widget.urls) {
      _release(url);
    }
    _transform.removeListener(_onTransform);
    _transform.dispose();
    _pages.dispose();
    super.dispose();
  }

  void _onTransform() {
    final zoomed = _transform.value.getMaxScaleOnAxis() > 1.01;
    if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
  }

  /// Decode the neighbours so a swipe shows a photo rather than a spinner.
  ///
  /// Only ±1. A decoded frame costs width x height x 4 bytes, so at the 1600px
  /// previews the backend now produces that is roughly 11MB each and ~33MB for
  /// three - fine. It was the reason to cap the preview size: at the 4288px
  /// originals previews used to be, the same three frames came to ~145MB and
  /// would be killed on an older phone.
  void _prefetchNeighbours() {
    if (!widget.prefetchNeighbours) return;
    for (final neighbour in [_index - 1, _index + 1]) {
      if (neighbour < 0 || neighbour >= widget.urls.length) continue;
      final url = widget.urls[neighbour];
      if (url == null || url.isEmpty) continue;
      precacheImage(DiskCachedImage(url), context, onError: (_, _) {});
    }
  }

  /// Let go of every photo more than one away. The page view already drops
  /// their widgets, but the decoded frames stay in the image cache until it
  /// fills, and a long portfolio would hold dozens of them.
  void _releaseDistant() {
    for (var i = 0; i < widget.urls.length; i++) {
      if ((i - _index).abs() > 1) _release(widget.urls[i]);
    }
  }

  void _release(String? url) {
    if (url == null || url.isEmpty) return;
    PaintingBinding.instance.imageCache.evict(DiskCachedImage(url));
  }

  String? _captionAt(int index) {
    final captions = widget.captions;
    if (captions == null || index >= captions.length) return null;
    final caption = captions[index];
    return (caption == null || caption.isEmpty) ? null : caption;
  }

  void _onPageChanged(int index) {
    setState(() {
      _index = index;
      // A new photo always opens unzoomed; carrying the previous photo's
      // transform over lands the next one off-centre and half cropped.
      _transform.value = Matrix4.identity();
    });
    _releaseDistant();
    _prefetchNeighbours();
    final caption = _captionAt(index);
    SemanticsService.sendAnnouncement(
      View.of(context),
      'Photo ${index + 1} of ${widget.urls.length}${caption == null ? '' : ', $caption'}',
      Directionality.of(context),
    );
  }

  /// The buttons' way to page: the same move a swipe makes, without the
  /// slide under reduced motion.
  void _goTo(int index) {
    if (index < 0 || index >= widget.urls.length) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(index);
    } else {
      _pages.animateToPage(index, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
    }
  }

  /// The button's zoom: like a double-tap on the middle of the photo.
  void _toggleZoomFromButton() {
    final size = MediaQuery.sizeOf(context);
    _doubleTapAt = TapDownDetails(localPosition: Offset(size.width / 2, size.height / 2));
    _toggleZoom();
  }

  void _toggleZoom() {
    if (_zoomed) {
      _transform.value = Matrix4.identity();
      return;
    }
    final position = _doubleTapAt?.localPosition;
    if (position == null) return;
    // Scale about the tapped point: translate it to the origin, scale, and
    // translate back.
    _transform.value = Matrix4.identity()
      ..translateByDouble(
        -position.dx * (_doubleTapScale - 1),
        -position.dy * (_doubleTapScale - 1),
        0,
        1,
      )
      ..scaleByDouble(_doubleTapScale, _doubleTapScale, _doubleTapScale, 1);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_zoomed) return;
    setState(() => _dragOffset += details.delta.dy);
  }

  void _onDragEnd(DragEndDetails details) {
    if (_zoomed) return;
    if (_dragOffset.abs() > _dismissAt) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _dragOffset = 0);
  }

  @override
  Widget build(BuildContext context) {
    // The ground fades out as the photo is dragged away, so the gesture reads
    // as lifting the photo off rather than sliding a page.
    final progress = (_dragOffset.abs() / (_dismissAt * 2)).clamp(0.0, 1.0);
    // With a screen reader the controls are the way around, so a tap never
    // hides them.
    final chromeVisible = _chromeVisible || MediaQuery.accessibleNavigationOf(context);
    final caption = _captionAt(_index);

    return Scaffold(
      backgroundColor: RInk.i900.withValues(alpha: 1 - progress * 0.6),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => setState(() => _chromeVisible = !_chromeVisible),
            onVerticalDragUpdate: _onDragUpdate,
            onVerticalDragEnd: _onDragEnd,
            onDoubleTapDown: (details) => _doubleTapAt = details,
            onDoubleTap: _toggleZoom,
            child: Transform.translate(
              offset: Offset(0, _dragOffset),
              child: PageView.builder(
                controller: _pages,
                onPageChanged: _onPageChanged,
                // While zoomed, a horizontal drag pans the photo instead of
                // paging away from it.
                physics: _zoomed ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
                itemCount: widget.urls.length,
                itemBuilder: (context, index) => InteractiveViewer(
                  // One controller, driving whichever page is showing: only
                  // one is interactive at a time, and it is reset on change.
                  transformationController: index == _index ? _transform : null,
                  minScale: 1,
                  maxScale: 4,
                  child: Center(child: _Photo(url: widget.urls[index])),
                ),
              ),
            ),
          ),
          if (chromeVisible) ...[
            _Chrome(
              title: widget.title,
              index: _index,
              total: widget.urls.length,
              zoomed: _zoomed,
              onClose: () => Navigator.of(context).maybePop(),
              onZoom: _toggleZoomFromButton,
            ),
            if (_index > 0 && !_zoomed)
              _PageButton(
                alignment: Alignment.centerLeft,
                icon: Icons.chevron_left,
                tooltip: 'Previous photo',
                onPressed: () => _goTo(_index - 1),
              ),
            if (_index < widget.urls.length - 1 && !_zoomed)
              _PageButton(
                alignment: Alignment.centerRight,
                icon: Icons.chevron_right,
                tooltip: 'Next photo',
                onPressed: () => _goTo(_index + 1),
              ),
            if (caption != null || widget.actionsBuilder != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(RSpace.s16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (caption != null)
                          Text(
                            caption,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: RInk.i050),
                          ),
                        if (caption != null && widget.actionsBuilder != null) const SizedBox(height: RSpace.s8),
                        if (widget.actionsBuilder != null) widget.actionsBuilder!(context, _index),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final source = url;
    if (source == null || source.isEmpty) return const _ViewerFallback();
    return Image(
      image: DiskCachedImage(source),
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: RSpace.s24,
            height: RSpace.s24,
            child: CircularProgressIndicator(strokeWidth: 2, color: RInk.i050),
          ),
        );
      },
      errorBuilder: (context, error, stack) => const _ViewerFallback(),
    );
  }
}

/// Matches RNetworkPhoto's stance: an expired signed URL is ordinary, so this
/// says "no photo" quietly rather than showing a broken-image icon.
class _ViewerFallback extends StatelessWidget {
  const _ViewerFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.photo_camera_outlined, size: RSpace.s32, color: RInk.i500),
    );
  }
}

/// Previous or next, at the edge of the photo, for anyone who cannot swipe.
class _PageButton extends StatelessWidget {
  const _PageButton({required this.alignment, required this.icon, required this.tooltip, required this.onPressed});

  final Alignment alignment;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SafeArea(
        child: Align(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: RSpace.s4),
            child: _ChromeButton(icon: icon, tooltip: tooltip, onPressed: onPressed),
          ),
        ),
      ),
    );
  }
}

/// A control over a photo: a large target on a dark disc, so it reads on a
/// white sky as well as on a night shot.
class _ChromeButton extends StatelessWidget {
  /// Above the 48px minimum: these sit over a photo, often reached one-handed
  /// with the phone held up to look.
  static const double target = RSpace.s48 + RSpace.s8;

  const _ChromeButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      // Labelled on the icon too: a tooltip alone is not read as the
      // button's name by every screen reader.
      icon: Icon(icon, semanticLabel: tooltip),
      tooltip: tooltip,
      color: RInk.i050,
      constraints: const BoxConstraints(minWidth: target, minHeight: target),
      style: IconButton.styleFrom(backgroundColor: RInk.i900.withValues(alpha: 0.45)),
    );
  }
}

class _Chrome extends StatelessWidget {
  const _Chrome({
    required this.title,
    required this.index,
    required this.total,
    required this.zoomed,
    required this.onClose,
    required this.onZoom,
  });

  final String? title;
  final int index;
  final int total;
  final bool zoomed;
  final VoidCallback onClose;
  final VoidCallback onZoom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: RSpace.s8, vertical: RSpace.s8),
          child: Row(
            children: [
              _ChromeButton(icon: Icons.close, tooltip: 'Close photo viewer', onPressed: onClose),
              const SizedBox(width: RSpace.s8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: theme.textTheme.titleSmall?.copyWith(color: RInk.i050),
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      '${index + 1} of $total',
                      style: theme.textTheme.bodySmall?.copyWith(color: RInk.i200),
                    ),
                  ],
                ),
              ),
              _ChromeButton(
                icon: zoomed ? Icons.zoom_out : Icons.zoom_in,
                tooltip: zoomed ? 'Zoom out' : 'Zoom in',
                onPressed: onZoom,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens [RPhotoViewer] over the current screen.
///
/// The transition is skipped entirely under the OS reduced-motion setting,
/// matching RSkeleton, which holds a static tone rather than shimmering.
Future<void> showRPhotoViewer(
  BuildContext context, {
  required List<String?> urls,
  required int initialIndex,
  String? title,
  List<String?>? captions,
  Widget Function(BuildContext context, int index)? actionsBuilder,
  bool prefetchNeighbours = true,
}) {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return Navigator.of(context).push<void>(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: RInk.i900,
      transitionDuration: reduceMotion ? Duration.zero : const Duration(milliseconds: 180),
      reverseTransitionDuration: reduceMotion ? Duration.zero : const Duration(milliseconds: 140),
      pageBuilder: (context, animation, secondary) => RPhotoViewer(
        urls: urls,
        initialIndex: initialIndex,
        title: title,
        captions: captions,
        actionsBuilder: actionsBuilder,
        prefetchNeighbours: prefetchNeighbours,
      ),
      transitionsBuilder: (context, animation, secondary, child) {
        if (reduceMotion) return child;
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}
