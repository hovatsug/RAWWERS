import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/shelf_browse_item.dart';
import 'package:rawwers/api/models/shelf_browse_level.dart';
import 'package:rawwers/api/models/shelf_browse_response.dart';
import 'package:rawwers/api/models/skill_tier.dart';
import 'package:rawwers/core/format/dates.dart';
import 'package:rawwers/core/format/money.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_card_row.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_sheet.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/components/r_tier_badge.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/shelf/shelf_controller.dart';
import 'package:rawwers/features/pro/shelf/shelf_orders_screen.dart';
import 'package:rawwers/features/shared/notifications/notifications_controller.dart';

/// The Shelf: gear a photographer can have for the RAWW their bookings earn.
///
/// Shows only what they can use: levels up to their tier, and for items made
/// for particular cameras, only those that fit a camera in My gear. Levels
/// above their tier show as teasers with the tier that unlocks them.
class ShelfScreen extends ConsumerWidget {
  const ShelfScreen({this.gearPath, this.ordersPath, this.itemPath, super.key});

  /// Where an item's card opens (its detail: photos, description, order).
  final String Function(String itemId)? itemPath;

  /// Where "Add your camera" goes (My gear).
  final String? gearPath;

  /// Where "My orders" goes.
  final String? ordersPath;


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelf = ref.watch(shelfControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Shelf'),
        actions: [
          if (ordersPath != null)
            TextButton(
              onPressed: () => context.push(ordersPath!),
              // A dot while an order update is unread; My orders reads them.
              child: Badge(
                isLabelVisible: (ref.watch(unreadCountProvider(typePrefix: shelfOrderUpdates)).valueOrNull ?? 0) > 0,
                smallSize: RSpace.s8,
                child: const Text('My orders'),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: switch (shelf) {
          AsyncData(:final value) => RefreshIndicator(
              onRefresh: () async => ref.invalidate(shelfControllerProvider),
              child: ListView(
                padding: const EdgeInsets.only(bottom: RSpace.s24),
                children: [
                  Padding(padding: const EdgeInsets.fromLTRB(RSpace.s16, RSpace.s16, RSpace.s16, 0), child: _Header(view: value)),
                  if (!value.hasCamera)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(RSpace.s16, RSpace.s16, RSpace.s16, 0),
                      child: _AddCameraPrompt(gearPath: gearPath),
                    ),
                  // What they wished for, wherever it sits, first.
                  if (_wished(value) case final wished when wished.isNotEmpty)
                    _ShelfRow(heading: Text('Your wish list', style: Theme.of(context).textTheme.titleMedium), items: wished, itemPath: itemPath),
                  for (final level in value.levels)
                    _ShelfRow(heading: _LevelHeading(level: level), items: level.items, itemPath: itemPath),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(RSpace.s8, RSpace.s16, RSpace.s16, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(onPressed: () => _showTerms(context, value), child: const Text('Terms for The Shelf')),
                    ),
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
        // The cap counts the UTC calendar month (owner's decision).
        Text(
          '${view.ordersThisMonth} of ${view.maxOrdersPerMonth} orders this month · '
          'resets ${RDates.of(context).date(view.ordersResetAt)}',
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

/// Every wished item across the levels, in level order.
List<ShelfBrowseItem> _wished(ShelfBrowseResponse view) => [
      for (final level in view.levels)
        for (final item in level.items)
          if (item.wished) item,
    ];

/// "Level 2 · about €100 · 1000 RAWW", and the tier that unlocks a locked one.
class _LevelHeading extends StatelessWidget {
  const _LevelHeading({required this.level});

  final ShelfBrowseLevel level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocks = SkillTier.values.where((t) => t.name == level.unlocksAtTier).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // Shelf levels are valued in euros until batch M4.
          'Level ${level.level} · about ${RMoney.of(context).format(level.bandEur, currency: 'EUR')} · ${level.bandRaww} RAWW',
          style: theme.textTheme.titleMedium,
        ),
        if (level.locked)
          Row(
            children: [
              const Icon(Icons.lock_outline, size: RIcon.inline),
              const SizedBox(width: RSpace.s4),
              Text(unlocks == null ? 'Locked' : 'Unlocks at ${rTierName(unlocks)}', style: theme.textTheme.labelMedium),
            ],
          ),
      ],
    );
  }
}

/// One row of cards, in the client's row pattern. Compatible items come
/// first (the server's order).
class _ShelfRow extends StatelessWidget {
  const _ShelfRow({required this.heading, required this.items, required this.itemPath});

  final Widget heading;
  final List<ShelfBrowseItem> items;
  final String Function(String itemId)? itemPath;

  static const cardWidth = 148.0;
  static const rowHeight = 236.0;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Padding(
        padding: RCardRow.headingPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [heading, const SizedBox(height: RSpace.s8), Text('Nothing here yet.', style: Theme.of(context).textTheme.bodySmall)],
        ),
      );
    }
    return RCardRow(
      heading: heading,
      height: rowHeight,
      itemCount: items.length,
      itemBuilder: (context, index) => _ShelfCard(item: items[index], itemPath: itemPath),
    );
  }
}

class _ShelfCard extends ConsumerStatefulWidget {
  const _ShelfCard({required this.item, required this.itemPath});

  final ShelfBrowseItem item;
  final String Function(String itemId)? itemPath;

  @override
  ConsumerState<_ShelfCard> createState() => _ShelfCardState();
}

class _ShelfCardState extends ConsumerState<_ShelfCard> {
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
    final note = !item.inStock ? 'Out of stock' : (item.fitsYourGear ? 'Fits your camera' : null);
    final open = widget.itemPath;

    return Opacity(
      opacity: item.locked ? 0.55 : 1,
      child: SizedBox(
        width: _ShelfRow.cardWidth,
        child: InkWell(
          onTap: open == null ? null : () => context.push(open(item.id)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(RSpace.s8),
                    child: SizedBox.square(
                      dimension: _ShelfRow.cardWidth,
                      child: item.coverUrl == null
                          ? ColoredBox(color: theme.colorScheme.surfaceContainerHighest)
                          : Image.network(
                              item.coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => ColoredBox(color: theme.colorScheme.surfaceContainerHighest),
                            ),
                    ),
                  ),
                  if (item.locked)
                    const Positioned(left: RSpace.s4, top: RSpace.s4, child: Icon(Icons.lock_outline)),
                  // A wish from before their level dropped: still theirs to
                  // take off, so it does not hold a place on a full list.
                  if (!item.locked || item.wished)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        tooltip: item.wished ? 'Take off your wish list' : 'Add to your wish list',
                        onPressed: _busy ? null : _toggle,
                        icon: Icon(item.wished ? Icons.favorite : Icons.favorite_border),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: RSpace.s8),
              Text(item.title, style: theme.textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              Text('${item.priceRaww} RAWW', style: theme.textTheme.bodyMedium),
              if (note != null) Text(note, style: muted, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
