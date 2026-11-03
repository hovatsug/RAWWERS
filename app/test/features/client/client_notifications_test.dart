import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/features/client/notifications/client_notifications_screen.dart';

import '../../support/fake_notifications.dart';

String? _route(String type, {String? url}) => clientNotificationRoute(
      notification(type: type, url: url),
      marketingPermissionsPath: '/account/marketing-permissions',
      bookingsPath: '/bookings',
    );

void main() {
  test('the marketing consent renewal opens the permissions', () {
    expect(_route('marketing_consent.renewal', url: '/account/marketing-permissions'), '/account/marketing-permissions');
    expect(_route('marketing_consent.renewal'), '/account/marketing-permissions');
  });

  test('booking and payment updates open Bookings', () {
    expect(_route('booking.request_accepted', url: '/client/bookings/0b0c5f3e-0000-0000-0000-000000000000'), '/bookings');
    expect(_route('payment.succeeded'), '/bookings');
  });

  test('anything else has nowhere to go', () {
    expect(_route('auth.new_login'), isNull);
  });
}
