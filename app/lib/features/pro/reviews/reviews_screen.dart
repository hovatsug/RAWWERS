import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/public_review_view.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/components/r_card.dart';
import 'package:rawwers/design/components/r_empty_state.dart';
import 'package:rawwers/design/components/r_error_state.dart';
import 'package:rawwers/design/components/r_input.dart';
import 'package:rawwers/design/components/r_sheet.dart';
import 'package:rawwers/design/components/r_skeleton.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/reviews/reply_controller.dart';
import 'package:rawwers/features/shared/reviews/pro_reviews_controller.dart';
import 'package:rawwers/features/shared/reviews/review_display.dart';

/// What clients have said about me, and my replies.
///
/// The same public list a client reads on the profile, so what shows here is
/// exactly what clients see - including that no reviewer is named. A review a
/// moderator hid is not in it; the photographer sees what the public sees.
class ProReviewsScreen extends ConsumerWidget {
  const ProReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = switch (ref.watch(authControllerProvider).valueOrNull) {
      AuthAuthenticated(:final me) => me,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Your reviews')),
      body: SafeArea(
        child: me == null ? const SizedBox.shrink() : _Reviews(proUserId: me.userId),
      ),
    );
  }
}

class _Reviews extends ConsumerWidget {
  const _Reviews({required this.proUserId});

  final String proUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reviews = ref.watch(proReviewsProvider(proUserId));

    return switch (reviews) {
      AsyncData(:final value) when value.items.isEmpty => const REmptyState(
          title: 'No reviews yet',
          body: 'Once a client has their photos, they can review the booking. Reviews appear here and on your profile.',
          icon: Icons.star_border,
        ),
      AsyncData(:final value) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(proReviewsProvider(proUserId)),
          child: ListView(
            padding: const EdgeInsets.all(RSpace.s16),
            children: [
              for (final review in value.items) ...[
                RCard(child: _ReviewWithReply(review: review, proUserId: proUserId)),
                const SizedBox(height: RSpace.s12),
              ],
              if (value.total > value.items.length)
                Text(
                  'Showing the ${value.items.length} most recent of ${value.total} reviews.',
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
      AsyncError() => RErrorState(
          message: 'Could not load your reviews.',
          onRetry: () => ref.invalidate(proReviewsProvider(proUserId)),
        ),
      _ => const Padding(padding: EdgeInsets.all(RSpace.s16), child: RSkeleton(height: 120)),
    };
  }
}

class _ReviewWithReply extends StatelessWidget {
  const _ReviewWithReply({required this.review, required this.proUserId});

  final PublicReviewView review;
  final String proUserId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReviewContent.public(review),
        // One reply per review, and it cannot be changed - so no button once
        // there is one, rather than a button the server would refuse.
        if (review.reply == null) ...[
          const SizedBox(height: RSpace.s12),
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              // RButton's theme gives it an infinite minimum width.
              constraints: const BoxConstraints(maxWidth: 160),
              child: RButton(
                label: 'Reply',
                variant: RButtonVariant.secondary,
                onPressed: () => showRSheet<void>(
                  context,
                  builder: (context) => _ReplyForm(reviewId: review.id, proUserId: proUserId),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ReplyForm extends ConsumerStatefulWidget {
  const _ReplyForm({required this.reviewId, required this.proUserId});

  final String reviewId;
  final String proUserId;

  @override
  ConsumerState<_ReplyForm> createState() => _ReplyFormState();
}

class _ReplyFormState extends ConsumerState<_ReplyForm> {
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final outcome = await ref
        .read(replyControllerProvider(widget.reviewId).notifier)
        .send(proUserId: widget.proUserId, text: _text.text);
    if (!mounted) return;
    switch (outcome) {
      case ReplyOutcome.sent:
        navigator.pop();
      case ReplyOutcome.alreadyReplied:
        navigator.pop();
        messenger.showSnackBar(const SnackBar(content: Text(alreadyRepliedMessage)));
      case ReplyOutcome.failed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(replyControllerProvider(widget.reviewId));
    final sending = state is ReplySending;

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
          Text('Reply to this review', style: theme.textTheme.titleMedium),
          const SizedBox(height: RSpace.s4),
          Text(
            'Your reply is public and can only be written once.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: RSpace.s16),
          RInput(label: 'Your reply', controller: _text, maxLines: 5),
          if (state case ReplyFailed(:final message)) ...[
            const SizedBox(height: RSpace.s12),
            Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: RShade.shade600)),
          ],
          const SizedBox(height: RSpace.s16),
          RButton(
            label: 'Post reply',
            loading: sending,
            onPressed: _text.text.trim().isEmpty || sending ? null : _send,
          ),
        ],
      ),
    );
  }
}
