import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/gig_response.dart';
import 'package:rawwers/api/models/user_role_type.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';
import 'package:rawwers/core/launch/launch_screen.dart';
import 'package:rawwers/features/pro/availability/availability_screen.dart';
import 'package:rawwers/features/pro/delivery/delivery_gallery_screen.dart';
import 'package:rawwers/features/pro/gear/gear_screen.dart';
import 'package:rawwers/features/pro/gear_verification/gear_verification_screen.dart';
import 'package:rawwers/features/pro/listing/listing_preview_screen.dart';
import 'package:rawwers/features/pro/onboarding/onboarding_screen.dart';
import 'package:rawwers/features/pro/payouts/payouts_screen.dart';
import 'package:rawwers/features/pro/gigs/gigs_screen.dart';
import 'package:rawwers/features/pro/profile/pro_profile_edit_screen.dart';
import 'package:rawwers/features/pro/portfolio/portfolio_screen.dart';
import 'package:rawwers/features/pro/pricing/pricing_screen.dart';
import 'package:rawwers/features/pro/pro_shell.dart';
import 'package:rawwers/features/pro/requests/requests_screen.dart';
import 'package:rawwers/features/pro/settings/pro_settings_screen.dart';
import 'package:rawwers/features/pro/dashboard/dashboard_screen.dart';
import 'package:rawwers/features/pro/upgrade/upgrade_to_pro_screen.dart';
import 'package:rawwers/features/pro/wallet/invoice_screen.dart';
import 'package:rawwers/features/pro/wallet/wallet_screen.dart';
import 'package:rawwers/features/shared/auth/forgot_password_screen.dart';
import 'package:rawwers/features/shared/auth/login_screen.dart';
import 'package:rawwers/features/shared/auth/register_screen.dart';
import 'package:rawwers/features/shared/auth/reset_password_screen.dart';
import 'package:rawwers/features/shared/auth/verify_email_screen.dart';

part 'app_router_pro.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// A full-screen detail view opened from the dashboard.
///
/// On the root navigator so it covers the bottom nav, and a direct child of the
/// dashboard so back returns there rather than into a menu. Both halves matter:
/// these were briefly nested under `settings`, which - because the parent
/// declared the root navigator while its children rendered on the shell - drew
/// the parent above its own child, so every Edit on the dashboard opened the
/// settings menu instead of the editor.
GoRoute _editor(String path, Widget Function(BuildContext, GoRouterState) builder) =>
    GoRoute(path: path, parentNavigatorKey: _rootNavigatorKey, builder: builder);

/// Route paths for the pro flavor. Kept as named constants rather than
/// string literals scattered through the app, so a typo in a path is a
/// compile error at the call site, not a runtime 404.
///
/// The paths are hierarchical because the routes are: every destination is
/// declared as a child of the screen it is opened from, so navigating to it
/// builds a real stack and Material draws a back arrow without any screen
/// having to supply one. Declaring these as flat siblings - `/settings/gear`
/// next to `/settings` rather than inside it - is what previously made
/// thirteen screens dead ends. See test/core/router/back_navigation_test.dart.
abstract final class ProRoute {
  static const launch = '/launch';

  /// Login is the auth entry point, and register/forgot/reset are its
  /// children so that each one stacks on top of it.
  static const login = '/auth';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';

  static const upgradeToPro = '/upgrade-to-pro';

  static const dashboard = '/dashboard';
  static const requests = '/requests';
  static const gigs = '/gigs';
  static const wallet = '/wallet';

  /// Settings and everything opened from it hang off the dashboard, so the
  /// way back is always the screen you came from.
  static const settings = '$dashboard/settings';
  static const profileEdit = '$dashboard/profile';
  static const gear = '$dashboard/gear';
  static const gearVerification = '$dashboard/gear-verification';
  static const portfolio = '$dashboard/portfolio';
  static const pricing = '$dashboard/pricing';
  static const payouts = '$dashboard/payouts';
  static const availability = '$dashboard/availability';
  static const listing = '$dashboard/listing';
  static const onboarding = '$dashboard/getting-set-up';
  static const verifyEmail = '$dashboard/verify-email';

  static const gigDelivery = '$gigs/delivery';

  /// One gig's invoice, opened from a Wallet earnings row.
  static const invoice = '$wallet/invoice';
}

@Riverpod(keepAlive: true)
GoRouter proRouter(Ref ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: ProRoute.launch,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthRoute = location.startsWith('/auth');
      final isLaunch = location == ProRoute.launch;
      final isUpgrade = location == ProRoute.upgradeToPro;

      if (authState.isLoading) {
        return isLaunch ? null : ProRoute.launch;
      }

      final resolved = authState.valueOrNull;
      if (resolved == null || resolved is AuthUnauthenticated) {
        return isAuthRoute ? null : ProRoute.login;
      }

      // AuthAuthenticated - every account starts client-only (register
      // always grants the client role, never pro; checked against the
      // real backend), so this gate is the common case for a fresh
      // sign-up, not an edge case.
      final me = (resolved as AuthAuthenticated).me;
      final hasProRole = me.roles?.contains(UserRoleType.pro) ?? false;
      if (!hasProRole) {
        return isUpgrade ? null : ProRoute.upgradeToPro;
      }

      return (isAuthRoute || isLaunch || isUpgrade) ? ProRoute.dashboard : null;
    },
    routes: [
      GoRoute(
        path: ProRoute.launch,
        builder: (context, state) => const LaunchScreen(title: 'RAWWERS Pro'),
      ),
      GoRoute(
        path: ProRoute.login,
        builder: (context, state) => const LoginScreen(registerPath: ProRoute.register, forgotPasswordPath: ProRoute.forgotPassword),
        routes: [
          GoRoute(
            path: 'register',
            builder: (context, state) => const RegisterScreen(loginPath: ProRoute.login),
          ),
          GoRoute(
            path: 'forgot-password',
            builder: (context, state) => const ForgotPasswordScreen(resetPasswordPath: ProRoute.resetPassword),
          ),
          GoRoute(
            path: 'reset-password',
            builder: (context, state) => const ResetPasswordScreen(loginPath: ProRoute.login),
          ),
        ],
      ),
      GoRoute(path: ProRoute.upgradeToPro, builder: (context, state) => const UpgradeToProScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ProShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ProRoute.dashboard,
                builder: (context, state) => const DashboardScreen(
                  settingsPath: ProRoute.settings,
                  profilePath: ProRoute.profileEdit,
                  portfolioPath: ProRoute.portfolio,
                  pricingPath: ProRoute.pricing,
                  availabilityPath: ProRoute.availability,
                  listingPath: ProRoute.listing,
                  onboardingPath: ProRoute.onboarding,
                ),
                routes: [
                  _editor('settings', (context, state) => const ProSettingsScreen(
                        verifyEmailPath: ProRoute.verifyEmail,
                        profileEditPath: ProRoute.profileEdit,
                        gearPath: ProRoute.gear,
                        gearVerificationPath: ProRoute.gearVerification,
                        portfolioPath: ProRoute.portfolio,
                        pricingPath: ProRoute.pricing,
                        onboardingPath: ProRoute.onboarding,
                        listingPath: ProRoute.listing,
                        payoutsPath: ProRoute.payouts,
                        availabilityPath: ProRoute.availability,
                      )),
                  _editor('profile', (context, state) => const ProProfileEditScreen()),
                  _editor('gear', (context, state) => const GearScreen()),
                  _editor('gear-verification', (context, state) => const GearVerificationScreen()),
                  _editor('portfolio', (context, state) => const PortfolioScreen()),
                  _editor('pricing', (context, state) => const PricingScreen()),
                  _editor('payouts', (context, state) => const PayoutsScreen()),
                  _editor('availability', (context, state) => const AvailabilityScreen()),
                  _editor('verify-email', (context, state) => const VerifyEmailScreen()),
                  _editor('listing', (context, state) => const ListingPreviewScreen(
                        onboardingPath: ProRoute.onboarding,
                        pricingPath: ProRoute.pricing,
                        profilePath: ProRoute.profileEdit,
                        portfolioPath: ProRoute.portfolio,
                      )),
                  _editor('getting-set-up', (context, state) => const OnboardingScreen(
                        profilePath: ProRoute.profileEdit,
                        portfolioPath: ProRoute.portfolio,
                        pricingPath: ProRoute.pricing,
                        gearPath: ProRoute.gearVerification,
                      )),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: ProRoute.requests, builder: (context, state) => const RequestsScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ProRoute.gigs,
                builder: (context, state) => const GigsScreen(),
                routes: [
                  GoRoute(
                    path: 'delivery',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => DeliveryGalleryScreen(gig: state.extra! as GigResponse),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ProRoute.wallet,
                builder: (context, state) => const WalletScreen(),
                routes: [
                  GoRoute(
                    path: 'invoice',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => InvoiceScreen(gigId: state.extra! as String),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
