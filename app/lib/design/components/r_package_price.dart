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
/// How much of the price story there is room to tell.
///
/// Replaces a `compact` flag that was declared and never passed anywhere - a
/// mode nothing exercised, which is the same shape of dead path this codebase
/// keeps finding. Both of these have call sites.
enum RPackagePriceDensity {
  /// A profile's package card: rate, the minimum and total it produces, and
  /// the curve line. Everything a client needs before requesting a booking.
  full,

  /// A Discover card, 148pt wide. The rate leads and the total follows on one
  /// short line. The minimum photo count and the curve line are dropped -
  /// not because they stop being true, but because a card that wraps to five
  /// lines stops being a card, and the profile is one tap away.
  card,
}


class RPackagePrice extends StatelessWidget {
  const RPackagePrice({
    required this.entryRate,
    required this.minimumPhotos,
    required this.startingTotal,
    required this.currency,
    this.density = RPackagePriceDensity.full,
    this.maxTotal,
    super.key,
  });

  /// Per photo. A decimal string, never a double.
  final String entryRate;
  final int minimumPhotos;

  /// What the smallest bookable selection costs. Server-computed by the same
  /// function the booking charges from.
  final String startingTotal;

  final String currency;

  final RPackagePriceDensity density;

  /// The dearest package's total, when a photographer has more than one and
  /// they differ. Shown only at card density, where this component stands in
  /// for a whole price list rather than one package.
  final String? maxTotal;

  String get _symbol => switch (currency.toUpperCase()) {
        'EUR' => '€',
        'GBP' => '£',
        'USD' => r'$',
        _ => '$currency ',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (density == RPackagePriceDensity.card) return _card(theme);

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
            // onSurfaceVariant, not outline. `outline` is the card's own
            // hairline border colour - one step from the card fill by design -
            // so using it as text rendered the starting total at 1.11:1
            // against a 4.5:1 requirement, in both themes. The line was
            // legible only on close inspection, which made this card look
            // like it disagreed with the Discover card when the two numbers
            // were identical.
            color: theme.colorScheme.onSurfaceVariant,
            fontFeatures: RType.tabularFigures,
          ),
        ),
        if (density == RPackagePriceDensity.full) ...[
          const SizedBox(height: RSpace.s4),
          // The accent carries this line because the decay curve is the one
          // fact most likely to change what a client books, and it should not
          // read as fine print. But meter500 at body size is 3.99:1 on the
          // client card and 3.75:1 on the pro card - past the 3:1 bar for
          // graphical objects, short of the 4.5:1 bar for text. The tokens
          // file's own rule is that the accent never carries body text
          // without a non-colour signal beside it.
          //
          // An icon rather than an underline. Underlines mean links in this
          // design language - RTextLink uses one for exactly this reason - and
          // borrowing that signal would make an explanatory line look
          // tappable. A downward trend is also the more literal statement:
          // sell_outlined already means "pricing" elsewhere in the app, and
          // the point here is not that this concerns price but that the price
          // falls.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.trending_down, size: 14, color: RAccent.meter500),
              const SizedBox(width: RSpace.s4),
              Flexible(
                child: Text(
                  'Price per photo drops as you choose more',
                  style: theme.textTheme.bodySmall?.copyWith(color: RAccent.meter500),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// Rate first and larger, total second and smaller - the same hierarchy the
  /// profile card uses, condensed. Built here rather than in the two card
  /// widgets because the ordering is the fix: this bug existed in five
  /// separate implementations before it had one.
  Widget _card(ThemeData theme) {
    final range = maxTotal != null && maxTotal != startingTotal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$_symbol$entryRate',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFeatures: RType.tabularFigures,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(text: ' /photo', style: theme.textTheme.bodySmall),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          range
              ? 'from $_symbol$startingTotal to $_symbol$maxTotal'
              : 'from $_symbol$startingTotal',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontFeatures: RType.tabularFigures,
          ),
        ),
      ],
    );
  }
}
