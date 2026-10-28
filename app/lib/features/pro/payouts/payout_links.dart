import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/features/pro/payouts/payouts_controller.dart';
import 'package:rawwers/features/pro/settings/settings_controller.dart';
import 'package:rawwers/features/pro/wallet/wallet_controller.dart';
import 'package:url_launcher/url_launcher.dart';

part 'payout_links.g.dart';

/// The pro app's URL scheme. Registered by the pro flavor only (iOS
/// Info-Pro.plist, Android src/pro), and the scheme the API's return pages
/// hand over to (api/app/services/connect_return.py).
const proAppScheme = 'rawwerspro';

/// A return from Stripe's hosted onboarding: `rawwerspro://payouts/...`.
///
/// Only the scheme and host are looked at. Whatever else the address
/// carries is never read: the link is a hint that the photographer is back,
/// and the truth is what the server says when asked.
bool isPayoutReturn(Uri uri) => uri.scheme == proAppScheme && uri.host == 'payouts';

/// The device side of payout setup: opening Stripe's form, closing it, and
/// the links that come back. A seam, like PaymentSheetLauncher: the browser
/// and the link stream are platform singletons a test cannot drive.
abstract interface class PayoutLinkPlatform {
  /// Opens [url] in the in-app browser where the platform has one. False
  /// when nothing could open it.
  Future<bool> open(Uri url);

  /// Closes the in-app browser if it is still showing.
  Future<void> closeBrowser();

  /// Links the app is opened with, while it runs.
  Stream<Uri> get incoming;
}

class DevicePayoutLinkPlatform implements PayoutLinkPlatform {
  DevicePayoutLinkPlatform();

  final _links = AppLinks();

  @override
  Future<bool> open(Uri url) async {
    try {
      return await launchUrl(url, mode: LaunchMode.inAppBrowserView);
    } on Exception {
      return false;
    }
  }

  @override
  Future<void> closeBrowser() async {
    try {
      await closeInAppWebView();
    } on Exception {
      // Nothing open, or a platform without an in-app browser.
    }
  }

  @override
  Stream<Uri> get incoming => _links.uriLinkStream;
}

@Riverpod(keepAlive: true)
PayoutLinkPlatform payoutLinkPlatform(Ref ref) => DevicePayoutLinkPlatform();

/// Asks the server where payout setup stands, then refreshes everything that
/// shows it.
///
/// The live Connect status first: the server reconciles the stored status
/// with Stripe while answering it, so the Wallet and Settings, which read
/// the stored status, are refreshed after it rather than alongside it.
Future<void> refetchPayoutStatus(WidgetRef ref) async {
  final keep = ref.listenManual(connectStatusControllerProvider, (_, _) {});
  try {
    ref.invalidate(connectStatusControllerProvider);
    await ref.read(connectStatusControllerProvider.future);
  } on Object {
    // The Payouts screen shows its own error; the others still refresh.
  } finally {
    keep.close();
  }
  ref.invalidate(payoutAccountProvider);
  ref.invalidate(walletControllerProvider);
}

/// Notices a photographer coming back from Stripe - by the return link, or
/// by switching back to the app after leaving the browser some other way -
/// and asks the server where setup stands. Nothing else: it does not
/// navigate, and it never reads the link beyond recognising it.
class PayoutReturnListener extends ConsumerStatefulWidget {
  const PayoutReturnListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<PayoutReturnListener> createState() => _PayoutReturnListenerState();
}

class _PayoutReturnListenerState extends ConsumerState<PayoutReturnListener> {
  StreamSubscription<Uri>? _links;
  late final AppLifecycleListener _lifecycle;

  /// The re-read in flight. Coming back by the return link also resumes
  /// the app, so the two arrive together (3 ms apart in the simulator);
  /// they share one re-read rather than asking Stripe twice.
  Future<void>? _refetching;

  Future<void> _refetch() {
    if (!mounted) return Future.value();
    return _refetching ??= refetchPayoutStatus(ref).whenComplete(() => _refetching = null);
  }

  @override
  void initState() {
    super.initState();
    final platform = ref.read(payoutLinkPlatformProvider);
    _links = platform.incoming.listen((uri) async {
      if (!isPayoutReturn(uri)) return;
      final refetched = _refetch();
      await platform.closeBrowser();
      await refetched;
    }, onError: (Object _) {});
    _lifecycle = AppLifecycleListener(onResume: _refetch);
  }

  @override
  void dispose() {
    _links?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
