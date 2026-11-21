import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:rawwers/design/tokens.dart';

/// What plays a video once someone has tapped it. A provider so widget tests
/// can put a stand-in in its place: the platform player does not run there.
final videoSurfaceProvider = Provider<Widget Function(String url, {VoidCallback? onFailed})>(
  (ref) => (url, {onFailed}) => VideoSurface(url: url, onFailed: onFailed),
);

/// Plays one video from a URL, started by the viewer's tap (never on its
/// own, so never with sound nobody asked for). Tap to pause and play again.
/// A video that cannot load says so in plain words.
class VideoSurface extends StatefulWidget {
  const VideoSurface({required this.url, this.onFailed, super.key});

  final String url;
  final VoidCallback? onFailed;

  @override
  State<VideoSurface> createState() => _VideoSurfaceState();
}

class _VideoSurfaceState extends State<VideoSurface> {
  late final VideoPlayerController _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _controller.play();
    }).catchError((Object _) {
      if (!mounted) return;
      setState(() => _failed = true);
      widget.onFailed?.call();
    });
    _controller.addListener(_changed);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_changed);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || _controller.value.hasError) {
      return const ColoredBox(
        color: RInk.i950,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(RSpace.s16),
            child: Text("This video can't play right now.", textAlign: TextAlign.center, style: TextStyle(color: RInk.i050)),
          ),
        ),
      );
    }
    if (!_controller.value.isInitialized) {
      return const ColoredBox(color: RInk.i950, child: Center(child: CircularProgressIndicator()));
    }
    final playing = _controller.value.isPlaying;
    return GestureDetector(
      onTap: () => playing ? _controller.pause() : _controller.play(),
      child: ColoredBox(
        color: RInk.i950,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(child: AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))),
            if (!playing)
              Center(
                child: Semantics(
                  button: true,
                  label: 'Play',
                  child: Icon(Icons.play_arrow_rounded, color: RInk.i050, size: RSpace.s64),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
