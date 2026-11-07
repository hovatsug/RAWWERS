import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/core/format/dates.dart';
import 'package:rawwers/core/images/disk_cached_image.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_image_tile.dart';
import 'package:rawwers/design/components/r_photo_viewer.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/gallery/addon_controller.dart';
import 'package:rawwers/features/client/gallery/addon_window.dart';

/// The gallery after the selection closed. While the add-on window is open
/// the photos not yet chosen can be added; the chosen ones are greyed with a
/// "Chosen" badge and cannot be picked or removed. After it ends the gallery
/// is read-only. Every photo still opens full size.
class AddonGallery extends ConsumerWidget {
  const AddonGallery({required this.galleryId, required this.bookingId, super.key});

  final String galleryId;
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addonControllerProvider(galleryId));
    return switch (state) {
      AsyncData(:final value) => Column(
          children: [
            _Banner(state: value),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(RSpace.s16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: RSpace.s8,
                  crossAxisSpacing: RSpace.s8,
                ),
                itemCount: value.gallery.items.length,
                itemBuilder: (context, index) {
                  final item = value.gallery.items[index];
                  final id = item.mediaAssetId;
                  final chosen = value.isChosen(id);
                  final picked = value.isPicked(id);
                  final pickable = value.open && !chosen && !value.busy;
                  return RImageTile(
                    image: DiskCachedImage(item.thumbnailUrl ?? item.watermarkPreviewUrl ?? ''),
                    selected: picked,
                    selectable: pickable,
                    lockedLabel: chosen ? 'Chosen' : null,
                    semanticLabel: 'Photo ${index + 1}, ${chosen ? 'chosen' : (picked ? 'added' : 'not chosen')}',
                    onTap: pickable ? () => ref.read(addonControllerProvider(galleryId).notifier).toggle(id) : null,
                    onExpand: () => showRPhotoViewer(
                      context,
                      title: 'Your photos',
                      initialIndex: index,
                      urls: [for (final i in value.gallery.items) i.watermarkPreviewUrl ?? i.thumbnailUrl],
                    ),
                  );
                },
              ),
            ),
            if (value.open) _AddBar(galleryId: galleryId, bookingId: bookingId),
          ],
        ),
      AsyncError() => RErrorState(
          message: 'Could not open your gallery.',
          onRetry: () => ref.invalidate(addonControllerProvider(galleryId)),
        ),
      _ => const Padding(padding: EdgeInsets.all(RSpace.s16), child: RSkeleton(height: 120)),
    };
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.state});

  final AddonState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ends = state.gallery.addonWindowEndsAt;
    if (ends == null) return const SizedBox.shrink();
    final open = state.open && addonTimeLeft(ends) != null;
    return Container(
      width: double.infinity,
      color: open ? theme.colorScheme.secondaryContainer : theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: RSpace.s16, vertical: RSpace.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(open ? addonBanner(ends) : 'Gallery closed', style: theme.textTheme.titleSmall),
          const SizedBox(height: RSpace.s4),
          Text(
            open
                ? 'Tap photos you did not choose to add them. Until ${RDates.of(context).dateTime(ends)}.'
                : 'Closed on ${RDates.of(context).date(ends)}. Your chosen photos stay yours.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _AddBar extends ConsumerWidget {
  const _AddBar({required this.galleryId, required this.bookingId});

  final String galleryId;
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final value = ref.watch(addonControllerProvider(galleryId)).valueOrNull;
    if (value == null) return const SizedBox.shrink();
    final count = value.picked.length;
    final quote = value.quote;
    final price = quote == null ? null : '${quote.currency} ${quote.amount}';

    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(RSpace.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                count == 0
                    ? '${value.unchosen} more ${value.unchosen == 1 ? 'photo' : 'photos'} you can add'
                    : (value.quoting || price == null ? '$count to add' : '$count to add · $price'),
                style: theme.textTheme.titleMedium,
              ),
              if (value.error != null) ...[
                const SizedBox(height: RSpace.s8),
                Text(value.error!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: RSpace.s12),
              RButton(
                label: count == 0 || price == null ? 'Add photos' : 'Add $count for $price',
                loading: value.busy,
                onPressed: value.canConfirm ? () => _confirm(context, ref, count, price!) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref, int count, String price) async {
    final agreed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add ${count == 1 ? '1 photo' : '$count photos'}?'),
        content: Text('You will be charged $price. They are yours to download once paid.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Not yet')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text('Pay $price')),
        ],
      ),
    );
    if (agreed != true) return;
    final outcome = await ref.read(addonControllerProvider(galleryId).notifier).confirm(bookingId: bookingId);
    if (!context.mounted || outcome != AddonOutcome.added) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added. They appear in your photos as soon as the payment clears.')),
    );
  }
}
