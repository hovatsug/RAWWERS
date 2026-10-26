import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/features/pro/dashboard/next_shoot.dart';
import 'package:rawwers/features/pro/gigs/gigs_controller.dart';
import 'package:rawwers/features/pro/requests/requests_controller.dart';
import 'package:rawwers/features/pro/wallet/wallet_controller.dart';
import 'package:rawwers/features/pro/listing/listing_preview_controller.dart';
import 'package:rawwers/features/pro/portfolio/portfolio_controller.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';
import 'package:rawwers/features/pro/tier/tier_controller.dart';

part 'dashboard_controller.g.dart';

/// Refreshing the dashboard, in one place.
///
/// Every block on the screen watches a shared provider rather than fetching
/// its own copy, so this is what a pull-to-refresh drives. Two reasons it is
/// centralised rather than left to each block:
///
///   - `GET /v1/pro/me/skills` recomputes twelve niches and commits before it
///     returns anything (docs/BACKEND_GAPS.md). Seven blocks refreshing
///     independently would mean several rounds of that on one pull.
///   - The blocks are not independent. Price and bookable days are read off
///     the listing preview, which is also what renders the card, so a pricing
///     or availability change has to invalidate the preview or the card goes
///     stale while the section above it looks correct.
@riverpod
class DashboardController extends _$DashboardController {
  @override
  void build() {}

  Future<void> refreshAll() async {
    ref.invalidate(proProfileControllerProvider);
    ref.invalidate(listingPreviewControllerProvider);
    ref.invalidate(portfolioControllerProvider);
    ref.invalidate(todayControllerProvider);
    // The band's money and the You tab's lists read these.
    ref.invalidate(walletControllerProvider);
    ref.invalidate(nextShootProvider);
    ref.invalidate(gigsControllerProvider);
    ref.invalidate(pendingRequestsControllerProvider);
    await ref.read(tierStandingsControllerProvider.notifier).refresh();
  }

  /// Called after an edit made elsewhere - pricing, availability, portfolio -
  /// so the card and the sections that read from it cannot disagree with the
  /// editor the photographer just left.
  void invalidateListingDerived() {
    ref.invalidate(listingPreviewControllerProvider);
  }
}
