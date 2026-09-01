import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../design/tokens.dart';
import '../../design/widgets/r_badge.dart';
import '../../design/widgets/r_button.dart';
import '../../design/widgets/r_card.dart';
import '../../design/widgets/r_skeleton.dart';
import '../../design/widgets/r_text_field.dart';
import '../../data/models/discover_models.dart';
import '../auth/providers.dart';
import '../discover/widgets/discover_card_tile.dart';
import 'listing_card_providers.dart';

class ListingCardScreen extends ConsumerStatefulWidget {
  const ListingCardScreen({super.key});

  @override
  ConsumerState<ListingCardScreen> createState() => _ListingCardScreenState();
}

class _ListingCardScreenState extends ConsumerState<ListingCardScreen> {
  final _headlineController = TextEditingController();
  final _coverController = TextEditingController();
  List<String> _selectedTags = [];
  bool _initialized = false;
  bool _saving = false;
  bool _gridPreview = false;

  @override
  void dispose() {
    _headlineController.dispose();
    _coverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(listingCardDataProvider);

    return dataAsync.when(
      loading: () => const RSkeleton(height: 180),
      error: (error, _) => Text('Listing card unavailable: $error'),
      data: (data) {
        if (!_initialized) {
          _headlineController.text = data.profile.headline ?? '';
          _coverController.text = data.profile.coverMediaAssetId ?? '';
          _selectedTags = data.myNiches.niches.map((e) => e.slug).take(5).toList();
          _initialized = true;
        }

        final baselineHeadline = data.profile.headline ?? '';
        final baselineCover = data.profile.coverMediaAssetId ?? '';
        final baselineTags = data.myNiches.niches.map((e) => e.slug).toSet();
        final dirty = _headlineController.text != baselineHeadline ||
            _coverController.text != baselineCover ||
            _selectedTags.toSet().difference(baselineTags).isNotEmpty ||
            baselineTags.difference(_selectedTags.toSet()).isNotEmpty;

        final cheapest = [...data.publicProfile.packages]..sort((a, b) => a.price.compareTo(b.price));
        final price = cheapest.isEmpty ? null : cheapest.first;

        final preview = DiscoverCardModel(
          proUserId: data.profile.userId,
          displayName: data.profile.displayName,
          headline: _headlineController.text,
          coverMediaAssetId: _coverController.text.trim().isEmpty ? null : _coverController.text.trim(),
          city: data.profile.city,
          country: data.profile.country,
          minPrice: price?.price,
          currency: price?.currency ?? 'EUR',
          avgRating: data.publicProfile.avgRating,
          reviewCount: data.publicProfile.reviewCount,
          topNiches: _selectedTags,
        );

        return ListView(
          children: [
            RCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What clients see', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: RTokens.spacingX2),
                  RTextField(
                    controller: _headlineController,
                    hintText: 'Headline',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: RTokens.spacingX1),
                  Text('${_headlineController.text.length}/80', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: RTokens.spacingX2),
                  RTextField(
                    controller: _coverController,
                    hintText: 'Cover media asset ID',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: RTokens.spacingX2),
                  Text('Tags (max 5)', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: RTokens.spacingX1),
                  Wrap(
                    spacing: RTokens.spacingX1,
                    runSpacing: RTokens.spacingX1,
                    children: data.catalog.map((item) {
                      final active = _selectedTags.contains(item.slug);
                      return FilterChip(
                        selected: active,
                        label: Text(item.name),
                        onSelected: (selected) {
                          setState(() {
                            if (!selected) {
                              _selectedTags.remove(item.slug);
                              return;
                            }
                            if (_selectedTags.length >= 5) return;
                            _selectedTags.add(item.slug);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: RTokens.spacingX2),
                  if (price != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pricing preview', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: RTokens.spacingX1),
                        Text('${price.currency} ${price.price.toStringAsFixed(0)} base package'),
                        Text('${price.currency} ${price.extraPhotoPrice.toStringAsFixed(0)} per extra image'),
                        Text('${price.includedPhotos} photos included'),
                      ],
                    ),
                  const SizedBox(height: RTokens.spacingX2),
                  if (dirty)
                    RButton(
                      label: _saving ? 'Saving...' : 'Save',
                      onPressed: _saving
                          ? null
                          : () async {
                              setState(() => _saving = true);
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                final repo = ref.read(listingCardRepositoryProvider);
                                await repo.updateMyProfile(
                                  headline: _headlineController.text,
                                  coverMediaAssetId: _coverController.text,
                                );
                                await repo.putMyNiches(previous: data.myNiches.niches, selected: _selectedTags);
                                ref.invalidate(listingCardDataProvider);
                                await ref.read(listingCardDataProvider.future);
                                if (!context.mounted) return;
                                messenger.showSnackBar(const SnackBar(content: Text('Listing card saved')));
                              } catch (e) {
                                if (!context.mounted) return;
                                messenger.showSnackBar(SnackBar(content: Text('Save failed: $e')));
                              } finally {
                                if (mounted) setState(() => _saving = false);
                              }
                            },
                    ),
                ],
              ),
            ),
            const SizedBox(height: RTokens.spacingX3),
            RCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Live preview', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: RTokens.spacingX2),
                  Row(
                    children: [
                      ChoiceChip(
                        selected: !_gridPreview,
                        label: const Text('List'),
                        onSelected: (_) => setState(() => _gridPreview = false),
                      ),
                      const SizedBox(width: RTokens.spacingX2),
                      ChoiceChip(
                        selected: _gridPreview,
                        label: const Text('Grid'),
                        onSelected: (_) => setState(() => _gridPreview = true),
                      ),
                    ],
                  ),
                  const SizedBox(height: RTokens.spacingX2),
                  if (_gridPreview)
                    GridView.count(
                      crossAxisCount: 1,
                      childAspectRatio: 1.8,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        DiscoverCardTile(item: preview),
                        DiscoverCardTile(item: preview),
                      ],
                    )
                  else
                    Column(
                      children: [
                        DiscoverCardTile(item: preview),
                        const SizedBox(height: RTokens.spacingX2),
                        DiscoverCardTile(item: preview),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: RTokens.spacingX3),
            RCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Verify Public View', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: RTokens.spacingX2),
                  RButton(
                    label: 'Check now',
                    onPressed: () async {
                      final me = ref.read(meProvider);
                      if (me == null) return;
                      final repo = ref.read(listingCardRepositoryProvider);
                      final pub = await repo.getPublicProfile(me.userId);
                      final search = await repo.findSearchCard(
                        city: pub.city ?? '',
                        country: pub.country ?? '',
                        proUserId: me.userId,
                      );
                      if (!context.mounted) return;
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        builder: (ctx) => Padding(
                          padding: const EdgeInsets.all(RTokens.spacingX4),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Public profile', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: RTokens.spacingX2),
                                Text('Headline: ${pub.headline ?? '-'}'),
                                Text('Cover media: ${pub.coverMediaAssetId ?? '-'}'),
                                const SizedBox(height: RTokens.spacingX2),
                                Text('Search card', style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: RTokens.spacingX2),
                                Text('Headline: ${search?['headline'] ?? '-'}'),
                                Text('Cover media: ${search?['cover_media_asset_id'] ?? '-'}'),
                                const SizedBox(height: RTokens.spacingX2),
                                RBadge(label: (_headlineController.text == (pub.headline ?? '')) ? 'Headline match' : 'Headline differs'),
                                const SizedBox(height: RTokens.spacingX1),
                                RBadge(label: ((_coverController.text.trim()) == (pub.coverMediaAssetId ?? '')) ? 'Cover match' : 'Cover differs'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
