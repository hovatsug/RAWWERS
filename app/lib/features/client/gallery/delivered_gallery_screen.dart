import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
/// There is no save control yet, deliberately. Putting the file on someone's
/// device needs a package this project cannot currently take - every
/// share_plus 13.x pulls an interface declaring Dart >=3.10, and code
/// generation here runs through an analyzer capped at 3.9 by source_gen 2.x
/// and riverpod_generator 2.x, so adding it does not degrade the app, it
/// stops the app building. A button that cannot work is worse than no
/// button, so the seam is left open and named rather than faked.
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
    );
  }
}
