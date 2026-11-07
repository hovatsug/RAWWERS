import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/shelf_browse_item.dart';
import 'package:rawwers/api/models/shelf_browse_level.dart';
import 'package:rawwers/api/models/skill_tier.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/components/r_tier_badge.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/shelf/shelf_checkout.dart';
import 'package:rawwers/features/pro/shelf/shelf_controller.dart';

/// One item on The Shelf: its photos large and swipeable, what it is, what
/// it costs, which cameras it fits, and the order button when it can be
/// ordered (or why not).
class ShelfItemScreen extends ConsumerWidget {
  const ShelfItemScreen({required this.itemId, this.orderItem, super.key});

  final String itemId;

  /// Opens the order flow (the checkout, by default).
  final void Function(BuildContext context, ShelfBrowseItem item)? orderItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelf = ref.watch(shelfControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('The Shelf')),
      body: SafeArea(
        child: switch (shelf) {
          AsyncData(:final value) => switch (_find(value.levels)) {
              (final item, final level)? => _Detail(item: item, level: level, spendable: value.spendable, orderItem: orderItem),
              null => const REmptyState(title: 'Not on The Shelf', body: 'This item is no longer available.', icon: Icons.inventory_2_outlined),
            },
          AsyncError() => RErrorState(message: 'The Shelf could not be loaded.', onRetry: () => ref.invalidate(shelfControllerProvider)),
          _ => const Padding(padding: EdgeInsets.all(RSpace.s16), child: RSkeleton(height: RSize.blockTall)),
        },
      ),
    );
  }

  (ShelfBrowseItem, ShelfBrowseLevel)? _find(List<ShelfBrowseLevel> levels) {
    for (final level in levels) {
      for (final item in level.items) {
        if (item.id == itemId) return (item, level);
      }
    }
    return null;
  }
}

/// What the item fits, in words.
String shelfCompatibility(ShelfBrowseItem item) {
  final names = item.cameraNames ?? const <String>[];
  if (names.isEmpty) return 'Fits any camera.';
  return item.fitsYourGear ? 'Fits your ${names.join(', ')}.' : 'Made for ${names.join(', ')}.';
}

class _Detail extends ConsumerStatefulWidget {
  const _Detail({required this.item, required this.level, required this.spendable, required this.orderItem});

  final ShelfBrowseItem item;
  final ShelfBrowseLevel level;
  final int spendable;
  final void Function(BuildContext context, ShelfBrowseItem item)? orderItem;

  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  int _page = 0;
  bool _busy = false;

  Future<void> _toggle() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final problem = await ref.read(shelfControllerProvider.notifier).toggleWish(widget.item);
    if (!mounted) return;
    setState(() => _busy = false);
    if (problem != null) messenger.showSnackBar(SnackBar(content: Text(problem)));
  }

  Future<void> _order() async {
    final custom = widget.orderItem;
    if (custom != null) return custom(context, widget.item);
    final messenger = ScaffoldMessenger.of(context);
    final placed = await showShelfCheckout(context, item: widget.item, spendable: widget.spendable);
    if (placed) messenger.showSnackBar(const SnackBar(content: Text('Order placed. Find it in My orders.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    final photos = (item.imageUrls?.isNotEmpty ?? false) ? item.imageUrls! : [if (item.coverUrl != null) item.coverUrl!];
    final unlocks = SkillTier.values.where((t) => t.name == widget.level.unlocksAtTier).firstOrNull;
    final why = item.locked
        ? (unlocks == null ? 'Locked.' : 'Unlocks at ${rTierName(unlocks)}.')
        : !item.inStock
            ? 'Out of stock.'
            : !item.affordable
                ? 'Not enough RAWW yet: ${widget.spendable} of ${item.priceRaww}.'
                : null;

    return ListView(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: photos.isEmpty
              ? ColoredBox(color: theme.colorScheme.surfaceContainerHighest)
              : PageView.builder(
                  itemCount: photos.length,
                  onPageChanged: (page) => setState(() => _page = page),
                  itemBuilder: (context, index) => Image.network(
                    photos[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => ColoredBox(color: theme.colorScheme.surfaceContainerHighest),
                  ),
                ),
        ),
        if (photos.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: RSpace.s8),
            child: Text('${_page + 1} / ${photos.length}', textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
          ),
        Padding(
          padding: const EdgeInsets.all(RSpace.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: theme.textTheme.titleLarge),
                        if (item.brand != null) Text(item.brand!, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  if (!item.locked || item.wished)
                    IconButton(
                      tooltip: item.wished ? 'Take off your wish list' : 'Add to your wish list',
                      onPressed: _busy ? null : _toggle,
                      icon: Icon(item.wished ? Icons.favorite : Icons.favorite_border),
                    ),
                ],
              ),
              const SizedBox(height: RSpace.s8),
              Text('${item.priceRaww} RAWW', style: theme.textTheme.headlineSmall),
              const SizedBox(height: RSpace.s8),
              Text(shelfCompatibility(item), style: theme.textTheme.bodyMedium),
              if (item.description != null && item.description!.isNotEmpty) ...[
                const SizedBox(height: RSpace.s12),
                Text(item.description!, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: RSpace.s16),
              if (why != null)
                Text(why, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))
              else
                RButton(label: 'Order', onPressed: _order),
            ],
          ),
        ),
      ],
    );
  }
}
