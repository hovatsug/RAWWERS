import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/download/photo_saver.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_image_tile.dart';
import 'package:rawwers/design/components/r_photo_viewer.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/gallery/delivered_controller.dart';

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
/// Saving is one photo at a time, from full screen only. The grid's tiles are
/// small enough that a save icon on each would be a mis-tap waiting to happen
/// next to the tap that opens the photo.
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
          AsyncData(:final value) => RefreshIndicator(
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
                    image: NetworkImage(photo.item.thumbnailUrl ?? photo.finalUrl),
                    onTap: () => _openViewer(context, ref, index),
                  );
                },
              ),
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
