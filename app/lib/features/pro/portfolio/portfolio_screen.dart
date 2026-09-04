import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/pro_portfolio_item.dart';
import 'package:rawwers/api/models/pro_portfolio_response.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_chip.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_network_photo.dart';
import 'package:rawwers/design/components/r_progress.dart';
import 'package:rawwers/design/components/r_sheet.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
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
                            onTap: () => _openTagger(context, ref, item),
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
                children: [RSkeleton(width: 240), SizedBox(height: RSpace.s16), RSkeleton(width: 200)],
              ),
            ),
        },
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
                  ? 'Add more whenever you want. The cover is what a client sees first.'
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
          Icon(Icons.photo_library_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
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
            const Positioned(left: 4, top: 4, child: _Badge(label: 'Cover')),
          // An untagged photo is invisible to niche filtering, which is how
          // most clients arrive - worth showing on the tile rather than
          // making someone open each one to find out.
          if (!tagged)
            const Positioned(right: 4, bottom: 4, child: _Badge(label: 'Untagged')),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: RSpace.s8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.inverseSurface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(RRadius.control),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onInverseSurface),
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
    final niches = ref.watch(nichesControllerProvider);

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
        switch (niches) {
          AsyncData(:final value) => Wrap(
              spacing: RSpace.s8,
              runSpacing: RSpace.s8,
              children: [
                for (final niche in value)
                  RSelectableChip(
                    label: niche.name,
                    selected: _selected.contains(niche.slug),
                    onPressed: () => setState(() {
                      _selected.contains(niche.slug) ? _selected.remove(niche.slug) : _selected.add(niche.slug);
                    }),
                  ),
              ],
            ),
          AsyncError() => const Text('Could not load the list of niches.'),
          _ => const RSkeleton(width: 240),
        },
        const SizedBox(height: RSpace.s24),
        if (_error != null) ...[
          Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
          const SizedBox(height: RSpace.s12),
        ],
        RButton(label: 'Save tags', onPressed: _saving ? null : _save, loading: _saving),
      ],
    );
  }
}
