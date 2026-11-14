import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/features/client/credit/credit_labels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/marketing_consent_offer_response.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_sheet.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/core/images/disk_cached_image.dart';
import 'package:rawwers/features/client/marketing/marketing_consent_controllers.dart';

/// After the rating, an optional card, separate from the booking and the
/// review: "Let RAWWERS feature your photos? Earn RAW credit." Shown only when
/// the server offers it for this booking; nothing is chosen until the client
/// chooses.
class MarketingOfferCard extends ConsumerWidget {
  const MarketingOfferCard({required this.gigId, this.creditPath, super.key});

  final String gigId;

  /// Where "See my credit" goes after credit is earned.
  final String? creditPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offer = ref.watch(marketingOfferControllerProvider(gigId)).valueOrNull;
    if (offer == null || !offer.offered) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final term = [for (final t in offer.terms ?? const []) if (t.months == offer.defaultTermMonths) t].firstOrNull;
    final credit = term?.creditAmount;
    final earns = offer.creditAvailable && credit != null && credit != '0.00';
    return Padding(
      padding: const EdgeInsets.fromLTRB(RSpace.s16, RSpace.s16, RSpace.s16, 0),
      child: RCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(earns ? 'Let RAWWERS feature your photos? Earn credit.' : 'Let RAWWERS feature your photos?', style: theme.textTheme.titleSmall),
            const SizedBox(height: RSpace.s4),
            Text(
              'Optional. You choose which photos and for how long'
              '${earns ? ', and earn up to ${creditAmount(credit, currency: term!.currency)} credit' : ''}. '
              'Credited to ${offer.photographerCredit ?? 'your photographer'}.',
              style: theme.textTheme.bodySmall,
            ),
            if (creditUnavailableText(offer) case final why?) ...[
              const SizedBox(height: RSpace.s4),
              Text(why, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: RSpace.s12),
            RButton(
              label: 'Choose photos',
              variant: RButtonVariant.secondary,
              onPressed: () => showRSheet<void>(context, builder: (_) => MarketingConsentForm(gigId: gigId, offer: offer, creditPath: creditPath)),
            ),
          ],
        ),
      ),
    );
  }
}

/// The choice itself: photos one by one (none ticked), a term (12 months
/// unless changed), the wording as the server sent it, and the confirmation
/// about the people shown (unticked).
class MarketingConsentForm extends ConsumerStatefulWidget {
  const MarketingConsentForm({required this.gigId, required this.offer, this.creditPath, super.key});

  final String gigId;
  final MarketingConsentOfferResponse offer;

  /// Where "See my credit" goes after credit is earned.
  final String? creditPath;

  @override
  ConsumerState<MarketingConsentForm> createState() => _MarketingConsentFormState();
}

class _MarketingConsentFormState extends ConsumerState<MarketingConsentForm> {
  final _chosen = <String>{};
  late int _term = widget.offer.defaultTermMonths;
  bool _confirmed = false;
  bool _sending = false;
  String? _error;

  Future<void> _send() async {
    setState(() {
      _sending = true;
      _error = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final router = GoRouter.maybeOf(context);
    final outcome = await ref
        .read(marketingOfferControllerProvider(widget.gigId).notifier)
        .grant(assetIds: _chosen.toList(), termMonths: _term, peopleConfirmed: _confirmed);
    if (!mounted) return;
    if (outcome.problem != null) {
      setState(() {
        _sending = false;
        _error = outcome.problem;
      });
      return;
    }
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          outcome.creditAmount != '0.00'
              ? 'Thank you. ${creditAmount(outcome.creditAmount, currency: outcome.currency)} credit added.'
              : 'Thank you. You can change this in Account > Marketing permissions.',
        ),
        action: outcome.creditAmount != '0.00' && widget.creditPath != null && router != null
            ? SnackBarAction(label: 'See my credit', onPressed: () => router.push(widget.creditPath!))
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photos = widget.offer.photos ?? const [];
    final terms = widget.offer.terms ?? const [];
    return Padding(
      padding: const EdgeInsets.all(RSpace.s16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Let RAWWERS feature your photos', style: theme.textTheme.titleMedium),
            const SizedBox(height: RSpace.s8),
            Text(widget.offer.wordingText ?? '', style: theme.textTheme.bodySmall),
            const SizedBox(height: RSpace.s16),
            Text('Which photos', style: theme.textTheme.titleSmall),
            const SizedBox(height: RSpace.s8),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: RSpace.s4,
              crossAxisSpacing: RSpace.s4,
              children: [
                for (final photo in photos)
                  GestureDetector(
                    key: ValueKey('marketing-photo-${photo.mediaAssetId}'),
                    // The whole tile, not only the drawn parts: a photo still
                    // without a thumbnail is mostly empty space.
                    behavior: HitTestBehavior.opaque,
                    onTap: _sending
                        ? null
                        : () => setState(() => _chosen.contains(photo.mediaAssetId)
                            ? _chosen.remove(photo.mediaAssetId)
                            : _chosen.add(photo.mediaAssetId)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (photo.thumbnailUrl case final url?) Image(image: DiskCachedImage(url), fit: BoxFit.cover),
                        Align(
                          alignment: Alignment.topRight,
                          child: Icon(
                            _chosen.contains(photo.mediaAssetId) ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: theme.colorScheme.primary,
                            semanticLabel: _chosen.contains(photo.mediaAssetId) ? 'Chosen' : 'Not chosen',
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: RSpace.s16),
            Text('For how long', style: theme.textTheme.titleSmall),
            const SizedBox(height: RSpace.s8),
            Wrap(
              spacing: RSpace.s8,
              children: [
                for (final t in terms)
                  ChoiceChip(
                    label: Text(
                      widget.offer.creditAvailable && t.creditAmount != '0.00'
                          ? '${t.months} months · ${creditAmount(t.creditAmount, currency: t.currency)}'
                          : '${t.months} months',
                    ),
                    selected: _term == t.months,
                    onSelected: _sending ? null : (_) => setState(() => _term = t.months),
                  ),
              ],
            ),
            const SizedBox(height: RSpace.s16),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _confirmed,
              onChanged: _sending ? null : (value) => setState(() => _confirmed = value ?? false),
              title: Text(
                'Everyone shown is an adult who agrees, or I am their parent or guardian.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: RSpace.s8),
              Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
            ],
            const SizedBox(height: RSpace.s16),
            RButton(
              label: _chosen.isEmpty ? 'Choose at least one photo' : 'Allow ${_chosen.length == 1 ? '1 photo' : '${_chosen.length} photos'}',
              onPressed: _chosen.isEmpty || !_confirmed || _sending ? null : _send,
              loading: _sending,
            ),
          ],
        ),
      ),
    );
  }
}


/// Said where the offer is made, before the client confirms: why this grant
/// would earn no credit. Permission can still be given.
String? creditUnavailableText(MarketingConsentOfferResponse offer) => switch (offer.creditUnavailableReason) {
      'budget' => 'No credit is available this month. You can still give permission.',
      'monthly_cap' => 'You have earned credit for 3 permissions this month, the most there is. You can still give permission, without credit.',
      'already_credited' => 'You have already earned credit for this booking.',
      _ => null,
    };
