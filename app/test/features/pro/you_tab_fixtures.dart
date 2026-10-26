// Fake data for the You tab, shared by its tests and the screenshot harness.
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rawwers/api/models/booking_request_list_item.dart';
import 'package:rawwers/api/models/booking_request_status.dart';
import 'package:rawwers/api/models/earnings_balance_view.dart';
import 'package:rawwers/api/models/gig_response.dart';
import 'package:rawwers/api/models/gig_status.dart';
import 'package:rawwers/api/models/payout_account_status.dart';
import 'package:rawwers/api/models/payout_account_view.dart';
import 'package:rawwers/api/models/payout_method.dart';
import 'package:rawwers/api/models/pro_niche_skill_list_response.dart';
import 'package:rawwers/api/models/pro_profile_view.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/paging/cursor_page.dart';
import 'package:rawwers/design/theme_pro.dart';
import 'package:rawwers/features/pro/dashboard/dashboard_screen.dart';
import 'package:rawwers/features/pro/dashboard/next_shoot.dart';
import 'package:rawwers/features/pro/gigs/gigs_controller.dart';
import 'package:rawwers/features/pro/requests/requests_controller.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';
import 'package:rawwers/features/pro/tier/tier_breakdown.dart';
import 'package:rawwers/features/pro/tier/tier_controller.dart';
import 'package:rawwers/features/pro/wallet/wallet_controller.dart';

import '../../support/fake_http_client_adapter.dart';

WalletData wallet({
  String withdrawable = '41.95',
  String? available,
  String pending = '120.00',
  String held = '15.96',
  PayoutAccountStatus account = PayoutAccountStatus.active,
}) =>
    WalletData(
      balance: EarningsBalanceView(
        pendingEur: pending,
        availableEur: available ?? withdrawable,
        heldEur: held,
        reservedEur: '0.00',
        withdrawableEur: withdrawable,
      ),
      ledger: const [],
      payouts: const [],
      account: PayoutAccountView(
        proUserId: 'pro-me',
        payoutMethod: PayoutMethod.stripeConnect,
        status: account,
        updatedAt: DateTime.utc(2026, 9, 1),
      ),
    );

GigResponse gig({required String id, required GigStatus status, required DateTime start, String location = 'Alfama, Lisbon'}) => GigResponse(
      id: id,
      clientUserId: 'client-1',
      proUserId: 'pro-me',
      status: status,
      currency: 'EUR',
      amountMinimum: '180.00',
      amountPlatformFee: '36.00',
      amountProGross: '144.00',
      locationText: location,
      scheduledStart: start,
      scheduledEnd: start.add(const Duration(hours: 1)),
      createdAt: DateTime.utc(2026, 10, 1),
      updatedAt: DateTime.utc(2026, 10, 1),
    );

BookingRequestListItem request({required String id, required int secondsLeft, required DateTime start}) => BookingRequestListItem(
      id: id,
      proUserId: 'pro-me',
      clientUserId: 'client-2',
      packageId: 'pkg-1',
      requestedStart: start,
      requestedEnd: start.add(const Duration(hours: 1)),
      status: BookingRequestStatus.pending,
      expiresAt: DateTime.now().add(Duration(seconds: secondsLeft)),
      createdAt: DateTime.now(),
      secondsUntilExpiry: secondsLeft,
    );

class FakeWallet extends WalletController {
  FakeWallet(this._data);
  final WalletData? _data;
  @override
  Future<WalletData> build() async => _data ?? (throw Exception('down'));
}

class FakePending extends PendingRequestsController {
  FakePending(this._items);
  final List<BookingRequestListItem> _items;
  @override
  Future<PendingRequests> build() async => PendingRequests(_items.length, items: _items);
}

class FakeGigs extends GigsController {
  FakeGigs(this._items);
  final List<GigResponse> _items;
  @override
  Future<CursorPage<GigResponse>> build() async => CursorPage(items: _items, nextCursor: null);
}

class FakeProfile extends ProProfileController {
  @override
  Future<ProProfileView> build() async => const ProProfileView(
        userId: 'pro-me',
        displayName: 'Alex Lens',
        headline: 'Portraits, quietly',
        city: 'Lisbon',
        country: 'PT',
        isAcceptingBookings: true,
        completenessScore: 90,
        kycStatus: 'approved',
      );
}

class FakeStandings extends TierStandingsController {
  @override
  Future<TierStandings> build() async {
    final raw = jsonDecode(File('test/fixtures/pro_skills_response.json').readAsStringSync()) as Map<String, dynamic>;
    final skill = ProNicheSkillListResponse.fromJson(raw).items!.first;
    final breakdown = TierBreakdown.parse(skill.breakdown);
    return TierStandings(
      standings: [NicheStanding(skill: skill, breakdown: breakdown, progress: TierProgress.of(skill, breakdown), isPrimary: true)],
      hasChosenNiches: true,
    );
  }
}

/// Only Available now is served over HTTP; every other route answers 404, so
/// a block nobody faked shows its own error state rather than reaching out.
Future<ResponseBody> backend(RequestOptions o, {bool availableNowFails = false}) async {
  if (o.uri.path == '/v1/pro/available-now' && o.method == 'GET') {
    if (availableNowFails) return jsonResponseBody('{"error":{"code":"internal_error","message":"boom"}}', 500);
    return jsonResponseBody(
      jsonEncode({
        'switched_on': false,
        'available_until': null,
        'effective': false,
        'prep_minutes': 120,
        'prep_options_minutes': [90, 120, 180],
        'eligible_package_ids': ['pkg-1'],
        'lasts_hours': 4,
      }),
      200,
    );
  }
  return jsonResponseBody('{"error":{"code":"not_found","message":"no route in fake"}}', 404);
}

Widget youTab({
  WalletData? walletData,
  bool walletFails = false,
  GigResponse? next,
  List<GigResponse> gigs = const [],
  List<BookingRequestListItem> pending = const [],
  bool availableNowFails = false,
  double textScale = 1.0,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
    ..httpClientAdapter = FakeHttpClientAdapter((o) => backend(o, availableNowFails: availableNowFails));
  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(
          settingsPath: '/settings',
          profilePath: '/profile',
          portfolioPath: '/portfolio',
          pricingPath: '/pricing',
          availabilityPath: '/availability',
          listingPath: '/listing',
          onboardingPath: '/onboarding',
          interviewPath: '/interview',
          walletPath: '/wallet',
        ),
      ),
      GoRoute(path: '/wallet', builder: (context, state) => const Scaffold(body: Text('The Wallet'))),
    ],
  );
  return ProviderScope(
    overrides: [
      dioProvider.overrideWithValue(dio),
      walletControllerProvider.overrideWith(() => FakeWallet(walletFails ? null : (walletData ?? wallet()))),
      nextShootProvider.overrideWith((ref) async => next),
      gigsControllerProvider.overrideWith(() => FakeGigs(gigs)),
      pendingRequestsControllerProvider.overrideWith(() => FakePending(pending)),
      proProfileControllerProvider.overrideWith(FakeProfile.new),
      tierStandingsControllerProvider.overrideWith(FakeStandings.new),
    ],
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale), padding: const EdgeInsets.only(top: 47)),
      child: MaterialApp.router(theme: buildProTheme(), routerConfig: router, debugShowCheckedModeBanner: false),
    ),
  );
}
