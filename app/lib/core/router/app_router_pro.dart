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
import 'package:rawwers/features/pro/wallet/wallet_screen.dart';
import 'package:rawwers/features/shared/auth/forgot_password_screen.dart';
import 'package:rawwers/features/shared/auth/login_screen.dart';
import 'package:rawwers/features/shared/auth/register_screen.dart';
import 'package:rawwers/features/shared/auth/reset_password_screen.dart';
import 'package:rawwers/features/shared/auth/verify_email_screen.dart';

part 'app_router_pro.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

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
  static const profileEdit = '$settings/profile';
  static const gear = '$settings/gear';
  static const portfolio = '$settings/portfolio';
  static const pricing = '$settings/pricing';
  static const payouts = '$settings/payouts';
  static const availability = '$settings/availability';
  static const listing = '$settings/listing';
  static const onboarding = '$settings/getting-set-up';
  static const verifyEmail = '$settings/verify-email';

  static const gigDelivery = '$gigs/delivery';
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
                  GoRoute(
                    path: 'settings',
                    // Full-screen over the shell, but still a child of Today:
                    // presentation and stack depth are separate decisions, and
                    // covering the bottom nav must not cost the way back.
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const ProSettingsScreen(
                      verifyEmailPath: ProRoute.verifyEmail,
                      profileEditPath: ProRoute.profileEdit,
                      gearPath: ProRoute.gear,
                      portfolioPath: ProRoute.portfolio,
                      pricingPath: ProRoute.pricing,
                      onboardingPath: ProRoute.onboarding,
                      listingPath: ProRoute.listing,
                      payoutsPath: ProRoute.payouts,
                      availabilityPath: ProRoute.availability,
                    ),
                    routes: [
                      GoRoute(path: 'profile', builder: (context, state) => const ProProfileEditScreen()),
                      GoRoute(path: 'gear', builder: (context, state) => const GearScreen()),
                      GoRoute(path: 'portfolio', builder: (context, state) => const PortfolioScreen()),
                      GoRoute(path: 'pricing', builder: (context, state) => const PricingScreen()),
                      GoRoute(path: 'payouts', builder: (context, state) => const PayoutsScreen()),
                      GoRoute(path: 'availability', builder: (context, state) => const AvailabilityScreen()),
                      GoRoute(path: 'verify-email', builder: (context, state) => const VerifyEmailScreen()),
                      GoRoute(
                        path: 'listing',
                        builder: (context, state) => const ListingPreviewScreen(
                          onboardingPath: ProRoute.onboarding,
                          pricingPath: ProRoute.pricing,
                          profilePath: ProRoute.profileEdit,
                          portfolioPath: ProRoute.portfolio,
                        ),
                      ),
                      GoRoute(
                        path: 'getting-set-up',
                        builder: (context, state) => const OnboardingScreen(
                          profilePath: ProRoute.profileEdit,
                          portfolioPath: ProRoute.portfolio,
                          pricingPath: ProRoute.pricing,
                        ),
                      ),
                    ],
                  ),
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
            routes: [GoRoute(path: ProRoute.wallet, builder: (context, state) => const WalletScreen())],
          ),
        ],
      ),
    ],
  );
}
