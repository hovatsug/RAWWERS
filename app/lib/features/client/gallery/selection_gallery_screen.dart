import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/selection_quote_response.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_image_tile.dart';
import 'package:rawwers/design/components/r_photo_viewer.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/gallery/selection_controller.dart';
import 'package:rawwers/core/images/disk_cached_image.dart';

/// Choosing which photographs to keep.
///
/// This is the only screen in the product where someone is judging
/// photography and spending money in the same gesture, so two things are
/// held to a higher standard than elsewhere:
///
///   - What is ticked is one fact, shared by the grid and the full-screen
///     viewer. Neither owns a copy.
///   - Every figure comes from the server. Nothing here multiplies a price by
///     a count; the curve, the deposit already paid and the clamp at zero are
///     backend rules, and an app that approximates them eventually shows a
///     number nobody is charged.
class SelectionGalleryScreen extends ConsumerWidget {
  const SelectionGalleryScreen({required this.galleryId, required this.bookingId, super.key});

  final String galleryId;

  /// The booking this gallery belongs to. Confirming can end in a payment,
  /// and a payment is recorded against the booking, not the gallery.
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(selectionControllerProvider(galleryId));

    return Scaffold(
      appBar: AppBar(title: const Text('Choose your photos')),
      body: SafeArea(
        child: switch (state) {
          AsyncData(:final value) when value.items.isEmpty => const REmptyState(
            title: 'Nothing here yet',
            body: 'Your photographer has not published any photos for this shoot.',
            icon: Icons.photo_library_outlined,
          ),
          AsyncData(:final value) => Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(RSpace.s16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: RSpace.s8,
                    crossAxisSpacing: RSpace.s8,
                  ),
                  itemCount: value.items.length,
                  itemBuilder: (context, index) {
                    final item = value.items[index];
                    final id = item.mediaAssetId;
                    return RImageTile(
                      image: DiskCachedImage(item.thumbnailUrl ?? item.watermarkPreviewUrl ?? ''),
                      selected: value.isSelected(id),
                      onTap: value.frozen ? null : () => _openViewer(context, ref, index),
                    );
                  },
                ),
              ),
              _PriceBar(galleryId: galleryId, bookingId: bookingId),
            ],
          ),
          AsyncError() => RErrorState(
            message: 'Could not open your gallery.',
            onRetry: () => ref.invalidate(selectionControllerProvider(galleryId)),
          ),
          _ => const Padding(
            padding: EdgeInsets.all(RSpace.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RSkeleton(height: 120),
                SizedBox(height: RSpace.s12),
                RSkeleton(height: 120),
              ],
            ),
          ),
        },
      ),
    );
  }

  /// The same controller drives the viewer, so a photo ticked full screen is
  /// already ticked when the grid comes back.
  void _openViewer(BuildContext context, WidgetRef ref, int index) {
    final value = ref.read(selectionControllerProvider(galleryId)).valueOrNull;
    if (value == null) return;

    showRPhotoViewer(
      context,
      title: 'Choose your photos',
      initialIndex: index,
      urls: [for (final item in value.items) item.watermarkPreviewUrl ?? item.thumbnailUrl],
      actionsBuilder: (viewerContext, current) => Consumer(
        builder: (context, viewerRef, _) {
          final live = viewerRef.watch(selectionControllerProvider(galleryId)).valueOrNull;
          if (live == null) return const SizedBox.shrink();
          final id = live.items[current].mediaAssetId;
          final chosen = live.isSelected(id);
          return Row(
            children: [
              Expanded(child: _ViewerPrice(galleryId: galleryId)),
              const SizedBox(width: RSpace.s12),
              // RButton takes minimumSize: Size.fromHeight from the theme,
              // which is an infinite width. A Row gives a non-flex child
              // unbounded constraints, so it needs a ceiling here.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: RButton(
                  label: chosen ? 'Chosen' : 'Choose',
                  onPressed: live.frozen
                      ? null
                      : () => viewerRef.read(selectionControllerProvider(galleryId).notifier).toggle(id),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The running total, over the photo, while deciding.
class _ViewerPrice extends ConsumerWidget {
  const _ViewerPrice({required this.galleryId});

  final String galleryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(selectionControllerProvider(galleryId)).valueOrNull;
    final quote = value?.quote;
    if (value == null || quote == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${value.selectedCount} chosen', style: theme.textTheme.labelMedium?.copyWith(color: RInk.i050)),
        Text(
          _totalLabel(quote, value.quoteFailed),
          style: theme.textTheme.bodySmall?.copyWith(color: RInk.i200),
        ),
      ],
    );
  }
}

/// What is chosen, what it costs, and what one more would add.
///
/// The marginal price is the number that changes a decision, so it is stated
/// outright rather than left to be worked out from the total.
class _PriceBar extends ConsumerWidget {
  const _PriceBar({required this.galleryId, required this.bookingId});

  final String galleryId;
  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final value = ref.watch(selectionControllerProvider(galleryId)).valueOrNull;
    if (value == null) return const SizedBox.shrink();

    final quote = value.quote;
    final needed = quote?.photosStillNeeded ?? 0;
    final ready = quote?.canSubmit ?? false;
    final awaiting = value.phase is ConfirmAwaitingPayment;

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // The gate, phrased as the step left rather than as
                        // a failure: below the minimum this is the only
                        // thing the screen should be asking for.
                        awaiting
                            ? 'Your selection is locked in'
                            : (ready ? '${value.selectedCount} chosen' : '$needed more to continue'),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: RSpace.s4),
                      if (awaiting)
                        Text(
                          'Complete the payment to finish. It cannot be changed here.',
                          style: theme.textTheme.bodySmall,
                        )
                      else if (quote != null)
                        Text(
                          _totalLabel(quote, value.quoteFailed),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: value.quoteStale ? theme.colorScheme.onSurfaceVariant : null,
                          ),
                        ),
                      if (!awaiting && quote != null && quote.nextPhotoPrice != null && !value.quoteFailed)
                        Text(
                          _marginalLabel(quote),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      if (value.confirmError != null) ...[
                        const SizedBox(height: RSpace.s8),
                        Text(
                          value.confirmError!,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: RSpace.s12),
                  RButton(
                    label: _confirmLabel(value),
                    loading: value.busy,
                    onPressed: value.canConfirm ? () => _confirm(context, ref, value) : null,
                  ),
                ],
              ),
              if (value.locked) ...[
                const SizedBox(height: RSpace.s8),
                Text(
                  'This selection has been submitted. It cannot be changed here.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref, SelectionState value) async {
    final controller = ref.read(selectionControllerProvider(galleryId).notifier);

    // Already submitted, so already agreed to: retrying a payment is not a
    // second decision and does not ask again.
    if (value.phase is! ConfirmAwaitingPayment) {
      final agreed = await _askToConfirm(context, value);
      if (agreed != true) return;
    }

    final outcome = await controller.confirm(bookingId: bookingId);
    if (outcome is! ConfirmCompleted || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          outcome.paid ? 'Payment sent. This updates as soon as it clears.' : 'Your selection is confirmed.',
        ),
      ),
    );
    if (context.canPop()) context.pop();
  }

  /// The last point at which this can be undone, so it says what it commits
  /// to: how many photographs, what it costs, and that there is no going back.
  /// The figure is the server's `amount_due`, the same one on the button.
  Future<bool?> _askToConfirm(BuildContext context, SelectionState value) {
    final quote = value.quote!;
    final owed = !_nothingDue(quote);
    final count = value.selectedCount;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm your selection?'),
        content: Text(
          '${count == 1 ? '1 photo' : '$count photos'} chosen. '
          '${owed ? 'You will be charged ${_money(quote.amountDue, quote.currency)}.' : 'No charge - this is covered by what you have already paid.'} '
          'You cannot change your selection after this.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Not yet')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(owed ? 'Pay ${_money(quote.amountDue, quote.currency)}' : 'Confirm selection'),
          ),
        ],
      ),
    );
  }
}

bool _nothingDue(SelectionQuoteResponse quote) => quote.amountDue == '0.00';

/// The button says what it will do and what it will cost, so the number being
/// committed to is on screen before the tap rather than discovered after it.
String _confirmLabel(SelectionState value) {
  final phase = value.phase;
  if (phase is ConfirmAwaitingPayment) {
    final amount = phase.amount;
    return amount == null ? 'Pay now' : 'Pay ${_money(amount, phase.currency)}';
  }
  final quote = value.quote;
  if (quote == null || _nothingDue(quote)) return 'Confirm selection';
  return 'Pay ${_money(quote.amountDue, quote.currency)}';
}

/// Money is a decimal string end to end; it is displayed, never arithmetic.
String _money(String amount, String currency) => '$currency $amount';

String _totalLabel(SelectionQuoteResponse quote, bool failed) {
  if (failed) return 'Total unavailable - pull to refresh';
  if (quote.amountDue == '0.00') return 'Nothing more to pay';
  return '${_money(quote.amountDue, quote.currency)} to pay';
}

String _marginalLabel(SelectionQuoteResponse quote) {
  final next = quote.nextPhotoPrice;
  if (next == null) return '';
  if (next == '0.00') return 'The next photo is included';
  return 'One more adds ${_money(next, quote.currency)}';
}
