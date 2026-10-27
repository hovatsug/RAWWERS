import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:rawwers/core/env.dart';
import 'package:rawwers/core/flavor.dart';
import 'package:rawwers/core/router/app_router_client.dart';
import 'package:rawwers/design/components/r_logo.dart';
import 'package:rawwers/design/theme_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The first frame (/launch) replaces the native launch screen: the logo
  // must be decoded by then, or it blinks out for a frame.
  await RLogo.precache();

  // Set before the first payment sheet is opened, which in practice means
  // before runApp. A build with no key configured still boots - only the
  // payment step is unavailable, and it says so rather than throwing from
  // inside the SDK.
  if (Env.hasStripe) {
    Stripe.publishableKey = Env.stripePublishableKey;
    await Stripe.instance.applySettings();
  }

  runApp(
    ProviderScope(
      overrides: [currentFlavorProvider.overrideWithValue(AppFlavor.client)],
      child: const RawwersClientApp(),
    ),
  );
}

class RawwersClientApp extends ConsumerWidget {
  const RawwersClientApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'RAWWERS',
      theme: buildClientTheme(),
      routerConfig: ref.watch(clientRouterProvider),
    );
  }
}
