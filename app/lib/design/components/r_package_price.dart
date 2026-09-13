import 'package:flutter/material.dart';
import 'package:rawwers/design/tokens.dart';

/// What a package costs, in the order the pricing model actually works.
///
/// This exists as one component rather than as copy repeated on five screens
/// because repeating it is how the bug it fixes happened. Every client-facing
/// surface rendered `package.price` as the package price. That field is the
/// per-photo entry rate, so a real package advertised EUR 243 for work that
/// charges EUR 6,075 - a 25x understatement above a "Request this package"
/// button.
///
/// The order is the argument:
///
///   - The per-photo rate leads, because that is what the client is buying
///     and the number the whole model is built from.
///   - The minimum photo count is second, because it is what turns a rate
///     into a commitment.
///   - The starting total is last and smallest. It is a consequence of the
///     first two, not the headline, and putting it first is what made the old
///     card read as a fixed-price package deal.
///   - The curve gets its own line. A client should know the eleventh photo
///     costs less than the first before they request a booking, not discover
///     it halfway through a selection.
///
/// Every figure is passed in as a decimal string from the server and rendered
/// verbatim. Nothing here multiplies: photos past the tenth follow the
/// niche's decay curve, so `entryRate * minimumPhotos` is right only on flat
/// niches and overstates a portrait package by EUR 1,679.
class RPackagePrice extends StatelessWidget {
  const RPackagePrice({
    required this.entryRate,
    required this.minimumPhotos,
    required this.startingTotal,
    required this.currency,
    this.compact = false,
    super.key,
  });

  /// Per photo. A decimal string, never a double.
  final String entryRate;
  final int minimumPhotos;

  /// What the smallest bookable selection costs. Server-computed by the same
  /// function the booking charges from.
  final String startingTotal;

  final String currency;

  /// Drops the curve line where vertical space is genuinely short. The three
  /// figures always survive: they are the price, and a shorter version that
  /// omits one of them is how this went wrong in the first place.
  final bool compact;

  String get _symbol => switch (currency.toUpperCase()) {
        'EUR' => '€',
        'GBP' => '£',
        'USD' => r'$',
        _ => '$currency ',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$_symbol$entryRate',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFeatures: RType.tabularFigures,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(text: ' /photo', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: RSpace.s4),
        Text(
          'minimum $minimumPhotos photos · from $_symbol$startingTotal',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
            fontFeatures: RType.tabularFigures,
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: RSpace.s4),
          Text(
            'Price per photo drops as you choose more',
            style: theme.textTheme.bodySmall?.copyWith(color: RAccent.meter500),
          ),
        ],
      ],
    );
  }
}
