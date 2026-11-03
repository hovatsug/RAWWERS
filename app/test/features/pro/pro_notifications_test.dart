import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/features/pro/notifications/pro_notifications_screen.dart';

import '../../support/fake_notifications.dart';

String? _route(String type, {String? url}) => proNotificationRoute(
      notification(type: type, url: url),
      shelfPath: '/wallet/shelf',
      shelfOrdersPath: '/wallet/shelf/orders',
      requestsPath: '/requests',
      walletPath: '/wallet',
    );

void main() {
  test('order updates open My orders', () {
    expect(_route('shelf.order_shipped', url: '/wallet/shelf/orders'), '/wallet/shelf/orders');
    expect(_route('shelf.order_refunded'), '/wallet/shelf/orders');
  });

  test('the RAWW expiry warning opens The Shelf', () {
    expect(_route('shelf.raww_expiring', url: '/wallet/shelf'), '/wallet/shelf');
    expect(_route('shelf.raww_expired'), '/wallet/shelf');
  });

  test('a booking request opens Requests, a payout the Wallet', () {
    expect(_route('booking.request_received'), '/requests');
    expect(_route('payout.requested'), '/wallet');
  });

  test('anything else has nowhere to go', () {
    expect(_route('gear.verified'), isNull);
    expect(_route('finding.recorded', url: '/pro/findings'), isNull);
  });
}
