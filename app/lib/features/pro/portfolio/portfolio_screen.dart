import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/pro_niche_view.dart';
import 'package:rawwers/api/models/pro_portfolio_item.dart';
import 'package:rawwers/api/models/pro_portfolio_response.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/components/r_dialog.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/design/components/r_overlay_badge.dart';
import 'package:rawwers/design/components/r_photo_viewer.dart';
import 'package:rawwers/design/components/r_progress.dart';
import 'package:rawwers/design/components/r_sheet.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/niches/my_niches_controller.dart';
import 'package:rawwers/features/pro/portfolio/niches_controller.dart';
import 'package:rawwers/features/pro/portfolio/portfolio_controller.dart';

/// The work itself.
///
/// Leads with progress toward the minimum, because until a photographer
/// clears it their listing cannot go live and nothing else they do here
/// matters.
class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioControllerProvider);
    final uploads = ref.watch(portfolioUploadControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ref.read(portfolioUploadControllerProvider.notifier).pickAndUpload(),
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Add photos'),
      ),
      body: SafeArea(
        child: switch (portfolio) {
          AsyncData(:final value) => RefreshIndicator(
              onRefresh: () => ref.read(portfolioControllerProvider.notifier).refresh(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _MinimumProgress(portfolio: value)),
                  if (uploads.isNotEmpty)
                    SliverToBoxAdapter(child: _Uploads(uploads: uploads)),
                  if (value.items?.isEmpty ?? true)
                    const SliverToBoxAdapter(child: _EmptyPortfolio())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(RSpace.s16, 0, RSpace.s16, RSpace.s64),
                      sliver: SliverGrid.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: RSpace.s8,
                          crossAxisSpacing: RSpace.s8,
                        ),
                        itemCount: value.items!.length,
                        itemBuilder: (context, index) {
                          final item = value.items![index];
                          return _Tile(
                            item: item,
                            onTap: () => _openPhoto(context, ref, value.items!, index),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          AsyncError() => RErrorState(
              message: 'Could not load your portfolio.',
              onRetry: () => ref.invalidate(portfolioControllerProvider),
            ),
          _ => const Padding(
              padding: EdgeInsets.all(RSpace.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [RSkeleton(width: RSize.lineLong), SizedBox(height: RSpace.s16), RSkeleton(width: RSize.lineMedium)],
              ),
            ),
        },
      ),
    );
  }

  /// Tapping a photo opens it, and tagging happens in there.
  ///
  /// Tapping used to open the niche tagger directly off a 512px tile, which
  /// asked a photographer to decide what a photo *is* while looking at a
  /// thumbnail barely bigger than a stamp. The tagger is still one tap away,
  /// now from a screen where the photo is actually legible.
  ///
  /// A photo with no preview is still processing, so there is nothing to open:
  /// it goes straight to the tagger, which does work on an unprocessed asset.
  Future<void> _openPhoto(
    BuildContext context,
    WidgetRef ref,
    List<ProPortfolioItem> items,
    int index,
  ) async {
    final item = items[index];
    if (item.previewUrl == null) {
      await _openTagger(context, ref, item);
      return;
    }
    await showRPhotoViewer(
      context,
      title: 'Your portfolio',
      initialIndex: index,
      urls: [for (final entry in items) entry.previewUrl ?? entry.thumbnailUrl],
      actionsBuilder: (viewerContext, current) => PhotoActions(
        item: items[current],
        onTag: (item) => _openTagger(viewerContext, ref, item),
      ),
    );
  }

  Future<void> _openTagger(BuildContext context, WidgetRef ref, ProPortfolioItem item) async {
    await showRSheet<void>(
      context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(RSpace.s16),
        child: _NicheTagger(item: item),
      ),
    );
  }
}

/// What the confirmation says before a photo is removed: in plain words,
/// what happens, and that it cannot be undone. For the cover, what clients
/// see instead: the server shows another of their ready photos until they
/// choose a new cover (api services/profile_cover.py).
String removePhotoMessage(ProPortfolioItem item, {required bool otherReadyPhotos}) => [
      'This photo disappears from your profile and from Discover. It cannot be recovered.',
      if (item.isCover)
        otherReadyPhotos
            ? 'This is your cover. Another photo will be used until you choose a new one.'
            : 'This is your cover and your only ready photo: your listing will show no photo until you add one.',
    ].join(' ');

/// The buttons under a photo in the full-screen viewer: tag, make it the
/// cover, remove it. One column, each button the full width, so the three
/// read as a list of things to do with this photo and the long labels never
/// squeeze. The viewer is dark, so the outlined buttons get light text and
/// a light border here: the app's outlined style (meter700 on paper) is
/// 1.9:1 on the viewer's near-black, which is unreadable.
///
/// Reads the photo from the portfolio as it is now, not as it was when the
/// viewer opened, so "Cover" appears as soon as it is set.
class PhotoActions extends ConsumerStatefulWidget {
  const PhotoActions({required this.item, required this.onTag, super.key});

  final ProPortfolioItem item;
  final void Function(ProPortfolioItem item) onTag;

  @override
  ConsumerState<PhotoActions> createState() => _PhotoActionsState();
}

class _PhotoActionsState extends ConsumerState<PhotoActions> {
  bool _settingCover = false;

  Future<void> _setCover(ProPortfolioItem item) async {
    setState(() => _settingCover = true);
    final error = await ref.read(portfolioControllerProvider.notifier).setCover(item.mediaAssetId);
    if (!mounted) return;
    setState(() => _settingCover = false);
    if (error != null) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RRadius.surface)),
          title: const Text('Not set as cover'),
          content: Text(error),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final portfolio = ref.watch(portfolioControllerProvider).valueOrNull;
    final item = portfolio?.items?.firstWhere(
          (entry) => entry.mediaAssetId == widget.item.mediaAssetId,
          orElse: () => widget.item,
        ) ??
        widget.item;
    final chosen = portfolio?.coverChosen ?? false;
    final isChosenCover = item.isCover && chosen;
    final onDark = OutlinedButton.styleFrom(
      foregroundColor: RInk.i050,
      side: const BorderSide(color: RInk.i200),
    );

    return Theme(
      data: theme.copyWith(outlinedButtonTheme: OutlinedButtonThemeData(style: onDark.merge(theme.outlinedButtonTheme.style))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.isCover) ...[
            Row(
              children: [
                const ROverlayBadge(label: 'Cover'),
                const SizedBox(width: RSpace.s8),
                Expanded(
                  child: Text(
                    chosen ? 'Clients see this photo first.' : 'Clients see this photo first until you choose a cover.',
                    style: theme.textTheme.bodySmall?.copyWith(color: RInk.i200),
                  ),
                ),
              ],
            ),
            const SizedBox(height: RSpace.s8),
          ],
          RButton(
            label: (item.nicheSlugs?.isNotEmpty ?? false) ? 'Edit tags' : 'Tag niches',
            onPressed: () => widget.onTag(item),
          ),
          if (!isChosenCover) ...[
            const SizedBox(height: RSpace.s8),
            RButton(
              label: 'Set as cover',
              variant: RButtonVariant.secondary,
              loading: _settingCover,
              onPressed: () => _setCover(item),
            ),
          ],
          const SizedBox(height: RSpace.s8),
          RButton(
            label: 'Remove from portfolio',
            variant: RButtonVariant.secondary,
            onPressed: () => confirmAndRemovePhoto(context, ref, item),
          ),
        ],
      ),
    );
  }
}

/// Asks, then removes the photo. On success, closes the screen it was asked
/// from (the full-screen viewer or the tagger), whose photo is gone; on a
/// refusal, shows the server's reason and leaves everything as it was.
Future<void> confirmAndRemovePhoto(BuildContext context, WidgetRef ref, ProPortfolioItem item) async {
  final items = ref.read(portfolioControllerProvider).valueOrNull?.items ?? const <ProPortfolioItem>[];
  final otherReady = items.any((other) => other.mediaAssetId != item.mediaAssetId && other.kind == 'photo' && other.status == 'ready');
  final confirmed = await showRConfirmDialog(
    context,
    title: 'Remove from portfolio?',
    message: removePhotoMessage(item, otherReadyPhotos: otherReady),
    confirmLabel: 'Remove',
  );
  if (!confirmed || !context.mounted) return;
  final error = await ref.read(portfolioControllerProvider.notifier).removePhoto(item.mediaAssetId);
  if (!context.mounted) return;
  if (error != null) {
    // A dialog, not a snackbar: the snackbar would sit under the full-screen
    // viewer, and this is the reason the photo is still there.
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RRadius.surface)),
        title: const Text('Not removed'),
        content: Text(error),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
      ),
    );
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  Navigator.of(context).pop();
  messenger.showSnackBar(const SnackBar(content: Text('Removed from your portfolio.')));
}

class _MinimumProgress extends StatelessWidget {
  const _MinimumProgress({required this.portfolio});

  final ProPortfolioResponse portfolio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final have = portfolio.photoCount;
    final need = portfolio.photoMinimum;
    final met = have >= need;

    return Padding(
      padding: const EdgeInsets.all(RSpace.s16),
      child: RCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              met ? 'You have enough photos to go live' : '$have of $need photos',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: RSpace.s8),
            RProgressBar(value: need == 0 ? 1 : (have / need).clamp(0, 1).toDouble()),
            const SizedBox(height: RSpace.s8),
            Text(
              met
                  ? 'Add more whenever you want. The cover is what a client sees first: open a photo and tap Set as cover.'
                  : 'Your listing cannot go live until you have $need.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Uploads extends ConsumerWidget {
  const _Uploads({required this.uploads});

  final Map<String, UploadProgress> uploads;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(RSpace.s16, 0, RSpace.s16, RSpace.s16),
      child: RCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in uploads.entries) ...[
              Row(
                children: [
                  Expanded(child: Text(entry.value.fileName, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
                  if (entry.value.error != null)
                    IconButton(
                      onPressed: () => ref.read(portfolioUploadControllerProvider.notifier).dismiss(entry.key),
                      icon: const Icon(Icons.close),
                      tooltip: 'Dismiss',
                    ),
                ],
              ),
              if (entry.value.error != null)
                Text(
                  entry.value.error!,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                )
              else
                RProgressBar(value: entry.value.fraction),
              const SizedBox(height: RSpace.s8),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyPortfolio extends StatelessWidget {
  const _EmptyPortfolio();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(RSpace.s32),
      child: Column(
        children: [
          Icon(Icons.photo_library_outlined, size: RIcon.empty, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: RSpace.s16),
          Text('Nothing here yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: RSpace.s8),
          Text(
            'Clients pick a photographer by looking. Twelve of your best is '
            'more convincing than fifty of everything.',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.item, required this.onTap});

  final ProPortfolioItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tagged = item.nicheSlugs?.isNotEmpty ?? false;

    return InkWell(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RNetworkPhoto(url: item.thumbnailUrl),
          if (item.isCover)
            const Positioned(left: 4, top: 4, child: ROverlayBadge(label: 'Cover')),
          // An untagged photo is invisible to niche filtering, which is how
          // most clients arrive - worth showing on the tile rather than
          // making someone open each one to find out.
          if (item.status != 'ready')
            const Positioned(right: 4, bottom: 4, child: ROverlayBadge(label: 'Processing'))
          else if (!tagged)
            const Positioned(right: 4, bottom: 4, child: ROverlayBadge(label: 'Untagged')),
        ],
      ),
    );
  }
}

class _NicheTagger extends ConsumerStatefulWidget {
  const _NicheTagger({required this.item});

  final ProPortfolioItem item;

  @override
  ConsumerState<_NicheTagger> createState() => _NicheTaggerState();
}

class _NicheTaggerState extends ConsumerState<_NicheTagger> {
  late final Set<String> _selected = {...?widget.item.nicheSlugs};

  /// Tags this photo already had for niches that are not the
  /// photographer's (chosen before the tagger offered only their own, or a
  /// niche removed since). Kept as they are unless untagged here, and shown
  /// for the whole time the sheet is open so an untag can be undone.
  late final Set<String> _taggedBefore = {...?widget.item.nicheSlugs};
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    final error = await ref.read(portfolioControllerProvider.notifier).tagNiches(
          mediaAssetId: widget.item.mediaAssetId,
          nicheSlugs: _selected.toList(),
        );

    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _saving = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mine = ref.watch(myNichesControllerProvider);
    // Names for tags of niches that are not the photographer's.
    final names = {for (final n in ref.watch(nichesControllerProvider).valueOrNull ?? const <NicheOption>[]) n.slug: n.name};

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What is this a photo of?', style: theme.textTheme.titleMedium),
        const SizedBox(height: RSpace.s4),
        Text(
          'Tags are how clients browsing a niche find this shot.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: RSpace.s16),
        switch (mine) {
          AsyncData(:final value) => _chips(theme, value.niches ?? const [], names),
          AsyncError() => const Text('Could not load your niches.'),
          _ => const RSkeleton(width: RSize.lineLong),
        },
        const SizedBox(height: RSpace.s24),
        if (_error != null) ...[
          Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
          const SizedBox(height: RSpace.s12),
        ],
        RButton(label: 'Save tags', onPressed: _saving ? null : _save, loading: _saving),
        // A photo still processing has no full-screen view, so it is
        // removed from here.
        if (widget.item.previewUrl == null) ...[
          const SizedBox(height: RSpace.s12),
          RButton(
            label: 'Remove from portfolio',
            variant: RButtonVariant.secondary,
            onPressed: _saving ? null : () => confirmAndRemovePhoto(context, ref, widget.item),
          ),
        ],
      ],
    );
  }

  Widget _chips(ThemeData theme, List<ProNicheView> own, Map<String, String> names) {
    final ownSlugs = {for (final n in own) n.slug};
    final others = _taggedBefore.where((slug) => !ownSlugs.contains(slug)).toList()..sort();
    if (own.isEmpty && others.isEmpty) {
      return Text(
        'You have no niches yet. Choose them in Settings > Your niches, then tag your photos.',
        style: theme.textTheme.bodyMedium,
      );
    }
    void toggle(String slug) => setState(() {
          _selected.contains(slug) ? _selected.remove(slug) : _selected.add(slug);
        });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: RSpace.s8,
          runSpacing: RSpace.s8,
          children: [
            for (final niche in own)
              RSelectableChip(
                label: niche.name,
                selected: _selected.contains(niche.slug),
                onPressed: () => toggle(niche.slug),
              ),
            for (final slug in others)
              RSelectableChip(
                label: '${names[slug] ?? slug} (not your niche)',
                selected: _selected.contains(slug),
                onPressed: () => toggle(slug),
              ),
          ],
        ),
        if (others.isNotEmpty) ...[
          const SizedBox(height: RSpace.s8),
          Text(
            'This photo is also tagged with a niche that is not one of yours. '
            'The tag stays unless you untag it here; once untagged, it can only be added back while this sheet is open.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
