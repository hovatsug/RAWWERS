// Stand-ins for the photographer's marketing-consent controllers, for screen
// tests that show the cards without testing them (they are tested in
// test/features/pro/marketing_cards_test.dart).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/api/models/booking_marketing_settings_view.dart';
import 'package:rawwers/api/models/pro_marketing_agreement_view.dart';
import 'package:rawwers/features/pro/marketing/marketing_controllers.dart';

class FakeMarketingAgreement extends MarketingAgreementController {
  FakeMarketingAgreement([this.value = const ProMarketingAgreementView(optedIn: false, wordingVersion: 'photographer-draft-1', wordingText: 'DRAFT clause')]);

  ProMarketingAgreementView value;
  final sets = <bool>[];

  @override
  Future<ProMarketingAgreementView> build() async => value;

  @override
  Future<String?> set(bool optedIn) async {
    sets.add(optedIn);
    value = value.copyWith(optedIn: optedIn, recordedAt: DateTime.utc(2026, 11, 2));
    state = AsyncData(value);
    return null;
  }
}

class FakeBookingMarketing extends BookingMarketingController {
  FakeBookingMarketing([this.value = const BookingMarketingSettingsView(allowMarketing: true, includesChildren: false, locked: false, optedIn: true)]);

  BookingMarketingSettingsView value;
  final sets = <({bool? allowMarketing, bool? includesChildren})>[];

  @override
  Future<BookingMarketingSettingsView> build(String gigId) async => value;

  @override
  Future<String?> set({bool? allowMarketing, bool? includesChildren}) async {
    sets.add((allowMarketing: allowMarketing, includesChildren: includesChildren));
    value = value.copyWith(
      allowMarketing: allowMarketing ?? value.allowMarketing,
      includesChildren: includesChildren ?? value.includesChildren,
    );
    state = AsyncData(value);
    return null;
  }
}

/// Overrides for a screen that shows the marketing cards for [gigId] (or
/// the settings card only, without a gig).
List<Override> marketingOverrides({String? gigId}) => [
      marketingAgreementControllerProvider.overrideWith(FakeMarketingAgreement.new),
      if (gigId != null) bookingMarketingControllerProvider(gigId).overrideWith(FakeBookingMarketing.new),
    ];
