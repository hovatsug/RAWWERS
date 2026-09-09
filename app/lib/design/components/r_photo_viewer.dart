import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

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
/// No package for any of this: PageView, InteractiveViewer and a drag
/// recogniser are all core Flutter, and a dependency here would be one more
/// thing to keep current for gestures the framework already has.
class RPhotoViewer extends StatefulWidget {
  const RPhotoViewer({
    required this.urls,
    required this.initialIndex,
    this.title,
    this.actionsBuilder,
    super.key,
  });

  /// One entry per photo. A null or empty entry renders the same quiet
  /// placeholder the grid uses rather than a broken-image icon: a signed URL
  /// that has expired is an ordinary event, not the photographer's fault.
  final List<String?> urls;

  final int initialIndex;

  /// Shown above the counter. The gallery's own name, usually.
  final String? title;

  /// Lets a caller put controls over the photo - selection, in the client
  /// galleries - without this widget knowing what they mean.
  final Widget Function(BuildContext context, int index)? actionsBuilder;

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
    for (final neighbour in [_index - 1, _index + 1]) {
      if (neighbour < 0 || neighbour >= widget.urls.length) continue;
      final url = widget.urls[neighbour];
      if (url == null || url.isEmpty) continue;
      precacheImage(NetworkImage(url), context, onError: (_, _) {});
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _index = index;
      // A new photo always opens unzoomed; carrying the previous photo's
      // transform over lands the next one off-centre and half cropped.
      _transform.value = Matrix4.identity();
    });
    _prefetchNeighbours();
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
          if (_chromeVisible) ...[
            _Chrome(
              title: widget.title,
              index: _index,
              total: widget.urls.length,
              onClose: () => Navigator.of(context).maybePop(),
            ),
            if (widget.actionsBuilder != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(RSpace.s16),
                    child: widget.actionsBuilder!(context, _index),
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
    return Image.network(
      source,
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

class _Chrome extends StatelessWidget {
  const _Chrome({
    required this.title,
    required this.index,
    required this.total,
    required this.onClose,
  });

  final String? title;
  final int index;
  final int total;
  final VoidCallback onClose;

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
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
                color: RInk.i050,
                tooltip: 'Close',
              ),
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
  Widget Function(BuildContext context, int index)? actionsBuilder,
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
        actionsBuilder: actionsBuilder,
      ),
      transitionsBuilder: (context, animation, secondary, child) {
        if (reduceMotion) return child;
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}
