import 'package:flutter/material.dart';
import 'package:rawwers/api/models/meet_the_photographer_view.dart';
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
  const MeetSection({required this.name, required this.meet, super.key});

  final String name;
  final MeetThePhotographerView? meet;

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
          PresentationVideoSlot(video: video, name: name),
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

/// Where the presentation video goes. Laid out now - its poster, a play badge
/// and the length - so playback can be added without moving anything. The
/// server only ever sends a video once they exist and are switched on.
class PresentationVideoSlot extends StatelessWidget {
  const PresentationVideoSlot({required this.video, required this.name, super.key});

  final PresentationVideoView video;
  final String name;

  @override
  Widget build(BuildContext context) {
    final seconds = video.durationSeconds;
    return Semantics(
      label: 'Video introduction by $name${seconds == null ? '' : ', $seconds seconds'}',
      child: AspectRatio(
        // Recorded upright on a phone; shown a little shorter so the words
        // below it stay in view.
        aspectRatio: 4 / 5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            RNetworkPhoto(url: video.posterUrl),
            const Center(child: VideoPlayBadge(size: RSpace.s64)),
          ],
        ),
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
