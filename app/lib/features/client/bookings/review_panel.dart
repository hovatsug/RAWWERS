import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/client_booking_status_response.dart';
import 'package:rawwers/api/models/review_status.dart';
import 'package:rawwers/api/models/review_view.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/components/r_sheet.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/client/bookings/review_controller.dart';
import 'package:rawwers/features/shared/reviews/review_display.dart';

/// What the booking screen should say about reviewing, from what the server
/// sent. Null when there is nothing to say yet.
Widget? reviewPanelFor(String bookingId, ClientBookingStatusResponse booking) {
  // Checked first: a review exists whatever the gig has done since.
  if (booking.review case final review?) return _YourReview(review: review);

  final gigId = booking.gigId;
  if (gigId == null || !reviewableGigStatuses.contains(booking.gigStatus)) return null;
  return _ReviewInvite(bookingId: bookingId, gigId: gigId);
}

class _ReviewInvite extends StatelessWidget {
  const _ReviewInvite({required this.bookingId, required this.gigId});

  final String bookingId;
  final String gigId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How did it go?', style: theme.textTheme.titleSmall),
          const SizedBox(height: RSpace.s4),
          Text(
            'Your review helps other clients choose, and it can only be written once.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: RSpace.s12),
          RButton(
            label: 'Leave a review',
            onPressed: () => showRSheet<void>(
              context,
              builder: (context) => ReviewForm(bookingId: bookingId, gigId: gigId),
            ),
          ),
        ],
      ),
    );
  }
}

class _YourReview extends StatelessWidget {
  const _YourReview({required this.review});

  final ReviewView review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final public = review.status == ReviewStatus.published;
    return RCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your review', style: theme.textTheme.titleSmall),
          const SizedBox(height: RSpace.s8),
          ReviewContent(
            rating: review.rating,
            wouldBookAgain: review.wouldBookAgain,
            provenance: 'Written ${reviewDate(review.createdAt)}',
            text: review.text,
            replyText: review.reply?.text,
          ),
          // A hidden review is still theirs; saying nothing would leave them
          // believing others can read it.
          if (!public) ...[
            const SizedBox(height: RSpace.s12),
            Text(
              'This review is not shown publicly. It was held back by our moderators.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

/// The form itself: a rating, whether they would book again, and optional
/// words. Exactly what the review model can hold, minus the two fields with
/// nothing to fill them (tags, video).
class ReviewForm extends ConsumerStatefulWidget {
  const ReviewForm({required this.bookingId, required this.gigId, super.key});

  final String bookingId;
  final String gigId;

  @override
  ConsumerState<ReviewForm> createState() => _ReviewFormState();
}

/// The server's limit (MAX_REVIEW_TEXT_LENGTH). Checked here only so a long
/// review is caught before sending, with the words still in the box.
const reviewTextLimit = 2000;

class _ReviewFormState extends ConsumerState<ReviewForm> {
  final _text = TextEditingController();
  int? _rating;
  bool? _wouldBookAgain;
  String? _textError;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_text.text.trim().length > reviewTextLimit) {
      setState(() => _textError = 'Keep it under 2,000 characters.');
      return;
    }
    setState(() => _textError = null);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await ref.read(reviewSubmitControllerProvider(widget.bookingId).notifier).submit(
          gigId: widget.gigId,
          rating: _rating!,
          wouldBookAgain: _wouldBookAgain!,
          text: _text.text,
        );
    if (!mounted) return;
    switch (outcome) {
      case ReviewSubmitOutcome.sent:
        navigator.pop();
      case ReviewSubmitOutcome.alreadyReviewed:
        navigator.pop();
        messenger.showSnackBar(const SnackBar(content: Text(alreadyReviewedMessage)));
      case ReviewSubmitOutcome.failed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(reviewSubmitControllerProvider(widget.bookingId));
    final sending = state is ReviewSending;
    // Both are required answers. Neither has a default: a pre-filled rating
    // or "yes" would be the form answering for the client.
    final complete = _rating != null && _wouldBookAgain != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        RSpace.s16,
        RSpace.s16,
        RSpace.s16,
        RSpace.s16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Leave a review', style: theme.textTheme.titleMedium),
          const SizedBox(height: RSpace.s16),
          Text('Your rating', style: theme.textTheme.labelLarge),
          Row(
            children: [
              for (var star = 1; star <= 5; star++)
                IconButton(
                  tooltip: '$star star${star == 1 ? '' : 's'}',
                  isSelected: _rating != null && star <= _rating!,
                  icon: const Icon(Icons.star_border),
                  selectedIcon: const Icon(Icons.star),
                  onPressed: sending ? null : () => setState(() => _rating = star),
                ),
            ],
          ),
          const SizedBox(height: RSpace.s12),
          Text('Would you book them again?', style: theme.textTheme.labelLarge),
          const SizedBox(height: RSpace.s8),
          Row(
            children: [
              RFilterChip(
                label: 'Yes',
                selected: _wouldBookAgain == true,
                onPressed: () => setState(() => _wouldBookAgain = true),
              ),
              const SizedBox(width: RSpace.s8),
              RFilterChip(
                label: 'No',
                selected: _wouldBookAgain == false,
                onPressed: () => setState(() => _wouldBookAgain = false),
              ),
            ],
          ),
          const SizedBox(height: RSpace.s16),
          RInput(
            label: 'What was it like? (optional)',
            controller: _text,
            maxLines: 5,
            errorText: _textError,
          ),
          if (state case ReviewFailed(:final message)) ...[
            const SizedBox(height: RSpace.s12),
            Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: RShade.shade600)),
          ],
          const SizedBox(height: RSpace.s16),
          RButton(
            label: 'Post review',
            loading: sending,
            onPressed: complete && !sending ? _submit : null,
          ),
        ],
      ),
    );
  }
}
