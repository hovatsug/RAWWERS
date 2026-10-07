import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/gallery_detail_response.dart';
import 'package:rawwers/api/models/gig_response.dart';
import 'package:rawwers/api/models/proof_gallery_status.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/components/r_dialog.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/design/components/r_overlay_badge.dart';
import 'package:rawwers/design/components/r_photo_viewer.dart';
import 'package:rawwers/design/components/r_progress.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/delivery/delivery_gallery_controller.dart';

/// Delivering a shoot.
///
/// Publishing is the moment the client is told their photos are ready, so
/// it is a deliberate action with its own confirmation - never a side
/// effect of finishing an upload.
class DeliveryGalleryScreen extends ConsumerWidget {
  const DeliveryGalleryScreen({required this.gig, super.key});

  final GigResponse gig;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gallery = ref.watch(deliveryGalleryControllerProvider(gig));
    final uploads = ref.watch(deliveryUploadControllerProvider(gig));

    return Scaffold(
      appBar: AppBar(title: const Text('Deliver photos')),
      floatingActionButton: FloatingActionButton.extended(
        // Each photo now tracks and shows its own fate in the list below,
        // uploading, processing or failed - there is no longer one outcome
        // for the whole batch to report here.
        onPressed: () => ref.read(deliveryUploadControllerProvider(gig).notifier).pickAndUpload(),
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Add photos'),
      ),
      body: SafeArea(
        child: switch (gallery) {
          AsyncData(:final value) => RefreshIndicator(
              onRefresh: () => ref.read(deliveryGalleryControllerProvider(gig).notifier).refresh(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _Status(detail: value, gig: gig)),
                  if (uploads.isNotEmpty) SliverToBoxAdapter(child: _Uploads(gig: gig, uploads: uploads)),
                  if (value.items.isEmpty)
                    const SliverToBoxAdapter(child: _EmptyGallery())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(RSpace.s16, 0, RSpace.s16, RSpace.s64),
                      sliver: SliverGrid.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: RSpace.s8,
                          crossAxisSpacing: RSpace.s8,
                        ),
                        itemCount: value.items.length,
                        itemBuilder: (context, index) => GestureDetector(
                          // The grid shows 512px thumbnails; opening one shows
                          // the watermarked preview, which is what a
                          // photographer needs to check focus before they
                          // publish. Falls back to the thumbnail so a photo
                          // still opens while its preview is being generated.
                          onTap: () => showRPhotoViewer(
                            context,
                            title: 'Deliver photos',
                            initialIndex: index,
                            urls: [
                              for (final item in value.items) item.watermarkPreviewUrl ?? item.thumbnailUrl,
                            ],
                          ),
                          child: RNetworkPhoto(
                            url: value.items[index].thumbnailUrl ?? value.items[index].watermarkPreviewUrl,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          AsyncError() => RErrorState(
              message: 'Could not open the gallery for this shoot.',
              onRetry: () => ref.invalidate(deliveryGalleryControllerProvider(gig)),
            ),
          _ => const Padding(
              padding: EdgeInsets.all(RSpace.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [RSkeleton(width: 220), SizedBox(height: RSpace.s16), RSkeleton(width: 180)],
              ),
            ),
        },
      ),
    );
  }
}

class _Status extends ConsumerWidget {
  const _Status({required this.detail, required this.gig});

  final GalleryDetailResponse detail;
  final GigResponse gig;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gallery = detail.gallery;
    final count = detail.items.length;
    final included = gallery.includedPhotos;
    final (label, kind) = _statusChip(gallery.status);

    return Padding(
      padding: const EdgeInsets.all(RSpace.s16),
      child: RCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(_headline(gallery.status), style: theme.textTheme.titleSmall)),
                RStatusChip(label: label, kind: kind),
              ],
            ),
            const SizedBox(height: RSpace.s8),
            Text(_explanation(gallery.status, count, included), style: theme.textTheme.bodySmall),
            if (gallery.status == ProofGalleryStatus.draft) ...[
              const SizedBox(height: RSpace.s16),
              RButton(
                label: 'Send to client',
                // Nothing to send is not an error state worth a message -
                // the button simply is not available yet.
                onPressed: count == 0 ? null : () => _publish(context, ref),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _headline(ProofGalleryStatus status) => switch (status) {
        ProofGalleryStatus.draft => 'Not sent yet',
        ProofGalleryStatus.published => 'Sent to your client',
        ProofGalleryStatus.selectionSubmitted => 'Your client has chosen',
        ProofGalleryStatus.delivered => 'Delivered',
      };

  String _explanation(ProofGalleryStatus status, int count, int included) => switch (status) {
        ProofGalleryStatus.draft =>
          'Only you can see these $count. They stay private until you send them.',
        ProofGalleryStatus.published =>
          'Your client is choosing their $included from these $count.',
        ProofGalleryStatus.selectionSubmitted =>
          'They have picked. Edit and deliver the finals next.',
        ProofGalleryStatus.delivered => 'This shoot is finished.',
      };

  (String, RStatusChipKind) _statusChip(ProofGalleryStatus status) => switch (status) {
        ProofGalleryStatus.draft => ('Draft', RStatusChipKind.inProgress),
        ProofGalleryStatus.published => ('Sent', RStatusChipKind.positive),
        ProofGalleryStatus.selectionSubmitted => ('Chosen', RStatusChipKind.positive),
        ProofGalleryStatus.delivered => ('Delivered', RStatusChipKind.positive),
      };

  Future<void> _publish(BuildContext context, WidgetRef ref) async {
    final count = detail.items.length;
    final confirmed = await showRConfirmDialog(
      context,
      title: 'Send these to your client?',
      // Publishing notifies them, and there is no unsend - worth saying
      // before the tap rather than after.
      message: 'They will be told their photos are ready and can start '
          'choosing from all $count. You cannot unsend this.',
      confirmLabel: 'Send',
    );
    if (!confirmed || !context.mounted) return;

    final error = await ref.read(deliveryGalleryControllerProvider(gig).notifier).publish();
    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

class _Uploads extends ConsumerWidget {
  const _Uploads({required this.gig, required this.uploads});

  final GigResponse gig;
  final Map<String, DeliveryUploadItem> uploads;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.read(deliveryUploadControllerProvider(gig).notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(RSpace.s16, 0, RSpace.s16, RSpace.s16),
      child: RCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in uploads.entries) ...[
              Row(
                children: [
                  if (entry.value.localPath case final path?) ...[
                    // The photo itself, from the phone, the moment it is
                    // picked - not a filename while the server works. Decoded
                    // at thumbnail size so a batch of camera files does not
                    // hold full-resolution bitmaps in memory.
                    ClipRRect(
                      borderRadius: BorderRadius.circular(RRadius.photo),
                      child: Image.file(
                        File(path),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        cacheWidth: 120,
                        errorBuilder: (_, _, _) => const SizedBox(width: 40, height: 40),
                      ),
                    ),
                    const SizedBox(width: RSpace.s8),
                  ],
                  Expanded(child: Text(entry.value.fileName, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
                  switch (entry.value) {
                    DeliveryUploadFailed(:final mediaAssetId) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Only a photo whose upload already succeeded has
                          // anything to retry - a raw upload failure needs
                          // the file re-picked, which this screen cannot do
                          // on its own.
                          if (mediaAssetId != null)
                            TextButton(
                              onPressed: () => notifier.retryAttach(entry.key),
                              child: const Text('Retry'),
                            ),
                          IconButton(
                            onPressed: () => notifier.dismiss(entry.key),
                            icon: const Icon(Icons.close),
                            tooltip: 'Dismiss',
                          ),
                        ],
                      ),
                    _ => const SizedBox.shrink(),
                  },
                ],
              ),
              switch (entry.value) {
                DeliveryUploadUploading(:final fraction) => RProgressBar(value: fraction),
                // Not an error state and not styled like one: the photo is
                // uploaded and this is the server doing real, expected work
                // before it can appear below - the same "Processing" a
                // portfolio tile shows while its own preview is generating.
                DeliveryUploadProcessing() => const Align(
                    alignment: Alignment.centerLeft,
                    child: ROverlayBadge(label: 'Processing'),
                  ),
                DeliveryUploadFailed(:final message) =>
                  Text(message, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
              },
              const SizedBox(height: RSpace.s8),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(RSpace.s32),
      child: Column(
        children: [
          Icon(Icons.collections_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: RSpace.s16),
          Text('No proofs yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: RSpace.s8),
          Text(
            'Add the frames you want your client to choose from. They stay '
            'private until you send them.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
