import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/pro_reviews_response.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'pro_reviews_controller.g.dart';

/// How many reviews a page shows. The endpoint pages by offset; a profile
/// shows the most recent and says so rather than pretending to be complete.
const proReviewsPageSize = 20;

/// A photographer's published reviews, newest first - what a client sees on
/// their profile and what the photographer sees of themselves. One source for
/// both, so a reply the photographer writes is the reply the client reads.
@riverpod
Future<ProReviewsResponse> proReviews(Ref ref, String proUserId) async {
  final client = ref.read(reviewsClientProvider);
  final result = await apiCall(
    () => client.listProReviewsV1ProsProUserIdReviewsGet(
      proUserId: proUserId,
      limit: proReviewsPageSize,
      rating: null,
      authorization: null,
      xMinusUserMinusId: null,
    ),
  );
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}
