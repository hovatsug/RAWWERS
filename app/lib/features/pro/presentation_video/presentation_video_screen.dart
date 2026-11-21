import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/my_presentation_video.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_dialog.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/presentation_video/presentation_video_controller.dart';
import 'package:rawwers/features/shared/meet/meet_section.dart';
import 'package:rawwers/features/shared/video/video_surface.dart';

/// "Your introduction video": one short video clients watch on your
/// profile. Every state in plain words: not available, none yet, uploading,
/// processing, ready (with a preview), failed (with what to do), and
/// replacing or deleting it.
class PresentationVideoScreen extends ConsumerWidget {
  const PresentationVideoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(presentationVideoControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Your introduction video')),
      body: switch (state) {
        AsyncData(:final value) => _Body(state: value),
        AsyncError() => RErrorState(
            message: 'Could not load your video.',
            onRetry: () => ref.invalidate(presentationVideoControllerProvider),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.state});

  final PresentationVideoScreenState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final server = state.server;
    if (!server.available) {
      return Center(
        key: const ValueKey('video-not-available'),
        child: Padding(
          padding: const EdgeInsets.all(RSpace.s24),
          child: Text(server.message ?? 'Video is not available right now.', textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
        ),
      );
    }
    final shown = server.shown;
    final pending = server.pending;
    final controller = ref.read(presentationVideoControllerProvider.notifier);

    Future<void> choose(VideoSource source) async {
      final message = await controller.pickAndUpload(source);
      if (message != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    }

    final busy = state.uploadProgress != null || state.processing;
    return ListView(
      padding: const EdgeInsets.all(RSpace.s16),
      children: [
        Text(
          'Up to ${server.maxSeconds} seconds: who you are, what you shoot, and what working with you is like. '
          'Clients see it on your profile while you are live.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: RSpace.s16),
        if (state.uploadProgress != null) _Uploading(progress: state.uploadProgress!),
        if (state.processing) const _Processing(),
        if (state.error != null) ...[
          _Problem(
            key: const ValueKey('video-upload-error'),
            message: state.error!,
            action: RButton(label: 'Try again', onPressed: controller.retryUpload),
          ),
          const SizedBox(height: RSpace.s16),
        ],
        if (pending != null && pending.status == 'failed' && state.uploadProgress == null) ...[
          _Problem(key: const ValueKey('video-failed'), message: pending.message ?? 'This video could not be processed. Try another one.'),
          const SizedBox(height: RSpace.s16),
        ],
        if (shown != null) ...[
          if (busy) Text('Clients still see your current video until the new one is ready.', style: theme.textTheme.bodySmall),
          const SizedBox(height: RSpace.s8),
          _Preview(video: shown),
          const SizedBox(height: RSpace.s16),
        ] else if (!busy && pending?.status != 'failed') ...[
          Text('No video yet.', key: const ValueKey('video-none'), style: theme.textTheme.titleMedium),
          const SizedBox(height: RSpace.s16),
        ],
        if (!busy) ...[
          RButton(
            label: shown == null ? 'Choose a video' : 'Replace with a video from your library',
            onPressed: () => choose(VideoSource.library),
          ),
          const SizedBox(height: RSpace.s8),
          RButton(
            label: shown == null ? 'Record a video' : 'Record a new video',
            variant: RButtonVariant.secondary,
            onPressed: () => choose(VideoSource.camera),
          ),
        ],
        if (shown != null && !busy) ...[
          const SizedBox(height: RSpace.s8),
          RButton(
            label: 'Delete video',
            variant: RButtonVariant.secondary,
            onPressed: () async {
              final confirmed = await showRConfirmDialog(
                context,
                title: 'Delete your video?',
                message: 'Clients will no longer see it on your profile. You can add a new one at any time.',
                confirmLabel: 'Delete',
              );
              if (!confirmed) return;
              final message = await controller.delete(shown.mediaAssetId);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message ?? 'Video deleted.')));
              }
            },
          ),
        ],
      ],
    );
  }
}

class _Uploading extends StatelessWidget {
  const _Uploading({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).clamp(0, 100).round();
    return RCard(
      key: const ValueKey('video-uploading'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Uploading… $percent%', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: RSpace.s8),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: RSpace.s8),
          const Text('Keep the app open until it finishes.'),
        ],
      ),
    );
  }
}

class _Processing extends StatelessWidget {
  const _Processing();

  @override
  Widget build(BuildContext context) {
    return RCard(
      key: const ValueKey('video-processing'),
      child: Row(
        children: [
          const SizedBox(width: RSpace.s24, height: RSpace.s24, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: RSpace.s12),
          Expanded(child: Text('Processing your video. This usually takes a minute or two.', style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _Problem extends StatelessWidget {
  const _Problem({required this.message, this.action, super.key});

  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          if (action != null) ...[const SizedBox(height: RSpace.s12), action!],
        ],
      ),
    );
  }
}

/// The ready video: its poster until tapped, then it plays.
class _Preview extends ConsumerStatefulWidget {
  const _Preview({required this.video});

  final MyPresentationVideo video;

  @override
  ConsumerState<_Preview> createState() => _PreviewState();
}

class _PreviewState extends ConsumerState<_Preview> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    final url = widget.video.playbackUrl;
    final seconds = widget.video.durationSeconds;
    return Column(
      key: const ValueKey('video-ready'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 4 / 5,
          child: _playing && url != null
              ? ref.read(videoSurfaceProvider)(url)
              : GestureDetector(
                  key: const ValueKey('video-play'),
                  onTap: url == null ? null : () => setState(() => _playing = true),
                  child: Semantics(
                    button: true,
                    label: 'Play your video',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        RNetworkPhoto(url: widget.video.posterUrl),
                        const Center(child: VideoPlayBadge(size: RSpace.s64)),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: RSpace.s8),
        Text(seconds == null ? 'Clients see this video.' : 'Clients see this video ($seconds seconds).'),
      ],
    );
  }
}
