// Screenshots of the pro app's other tabs and editors, for a person to look
// at - not goldens. Skipped unless SCREENSHOT_DIR is set (see
// pro_you_screenshot_test.dart):
//
//   SCREENSHOT_DIR=/tmp/shots flutter test test/screenshots
//
// The tabs are shot inside the real ProShell, so the tab bar is in each one.
// The dates read en-GB, as on a Lisbon phone.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/booking_request_list_item.dart';
import 'package:rawwers/api/models/booking_request_status.dart';
import 'package:rawwers/api/models/chat_thread_status.dart';
import 'package:rawwers/api/models/chat_thread_summary.dart';
import 'package:rawwers/api/models/earnings_balance_view.dart';
import 'package:rawwers/api/models/earnings_entry_status.dart';
import 'package:rawwers/api/models/earnings_ledger_item_view.dart';
import 'package:rawwers/api/models/earnings_source_type.dart';
import 'package:rawwers/api/models/gig_response.dart';
import 'package:rawwers/api/models/gig_status.dart';
import 'package:rawwers/api/models/invoice_summary_view.dart';
import 'package:rawwers/api/models/notification_digest_mode.dart';
import 'package:rawwers/api/models/notification_preference_view.dart';
import 'package:rawwers/api/models/payout_account_status.dart';
import 'package:rawwers/api/models/payout_account_view.dart';
import 'package:rawwers/api/models/payout_method.dart';
import 'package:rawwers/api/models/pro_niche_pricing_preview_response.dart';
import 'package:rawwers/api/models/pro_package_view.dart';
import 'package:rawwers/api/models/pro_portfolio_item.dart';
import 'package:rawwers/api/models/pro_portfolio_response.dart';
import 'package:rawwers/api/models/pro_pricing_curve_point.dart';
import 'package:rawwers/api/models/pro_profile_view.dart';
import 'package:rawwers/core/paging/cursor_page.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/gigs/gigs_controller.dart';
import 'package:rawwers/features/pro/gigs/gigs_screen.dart';
import 'package:rawwers/features/pro/messages/pro_messages_controller.dart';
import 'package:rawwers/features/pro/messages/pro_messages_screen.dart';
import 'package:rawwers/features/pro/portfolio/niches_controller.dart';
import 'package:rawwers/features/pro/portfolio/portfolio_controller.dart';
import 'package:rawwers/features/pro/portfolio/portfolio_screen.dart';
import 'package:rawwers/features/pro/presence/presence_visibility_controller.dart';
import 'package:rawwers/features/pro/pricing/pricing_controller.dart';
import 'package:rawwers/features/pro/pricing/pricing_screen.dart';
import 'package:rawwers/features/pro/pro_shell.dart';
import 'package:rawwers/features/pro/requests/requests_controller.dart';
import 'package:rawwers/features/pro/requests/requests_screen.dart';
import 'package:rawwers/features/pro/settings/pro_settings_screen.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';
import 'package:rawwers/features/pro/wallet/summary_controller.dart';
import 'package:rawwers/features/pro/wallet/wallet_controller.dart';
import 'package:rawwers/features/pro/wallet/wallet_screen.dart';

import 'screenshot_support.dart';

final _now = DateTime.now().toUtc();
DateTime _days(int n, {int hour = 10}) {
  final d = _now.add(Duration(days: n));
  return DateTime.utc(d.year, d.month, d.day, hour);
}

// --- Requests ---------------------------------------------------------------

BookingRequestListItem _request(String id, {required int hoursLeft, required int inDays, String location = 'Alfama, Lisbon', String? notes}) =>
    BookingRequestListItem(
      id: id,
      proUserId: 'pro-me',
      clientUserId: 'client-$id',
      packageId: 'pkg-1',
      requestedStart: _days(inDays),
      requestedEnd: _days(inDays).add(const Duration(hours: 1)),
      locationText: location,
      notes: notes,
      status: BookingRequestStatus.pending,
      expiresAt: _now.add(Duration(hours: hoursLeft)),
      createdAt: _now,
      secondsUntilExpiry: hoursLeft * 3600 + 14 * 60,
    );

final _requests = [
  _request('r1', hoursLeft: 2, inDays: 4, notes: 'Family portraits by the river, golden hour if possible.'),
  _request('r2', hoursLeft: 19, inDays: 9, location: 'Ribeira, Porto'),
  _request('r3', hoursLeft: 40, inDays: 15, location: 'Cascais', notes: 'Headshots for a new website.'),
];

class _Requests extends RequestsController {
  @override
  Future<CursorPage<BookingRequestListItem>> build() async => CursorPage(items: _requests);
}

class _Pending extends PendingRequestsController {
  @override
  Future<PendingRequests> build() async => PendingRequests(_requests.length, items: _requests);
}

// --- Gigs -------------------------------------------------------------------

GigResponse _gig(String id, GigStatus status, int inDays, {String location = 'Alfama, Lisbon', String gross = '144.00'}) => GigResponse(
      id: id,
      clientUserId: 'client-$id',
      proUserId: 'pro-me',
      status: status,
      currency: 'EUR',
      amountMinimum: '180.00',
      amountPlatformFee: '36.00',
      amountProGross: gross,
      locationText: location,
      scheduledStart: _days(inDays),
      scheduledEnd: _days(inDays).add(const Duration(hours: 1)),
      createdAt: _days(-20),
      updatedAt: _days(-1),
    );

class _Gigs extends GigsController {
  @override
  Future<CursorPage<GigResponse>> build() async => CursorPage(items: [
        _gig('g1', GigStatus.scheduled, 3),
        _gig('g2', GigStatus.shootDone, -2, location: 'Belém, Lisbon'),
        _gig('g3', GigStatus.selectionPending, -6, location: 'Sintra', gross: '212.00'),
        _gig('g4', GigStatus.completed, -12, location: 'Ribeira, Porto'),
        _gig('g5', GigStatus.cancelledByClient, -15, location: 'Cascais'),
      ]);
}

// --- Messages ---------------------------------------------------------------

ChatThreadSummary _thread(String id, String client, String preview, {int unread = 0, int minutesAgo = 5}) => ChatThreadSummary(
      id: id,
      proUserId: 'pro-me',
      clientUserId: 'client-$id',
      status: ChatThreadStatus.open,
      createdAt: _days(-10),
      updatedAt: _now.subtract(Duration(minutes: minutesAgo)),
      clientDisplayName: client,
      unreadCount: unread,
      lastMessagePreview: preview,
      lastMessageAt: _now.subtract(Duration(minutes: minutesAgo)),
    );

class _Inbox extends ProMessagesController {
  @override
  Future<List<ChatThreadSummary>> build() async => [
        _thread('a', 'Rita Sousa', 'Are you free on the 14th?', unread: 2),
        _thread('b', 'Tomás Ferreira', 'Thanks! The photos are lovely.', minutesAgo: 190),
        _thread('c', 'Joana Lima', 'Could we move it to the afternoon?', minutesAgo: 60 * 30),
        _thread('d', 'Miguel Costa', 'Perfect, see you there.', minutesAgo: 60 * 24 * 9),
      ];
}

class _Unread extends ProUnreadController {
  @override
  Future<int> build() async => 2;
}

// --- Wallet -----------------------------------------------------------------

EarningsLedgerItemView _entry(String id, String net, EarningsEntryStatus status, int daysAgo) => EarningsLedgerItemView(
      id: id,
      sourceType: EarningsSourceType.gigBase,
      sourceId: 'g$id',
      grossEur: net,
      platformFeeEur: '0.00',
      netEur: net,
      status: status,
      availableAt: _days(-daysAgo + 7),
      createdAt: _days(-daysAgo),
    );

class _Wallet extends WalletController {
  @override
  Future<WalletData> build() async => WalletData(
        balance: const EarningsBalanceView(
          pendingEur: '144.00',
          availableEur: '412.50',
          heldEur: '15.96',
          requestedEur: '0.00',
          reservedEur: '0.00',
          paidOutEur: '1350.00',
          lifetimeEur: '1922.46',
          withdrawableEur: '412.50',
          adjustmentOwedEur: '0.00',
        ),
        ledger: [
          _entry('1', '144.00', EarningsEntryStatus.pending, 2),
          _entry('2', '212.00', EarningsEntryStatus.available, 9),
          _entry('3', '120.00', EarningsEntryStatus.available, 16),
        ],
        payouts: const [],
        account: PayoutAccountView(
          proUserId: 'pro-me',
          payoutMethod: PayoutMethod.stripeConnect,
          status: PayoutAccountStatus.active,
          updatedAt: DateTime.utc(2026, 9, 1),
        ),
      );
}

const _summary = InvoiceSummaryView(
  bookings: 14,
  gross: '2310.00',
  platformFees: '462.00',
  proRaww: '46.20',
  clientRaww: '23.10',
  proCash: '1778.70',
  averageGross: '165.00',
);

// --- Pricing ----------------------------------------------------------------

class _Packages extends PackagesController {
  @override
  Future<List<ProPackageView>> build() async => const [
        ProPackageView(
          id: 'pkg-1',
          proUserId: 'pro-me',
          nicheId: 'niche-portraits',
          title: 'Mini session',
          durationMinutes: 60,
          price: '12.00',
          currency: 'EUR',
          includedPhotos: 10,
          extraPhotoPrice: '8.00',
          proofsSlaDays: 3,
          finalsSlaDays: 7,
          addons: [],
          isActive: true,
          shortNoticeOk: true,
        ),
      ];
}

class _Niches extends NichesController {
  @override
  Future<List<NicheOption>> build() async => const [
        NicheOption(id: 'niche-portraits', slug: 'portraits', name: 'Portraits'),
        NicheOption(id: 'niche-weddings', slug: 'weddings', name: 'Weddings'),
      ];
}

const _preview = ProNichePricingPreviewResponse(
  nicheId: 'niche-portraits',
  nicheSlug: 'portraits',
  nicheName: 'Portraits',
  tier: 'rookie',
  entryPrice: '12.00',
  currency: 'EUR',
  entryPriceMin: '5.00',
  entryPriceMax: '20.00',
  withinCap: true,
  curve: [
    ProPricingCurvePoint(photoCount: 10, total: '120.00', perPhoto: '12.00'),
    ProPricingCurvePoint(photoCount: 25, total: '268.67', perPhoto: '10.75'),
    ProPricingCurvePoint(photoCount: 200, total: '1225.53', perPhoto: '6.13'),
  ],
);

// --- Portfolio --------------------------------------------------------------

class _Portfolio extends PortfolioController {
  @override
  Future<ProPortfolioResponse> build() async => ProPortfolioResponse(
        items: [
          for (var i = 0; i < 8; i++)
            ProPortfolioItem(
              mediaAssetId: 'a$i',
              kind: 'photo',
              status: 'ready',
              nicheSlugs: i.isEven ? const ['portraits'] : null,
              isCover: i == 0,
              createdAt: _days(-i),
            ),
        ],
        photoCount: 8,
        videoCount: 0,
        photoMinimum: 12,
      );
}

class _Uploads extends PortfolioUploadController {
  @override
  Map<String, UploadProgress> build() => const {};
}

// --- Settings ---------------------------------------------------------------

class _Profile extends ProProfileController {
  @override
  Future<ProProfileView> build() async => const ProProfileView(
        userId: 'pro-me',
        displayName: 'Alex Lens',
        headline: 'Portraits, quietly',
        city: 'Lisbon',
        country: 'PT',
        isAcceptingBookings: true,
        completenessScore: 92,
        kycStatus: 'approved',
        clientCreditPercent: 5,
        maxClientCreditPercent: 10,
      );
}

class _Prefs extends NotificationPreferencesController {
  @override
  Future<NotificationPreferenceView> build() async => const NotificationPreferenceView(
        timezone: 'Europe/Lisbon',
        quietHoursEnabled: false,
        channelEmailEnabled: false,
        channelInappEnabled: true,
        digestMode: NotificationDigestMode.instant,
      );
}

class _Visible extends PresenceVisibilityController {
  @override
  Future<bool> build() async => true;
}

// --- Assembly ---------------------------------------------------------------

List<Override> get _overrides => [
      requestsControllerProvider.overrideWith(_Requests.new),
      pendingRequestsControllerProvider.overrideWith(_Pending.new),
      gigsControllerProvider.overrideWith(_Gigs.new),
      proMessagesControllerProvider.overrideWith(_Inbox.new),
      proUnreadControllerProvider.overrideWith(_Unread.new),
      walletControllerProvider.overrideWith(_Wallet.new),
      earningsSummaryProvider.overrideWith((ref) async => _summary),
      packagesControllerProvider.overrideWith(_Packages.new),
      nichesControllerProvider.overrideWith(_Niches.new),
      pricingPreviewProvider(nicheId: 'niche-portraits', entryPrice: '12.00').overrideWith((ref) async => _preview),
      portfolioControllerProvider.overrideWith(_Portfolio.new),
      portfolioUploadControllerProvider.overrideWith(_Uploads.new),
      proProfileControllerProvider.overrideWith(_Profile.new),
      notificationPreferencesControllerProvider.overrideWith(_Prefs.new),
      payoutAccountProvider.overrideWith(
        (ref) async => PayoutAccountView(
          proUserId: 'pro-me',
          payoutMethod: PayoutMethod.stripeConnect,
          status: PayoutAccountStatus.active,
          updatedAt: DateTime.utc(2026, 9, 1),
        ),
      ),
      presenceVisibilityControllerProvider.overrideWith(_Visible.new),
    ];

Widget _app(String location, double textScale) {
  final router = GoRouter(
    initialLocation: location,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ProShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/you', builder: (context, state) => const Scaffold())]),
          StatefulShellBranch(routes: [GoRoute(path: '/requests', builder: (context, state) => const RequestsScreen())]),
          StatefulShellBranch(
            routes: [GoRoute(path: '/messages', builder: (context, state) => ProMessagesScreen(threadPath: (id) => '/messages/$id'))],
          ),
          StatefulShellBranch(routes: [GoRoute(path: '/gigs', builder: (context, state) => const GigsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/wallet', builder: (context, state) => const WalletScreen())]),
        ],
      ),
      GoRoute(path: '/pricing', builder: (context, state) => const PricingScreen()),
      GoRoute(path: '/portfolio', builder: (context, state) => const PortfolioScreen()),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const ProSettingsScreen(
          verifyEmailPath: '/verify',
          profileEditPath: '/profile',
          gearPath: '/gear',
          gearVerificationPath: '/gear-verification',
          portfolioPath: '/portfolio',
          pricingPath: '/pricing',
          onboardingPath: '/getting-set-up',
          listingPath: '/listing',
          payoutsPath: '/payouts',
          availabilityPath: '/availability',
          reviewsPath: '/reviews',
        ),
      ),
    ],
  );
  return ProviderScope(
    overrides: _overrides,
    child: MaterialApp.router(
      theme: buildProTheme(),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: (context, child) =>
          MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)), child: child!),
    ),
  );
}

void main() {
  setUpAll(() async {
    if (screenshotDir != null) await loadScreenshotFonts();
  });
  setUp(() => TestWidgetsFlutterBinding.instance.platformDispatcher.localeTestValue = const Locale('en', 'GB'));
  tearDown(() => TestWidgetsFlutterBinding.instance.platformDispatcher.clearLocaleTestValue());

  const screens = {
    'wallet': '/wallet',
    'requests': '/requests',
    'gigs': '/gigs',
    'messages': '/messages',
    'pricing': '/pricing',
    'portfolio': '/portfolio',
    'settings': '/settings',
  };
  for (final MapEntry(key: name, value: location) in screens.entries) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('screenshot $name at $scale', (tester) async {
        await shoot(tester, '$name-${scale == 1.0 ? '1.0' : '1.3'}', _app(location, scale));
      }, skip: screenshotDir == null);
    }
  }

  // The long screens, top to bottom.
  for (final name in ['wallet', 'pricing', 'settings']) {
    testWidgets('screenshot $name full page', (tester) async {
      await shoot(tester, '$name-full-page-1.0', _app(screens[name]!, 1.0), size: const Size(390, 2000));
    }, skip: screenshotDir == null);
  }
}
