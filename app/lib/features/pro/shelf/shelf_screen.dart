import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/shelf_browse_item.dart';
import 'package:rawwers/api/models/shelf_browse_level.dart';
import 'package:rawwers/api/models/shelf_browse_response.dart';
import 'package:rawwers/api/models/skill_tier.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_sheet.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/components/r_tier_badge.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/shelf/shelf_controller.dart';

/// The Shelf: gear a photographer can have for the RAWW their bookings earn.
///
/// Shows only what they can use: levels up to their tier, and for items made
/// for particular cameras, only those that fit a camera in My gear. Levels
/// above their tier show as teasers with the tier that unlocks them.
class ShelfScreen extends ConsumerWidget {
  const ShelfScreen({this.gearPath, this.orderItem, super.key});

  /// Where "Add your camera" goes (My gear).
  final String? gearPath;

  /// Opens an item's order flow; null until ordering exists.
  final void Function(BuildContext context, ShelfBrowseItem item)? orderItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelf = ref.watch(shelfControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('The Shelf')),
      body: SafeArea(
        child: switch (shelf) {
          AsyncData(:final value) => RefreshIndicator(
              onRefresh: () async => ref.invalidate(shelfControllerProvider),
              child: ListView(
                padding: const EdgeInsets.all(RSpace.s16),
                children: [
                  _Header(view: value),
                  if (!value.hasCamera) ...[
                    const SizedBox(height: RSpace.s16),
                    _AddCameraPrompt(gearPath: gearPath),
                  ],
                  for (final level in value.levels) ...[
                    const SizedBox(height: RSpace.s24),
                    _Level(level: level, orderItem: orderItem),
                  ],
                  const SizedBox(height: RSpace.s24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(onPressed: () => _showTerms(context, value), child: const Text('Terms for The Shelf')),
                  ),
                ],
              ),
            ),
          AsyncError() => RErrorState(
              message: 'The Shelf could not be loaded.',
              onRetry: () => ref.invalidate(shelfControllerProvider),
            ),
          _ => const Padding(padding: EdgeInsets.all(RSpace.s16), child: RSkeleton(width: RSize.lineMedium)),
        },
      ),
    );
  }

  void _showTerms(BuildContext context, ShelfBrowseResponse view) {
    showRSheet<void>(
      context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(RSpace.s16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Terms for The Shelf', style: Theme.of(context).textTheme.titleMedium),
              if (view.termsDraft) ...[
                const SizedBox(height: RSpace.s8),
                Text('Draft, not yet reviewed', style: Theme.of(context).textTheme.labelMedium),
              ],
              const SizedBox(height: RSpace.s12),
              Text(view.termsText),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.view});

  final ShelfBrowseResponse view;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tier = SkillTier.values.where((t) => t.name == view.tier).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${view.spendable} RAWW to spend', style: theme.textTheme.headlineSmall),
        const SizedBox(height: RSpace.s4),
        Text(
          '${tier == null ? 'Your tier' : rTierName(tier)} sees levels 1 to ${view.maxLevel}. '
          'Wish list: up to ${view.wishlistMax}.',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _AddCameraPrompt extends StatelessWidget {
  const _AddCameraPrompt({required this.gearPath});

  final String? gearPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add your camera', style: theme.textTheme.titleSmall),
          const SizedBox(height: RSpace.s4),
          Text(
            'Batteries and chargers show once The Shelf knows which camera you use.',
            style: theme.textTheme.bodySmall,
          ),
          if (gearPath != null) ...[
            const SizedBox(height: RSpace.s12),
            RButton(label: 'Add it in My gear', variant: RButtonVariant.secondary, onPressed: () => context.push(gearPath!)),
          ],
        ],
      ),
    );
  }
}

class _Level extends StatelessWidget {
  const _Level({required this.level, required this.orderItem});

  final ShelfBrowseLevel level;
  final void Function(BuildContext context, ShelfBrowseItem item)? orderItem;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocks = SkillTier.values.where((t) => t.name == level.unlocksAtTier).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: RSpace.s8,
          children: [
            Text('Level ${level.level}', style: theme.textTheme.titleMedium),
            Text('from ${level.bandRaww} RAWW', style: theme.textTheme.bodySmall),
          ],
        ),
        if (level.locked)
          Text(
            unlocks == null ? 'Locked' : 'Unlocks at ${rTierName(unlocks)}',
            style: theme.textTheme.labelMedium,
          ),
        const SizedBox(height: RSpace.s8),
        if (level.items.isEmpty)
          Text('Nothing here yet.', style: theme.textTheme.bodySmall)
        else
          for (final item in level.items) ...[
            _ItemCard(item: item, orderItem: orderItem),
            const SizedBox(height: RSpace.s8),
          ],
      ],
    );
  }
}

class _ItemCard extends ConsumerStatefulWidget {
  const _ItemCard({required this.item, required this.orderItem});

  final ShelfBrowseItem item;
  final void Function(BuildContext context, ShelfBrowseItem item)? orderItem;

  @override
  ConsumerState<_ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends ConsumerState<_ItemCard> {
  bool _busy = false;

  Future<void> _toggle() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final problem = await ref.read(shelfControllerProvider.notifier).toggleWish(widget.item);
    if (!mounted) return;
    setState(() => _busy = false);
    if (problem != null) messenger.showSnackBar(SnackBar(content: Text(problem)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final notes = [
      if (item.fitsYourGear) 'Fits your camera',
      if (!item.inStock) 'Out of stock',
      if (!item.locked && item.inStock && !item.affordable) 'Not enough RAWW yet',
    ];
    final canOrder = widget.orderItem != null && !item.locked && item.inStock && item.affordable;

    return Opacity(
      opacity: item.locked ? 0.55 : 1,
      child: RCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl != null) ...[
              SizedBox(
                width: 64,
                height: 64,
                child: Image.network(item.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
              ),
              const SizedBox(width: RSpace.s12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: theme.textTheme.titleSmall),
                  if (item.brand != null) Text(item.brand!, style: muted),
                  const SizedBox(height: RSpace.s4),
                  Text('${item.priceRaww} RAWW', style: theme.textTheme.bodyMedium),
                  if (notes.isNotEmpty) Text(notes.join(' · '), style: muted),
                  if (canOrder) ...[
                    const SizedBox(height: RSpace.s8),
                    RButton(label: 'Order', onPressed: () => widget.orderItem!(context, item)),
                  ],
                ],
              ),
            ),
            if (item.locked)
              const Padding(padding: EdgeInsets.all(RSpace.s8), child: Icon(Icons.lock_outline))
            else
              IconButton(
                tooltip: item.wished ? 'Take off your wish list' : 'Add to your wish list',
                onPressed: _busy ? null : _toggle,
                icon: Icon(item.wished ? Icons.favorite : Icons.favorite_border),
              ),
          ],
        ),
      ),
    );
  }
}
