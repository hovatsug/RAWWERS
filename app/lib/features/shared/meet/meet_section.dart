import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/meet_the_photographer_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';
import 'package:rawwers/features/shared/video/video_surface.dart';
import 'package:rawwers/api/models/presentation_video_view.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/design/tokens.dart';

/// "Meet the photographer" on a profile: their video, their own words, or
/// both - exactly as the server sends it. The photographer's preview draws
/// this same widget, so what they check is what clients read.
///
/// Nothing at all when there is nothing in it: the caller passes null and
/// gets no heading, no placeholder.
class MeetSection extends StatelessWidget {
  const MeetSection({required this.name, required this.meet, this.proUserId, super.key});

  final String name;
  final MeetThePhotographerView? meet;

  /// The photographer, for a fresh playback link when the video is tapped.
  final String? proUserId;

  @override
  Widget build(BuildContext context) {
    final view = meet;
    final interview = view?.interview ?? const [];
    final video = view?.video;
    if (view == null || (video == null && interview.isEmpty)) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Meet $name', style: theme.textTheme.titleLarge),
        const SizedBox(height: RSpace.s12),
        if (video != null) ...[
          PresentationVideoSlot(video: video, name: name, proUserId: proUserId),
          const SizedBox(height: RSpace.s16),
        ],
        for (final item in interview) ...[
          Text(item.title, style: theme.textTheme.titleSmall),
          const SizedBox(height: RSpace.s4),
          Text(item.answer, style: theme.textTheme.bodyMedium),
          const SizedBox(height: RSpace.s16),
        ],
      ],
    );
  }
}

/// A fresh signed playback link for a photographer's video (five minutes),
/// asked for when the client taps play. A provider so tests answer it.
final presentationVideoPlaybackProvider = Provider<Future<String?> Function(String proUserId)>((ref) {
  return (proUserId) async {
    final result = await apiCall(() => ref.read(presentationVideoClientProvider).playPresentationVideoV1ClientProsProUserIdPresentationVideoPlaybackPost(
          proUserId: proUserId,
          authorization: null,
          xMinusUserMinusId: null,
        ));
    return switch (result) {
      Ok(:final value) => value.playbackUrl,
      Err() => null,
    };
  };
});

/// The photographer's video: its poster and a play button until tapped (it
/// never starts by itself, so never with sound nobody asked for), then it
/// plays. A link that cannot be fetched says so, with a way to try again.
class PresentationVideoSlot extends ConsumerStatefulWidget {
  const PresentationVideoSlot({required this.video, required this.name, this.proUserId, super.key});

  final PresentationVideoView video;
  final String name;
  final String? proUserId;

  @override
  ConsumerState<PresentationVideoSlot> createState() => _PresentationVideoSlotState();
}

class _PresentationVideoSlotState extends ConsumerState<PresentationVideoSlot> {
  String? _url;
  bool _loading = false;
  bool _failed = false;

  Future<void> _play() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    final id = widget.proUserId;
    final url = id == null ? widget.video.playbackUrl : await ref.read(presentationVideoPlaybackProvider)(id);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _url = url;
      _failed = url == null || url.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final seconds = widget.video.durationSeconds;
    final url = _url;
    final Widget content;
    if (url != null && !_failed) {
      content = ref.read(videoSurfaceProvider)(url);
    } else {
      content = GestureDetector(
        onTap: _loading ? null : _play,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RNetworkPhoto(url: widget.video.posterUrl),
            Center(
              child: _loading
                  ? const CircularProgressIndicator(key: ValueKey('video-loading'))
                  : const VideoPlayBadge(size: RSpace.s64),
            ),
            if (_failed)
              Positioned(
                left: RSpace.s8,
                right: RSpace.s8,
                bottom: RSpace.s8,
                child: Container(
                  key: const ValueKey('video-failed'),
                  padding: const EdgeInsets.all(RSpace.s8),
                  color: RInk.i950.withValues(alpha: 0.7),
                  child: const Text("This video can't play right now. Tap to try again.",
                      textAlign: TextAlign.center, style: TextStyle(color: RInk.i050)),
                ),
              ),
          ],
        ),
      );
    }
    return Semantics(
      button: true,
      label: 'Video introduction by ${widget.name}${seconds == null ? '' : ', $seconds seconds'}',
      child: AspectRatio(
        // Recorded upright on a phone; shown a little shorter so the words
        // below it stay in view.
        aspectRatio: 4 / 5,
        child: content,
      ),
    );
  }
}

/// The play badge a video shows: on its poster, and on a Discover card that
/// has one.
class VideoPlayBadge extends StatelessWidget {
  const VideoPlayBadge({this.size = RSpace.s32, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('video-play-badge'),
      width: size,
      height: size,
      decoration: BoxDecoration(color: RInk.i950.withValues(alpha: 0.6), shape: BoxShape.circle),
      child: Icon(Icons.play_arrow_rounded, color: RInk.i050, size: size * 0.6),
    );
  }
}
