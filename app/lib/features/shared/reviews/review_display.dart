import 'package:flutter/material.dart';
import 'package:rawwers/core/format/dates.dart';
import 'package:rawwers/api/models/public_review_view.dart';
import 'package:rawwers/design/tokens.dart';

/// A 1-5 rating as five stars. Read out as a number, not as five icons.
class ReviewStars extends StatelessWidget {
  const ReviewStars({required this.rating, this.size = 16, super.key});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Rated $rating out of 5',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++) Icon(i <= rating ? Icons.star : Icons.star_border, size: size),
        ],
      ),
    );
  }
}

/// One review's content: rating, what it came from, the words, and any reply.
///
/// Shared by everywhere a review is read - a photographer's public profile,
/// their own list of reviews, and the client's view of the one they wrote - so
/// the three cannot disagree about what a review shows.
class ReviewContent extends StatelessWidget {
  const ReviewContent({
    required this.rating,
    required this.wouldBookAgain,
    required this.provenance,
    this.text,
    this.replyText,
    super.key,
  });

  /// Built from a review as the public sees it.
  ReviewContent.public(PublicReviewView review, {Key? key})
      : this(
          key: key,
          rating: review.rating,
          wouldBookAgain: review.wouldBookAgain,
          // No reviewer: the public list deliberately carries no client. What
          // makes it trustworthy is that it came from a real booking.
          provenance: 'Verified booking · ${review.niche.name} · ${reviewDate(review.createdAt)}',
          text: review.text,
          replyText: review.reply?.text,
        );

  final int rating;
  final bool wouldBookAgain;

  /// The line under the stars saying where the review comes from and when.
  final String provenance;
  final String? text;
  final String? replyText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final words = text?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReviewStars(rating: rating),
        const SizedBox(height: RSpace.s4),
        Text(provenance, style: theme.textTheme.bodySmall),
        if (words != null && words.isNotEmpty) ...[
          const SizedBox(height: RSpace.s8),
          Text(words, style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: RSpace.s8),
        Text(wouldBookAgain ? 'Would book again' : 'Would not book again', style: theme.textTheme.bodySmall),
        if (replyText case final reply?) ...[
          const SizedBox(height: RSpace.s12),
          Padding(
            padding: const EdgeInsets.only(left: RSpace.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reply from the photographer', style: theme.textTheme.labelLarge),
                const SizedBox(height: RSpace.s4),
                Text(reply, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// A review's date, as every dated record reads: "27 Oct 2026".
String reviewDate(DateTime at) => RDates.forLocale(WidgetsBinding.instance.platformDispatcher.locale).date(at);
