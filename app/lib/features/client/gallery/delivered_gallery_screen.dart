import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/download/photo_saver.dart';
import 'package:rawwers/core/download/save_all_run.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_image_tile.dart';
import 'package:rawwers/design/components/r_photo_viewer.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/gallery/delivered_controller.dart';
import 'package:rawwers/features/client/gallery/save_all_controller.dart';
import 'package:rawwers/core/images/disk_cached_image.dart';

/// The photographs a client has paid for.
///
/// Two things separate this from the selection gallery, and both matter:
///
///   - It shows only what the server unlocked. The gallery listing holds
///     everything the photographer uploaded, and the unchosen ones are not
///     this client's to look at here.
///   - Full screen shows the *original*, not the watermarked preview. These
///     are bought and paid for; a watermark on them would be absurd. The
///     listing only carries a thumbnail and a watermarked preview, so the
///     real files come from the downloads endpoint.
///
/// Saving is from full screen, one photo, or from the bar under the grid,
/// all of them. The grid's tiles are small enough that a save icon on each
/// would be a mis-tap waiting to happen next to the tap that opens the photo.
class DeliveredGalleryScreen extends ConsumerWidget {
  const DeliveredGalleryScreen({required this.galleryId, super.key});

  final String galleryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deliveredControllerProvider(galleryId));

    return Scaffold(
      appBar: AppBar(title: const Text('Your photos')),
      body: SafeArea(
        child: switch (state) {
          AsyncData(:final value) when value.isEmpty => const REmptyState(
              title: 'Nothing here yet',
              body: 'Once your selection is complete and paid for, your photos appear here.',
              icon: Icons.photo_library_outlined,
            ),
          AsyncData(:final value) => Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => ref.invalidate(deliveredControllerProvider(galleryId)),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(RSpace.s16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: RSpace.s8,
                        crossAxisSpacing: RSpace.s8,
                      ),
                      itemCount: value.photos.length,
                      itemBuilder: (context, index) {
                        final photo = value.photos[index];
                        return RImageTile(
                          // The grid stays on thumbnails: a wall of originals would
                          // decode hundreds of megabytes to show 100px squares.
                          image: DiskCachedImage(photo.item.thumbnailUrl ?? photo.finalUrl),
                          onTap: () => _openViewer(context, ref, index),
                        );
                      },
                    ),
                  ),
                ),
                // Shown only with photos in the grid, and the grid holds only
                // what the downloads endpoint released: the same rule decides
                // both, and it is the server's.
                SaveAllBar(galleryId: galleryId, assetIds: [for (final photo in value.photos) photo.assetId]),
              ],
            ),
          AsyncError() => RErrorState(
              message: 'Could not open your photos.',
              onRetry: () => ref.invalidate(deliveredControllerProvider(galleryId)),
            ),
          _ => const Padding(
              padding: EdgeInsets.all(RSpace.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [RSkeleton(height: 120), SizedBox(height: RSpace.s12), RSkeleton(height: 120)],
              ),
            ),
        },
      ),
    );
  }

  void _openViewer(BuildContext context, WidgetRef ref, int index) {
    final value = ref.read(deliveredControllerProvider(galleryId)).valueOrNull;
    if (value == null) return;

    showRPhotoViewer(
      context,
      title: 'Your photos',
      initialIndex: index,
      urls: [for (final photo in value.photos) photo.finalUrl],
      // Originals, so no read-ahead: a 4288px frame decodes to roughly 48MB
      // and holding three would be enough to get the app killed on an older
      // device. A brief spinner on the photo someone actually asked for is
      // the better trade.
      prefetchNeighbours: false,
      // Keyed per photo: swiping mid-save must not show one photo's progress
      // under the next.
      actionsBuilder: (viewerContext, current) => Align(
        alignment: Alignment.centerLeft,
        child: SavePhotoButton(
          key: ValueKey(value.photos[current].assetId),
          galleryId: galleryId,
          assetId: value.photos[current].assetId,
        ),
      ),
    );
  }
}

/// Saves one delivered photo to the device, showing how far along it is.
class SavePhotoButton extends ConsumerStatefulWidget {
  const SavePhotoButton({required this.galleryId, required this.assetId, super.key});

  final String galleryId;
  final String assetId;

  @override
  ConsumerState<SavePhotoButton> createState() => _SavePhotoButtonState();
}

class _SavePhotoButtonState extends ConsumerState<SavePhotoButton> {
  bool _saving = false;
  double? _progress;

  Future<void> _save() async {
    // Captured now: the button can be gone by the time the save finishes -
    // swiped past, or hidden with the chrome - and the result still has to
    // reach the person.
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _saving = true;
      _progress = null;
    });

    // A fresh link, not the one from page load: it may have expired while
    // they browsed.
    final url = await ref
        .read(deliveredControllerProvider(widget.galleryId).notifier)
        .freshLinkFor(widget.assetId);

    final outcome = url == null
        ? const SaveFailed(SaveFailure.linkUnavailable)
        : await ref.read(photoSaverProvider).save(
              url,
              name: 'RAWWERS-${widget.assetId}',
              onProgress: (fraction) {
                if (mounted) setState(() => _progress = fraction);
              },
            );

    // Remembered, so "save all" does not download it a second time.
    if (outcome is Saved) await ref.read(savedPhotosProvider).markSaved(widget.galleryId, widget.assetId);

    if (mounted) setState(() => _saving = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (outcome) {
          Saved() => 'Saved to your photos.',
          SaveFailed(:final reason) => reason.message,
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress;
    return ConstrainedBox(
      // RButton takes an infinite minimum width from the theme; see the
      // selection gallery's viewer.
      constraints: const BoxConstraints(maxWidth: 200),
      child: RButton(
        label: switch ((_saving, progress)) {
          (false, _) => 'Save to Photos',
          (true, null) => 'Saving…',
          (true, final p?) => 'Saving… ${(p * 100).round()}%',
        },
        onPressed: _saving ? null : _save,
      ),
    );
  }
}

/// "Save all to Photos", under the grid: the button, then how far it has got,
/// then what happened.
class SaveAllBar extends ConsumerWidget {
  const SaveAllBar({required this.galleryId, required this.assetIds, super.key});

  final String galleryId;

  /// In the order the grid shows them, so "photo 7" is the seventh tile.
  final List<String> assetIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(saveAllControllerProvider(galleryId));
    final controller = ref.read(saveAllControllerProvider(galleryId).notifier);
    void start({bool includeSaved = false}) => controller.start(assetIds, includeSaved: includeSaved);

    final children = switch (state) {
      SaveAllIdle() => [RButton(label: 'Save all to Photos', onPressed: start)],
      SaveAllRunning(:final reached, :final total, :final stopping) => [
        Semantics(
          liveRegion: true,
          child: Text(
            stopping ? 'Stopping after this photo…' : 'Saving ${reached < total ? reached + 1 : total} of $total',
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: RSpace.s8),
        LinearProgressIndicator(value: total == 0 ? null : reached / total),
        const SizedBox(height: RSpace.s8),
        Text('Keep RAWWERS open until this finishes.', style: theme.textTheme.bodySmall),
        const SizedBox(height: RSpace.s12),
        RButton(label: 'Cancel', variant: RButtonVariant.secondary, onPressed: stopping ? null : controller.cancel),
      ],
      SaveAllDone(:final result) => _outcome(context, ref, result, start),
    };

    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(RSpace.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }

  List<Widget> _outcome(
    BuildContext context,
    WidgetRef ref,
    SaveAllResult result,
    void Function({bool includeSaved}) start,
  ) {
    final theme = Theme.of(context);
    final inLibrary = result.saved + result.skipped;
    Widget message(String text) => Semantics(liveRegion: true, child: Text(text, style: theme.textTheme.bodyMedium));
    final tryAgain = RButton(label: 'Try again', onPressed: start);

    return switch (result) {
      SaveAllResult(stoppedBy: SaveFailure.permissionDenied) => [
        message(SaveFailure.permissionDenied.message),
        const SizedBox(height: RSpace.s12),
        // iOS has a link to the app's own page in Settings; Android has no
        // equivalent a link can open, and only versions before 10 ask at all.
        if (defaultTargetPlatform == TargetPlatform.iOS) ...[
          RButton(label: 'Open Settings', onPressed: () => ref.read(openAppSettingsProvider)()),
          const SizedBox(height: RSpace.s8),
          RButton(label: 'Try again', variant: RButtonVariant.secondary, onPressed: start),
        ] else
          tryAgain,
      ],
      SaveAllResult(stoppedBy: SaveFailure.linkUnavailable) => [
        message("Couldn't get your photos from RAWWERS. Check your connection and try again."),
        const SizedBox(height: RSpace.s12),
        tryAgain,
      ],
      SaveAllResult(stoppedBy: SaveFailure.notEnoughSpace) => [
        message("There isn't enough space on this device. $inLibrary of ${result.total} are in your photos."),
        const SizedBox(height: RSpace.s12),
        tryAgain,
      ],
      SaveAllResult(allAlreadySaved: true) => [
        message('All ${result.total} are already in your photos.'),
        const SizedBox(height: RSpace.s12),
        // Deleting from the library is invisible to the app, so the way
        // back is offered rather than assumed.
        RButton(
          label: 'Save them again',
          variant: RButtonVariant.secondary,
          onPressed: () => start(includeSaved: true),
        ),
      ],
      SaveAllResult(cancelled: true) => [
        message('Stopped. $inLibrary of ${result.total} are in your photos.'),
        const SizedBox(height: RSpace.s12),
        RButton(label: 'Continue', onPressed: start),
      ],
      SaveAllResult(failed: final failed) when failed.isNotEmpty => [
        message(
          '$inLibrary of ${result.total} are in your photos. '
          "Couldn't save ${failed.length == 1 ? '1 photo' : '${failed.length} photos'}: ${failedList(failed)}.",
        ),
        const SizedBox(height: RSpace.s12),
        tryAgain,
      ],
      _ => [message('All ${result.total} are in your photos.')],
    };
  }
}

/// "photo 7, photo 19", and past ten "… and 14 more": a list of hundreds
/// would push the button off the screen.
@visibleForTesting
String failedList(List<int> positions) {
  const shown = 10;
  final named = positions.take(shown).map((n) => 'photo $n').join(', ');
  final rest = positions.length - shown;
  return rest > 0 ? '$named and $rest more' : named;
}
