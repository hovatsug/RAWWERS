import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';
import 'package:rawwers/core/launch/launch_screen.dart';
import 'package:rawwers/features/client/account/account_screen.dart';
import 'package:rawwers/features/client/bookings/booking_detail_screen.dart';
import 'package:rawwers/features/client/bookings/bookings_screen.dart';
import 'package:rawwers/features/client/gallery/delivered_gallery_screen.dart';
import 'package:rawwers/features/client/gallery/selection_gallery_screen.dart';
import 'package:rawwers/features/client/client_shell.dart';
import 'package:rawwers/features/client/discover/home_screen.dart';
import 'package:rawwers/features/client/discover/niche_screen.dart';
import 'package:rawwers/features/client/messages/messages_screen.dart';
import 'package:rawwers/features/client/messages/thread_screen.dart';
import 'package:rawwers/features/client/pro_profile/pro_profile_screen.dart';
import 'package:rawwers/features/shared/auth/forgot_password_screen.dart';
import 'package:rawwers/features/shared/auth/login_screen.dart';
import 'package:rawwers/features/shared/auth/register_screen.dart';
import 'package:rawwers/features/shared/auth/reset_password_screen.dart';
import 'package:rawwers/features/shared/auth/verify_email_screen.dart';
import 'package:rawwers/features/client/discover/discover_freshness.dart';

part 'app_router_client.g.dart';

/// Route paths for the client flavor. Kept as named constants rather than
/// string literals scattered through the app, so a typo in a path is a
/// compile error at the call site, not a runtime 404.
abstract final class ClientRoute {
  static const launch = '/launch';

  /// Login is the auth entry point, and register/forgot/reset are its
  /// children so that each one stacks on top of it rather than replacing it.
  static const login = '/auth';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';

  static const discover = '/discover';
  static const bookings = '/bookings';
  /// Choosing which photographs to keep. Nested under the booking it belongs
  /// to, so backing out lands on that booking rather than the bookings list.
  static String gallery(String bookingId, String galleryId) => '$bookings/$bookingId/gallery/$galleryId';

  /// The photographs already chosen and paid for.
  static String delivered(String bookingId, String galleryId) =>
      '$bookings/$bookingId/photos/$galleryId';
  static const messages = '/messages';
  static const account = '/account';

  /// Opened from Account, so it hangs off Account and back returns there.
  static const verifyEmail = '$account/verify-email';

  /// Nested under Discover so the bottom nav stays put and back returns to
  /// the results the client was browsing, at the scroll position they left.
  static String proProfile(String proUserId) => '$discover/pro/$proUserId';

  /// One niche's page. Where its tile, its row heading and its hero slide all
  /// lead - one destination, however someone got there.
  static String niche(String nicheSlug) => '$discover/niche/$nicheSlug';

  static String bookingDetail(String bookingId) => '$bookings/$bookingId';

  static String thread(String threadId) => '$messages/$threadId';
}

@Riverpod(keepAlive: true)
GoRouter clientRouter(Ref ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: ClientRoute.launch,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthRoute = location.startsWith('/auth');
      final isLaunch = location == ClientRoute.launch;

      // AsyncLoading is the real "still checking" signal - AuthController's
      // build() is itself the session-read + GET /v1/me check, so this is
      // the window a slow connection makes visible. Everything routes
      // through the launch screen during it rather than flashing whatever
      // the location would otherwise resolve to.
      if (authState.isLoading) {
        return isLaunch ? null : ClientRoute.launch;
      }

      final resolved = authState.valueOrNull;
      if (resolved == null || resolved is AuthUnauthenticated) {
        return isAuthRoute ? null : ClientRoute.login;
      }
      // AuthAuthenticated.
      return (isAuthRoute || isLaunch) ? ClientRoute.discover : null;
    },
    routes: [
      GoRoute(path: ClientRoute.launch, builder: (context, state) => const LaunchScreen()),
      GoRoute(
        path: ClientRoute.login,
        builder: (context, state) => const LoginScreen(registerPath: ClientRoute.register, forgotPasswordPath: ClientRoute.forgotPassword),
        routes: [
          GoRoute(path: 'register', builder: (context, state) => const RegisterScreen(loginPath: ClientRoute.login)),
          GoRoute(
            path: 'forgot-password',
            builder: (context, state) => const ForgotPasswordScreen(resetPasswordPath: ClientRoute.resetPassword),
          ),
          GoRoute(path: 'reset-password', builder: (context, state) => const ResetPasswordScreen(loginPath: ClientRoute.login)),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ClientShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            // Back from a profile or a niche page: Discover's live rows may
            // be stale (discover_freshness.dart).
            observers: [DiscoverPopObserver(() => ref.read(discoverReturnsProvider.notifier).bump())],
            routes: [
              GoRoute(
                path: ClientRoute.discover,
                // The browsing home replaces the plain search-and-filter list
                // as the primary way in. Search still exists and is reachable
                // from here; it is no longer the first thing anyone meets.
                builder: (context, state) => ClientHomeScreen(
                  onOpenPro: (proUserId) => context.push(ClientRoute.proProfile(proUserId)),
                  onOpenNiche: (nicheSlug) => context.push(ClientRoute.niche(nicheSlug)),
                ),
                routes: [
                  GoRoute(
                    path: 'pro/:proUserId',
                    builder: (context, state) => ProProfileScreen(proUserId: state.pathParameters['proUserId']!),
                  ),
                  GoRoute(
                    path: 'niche/:nicheSlug',
                    builder: (context, state) => NicheScreen(
                      nicheSlug: state.pathParameters['nicheSlug']!,
                      onOpenPro: (proUserId) => context.push(ClientRoute.proProfile(proUserId)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ClientRoute.bookings,
                builder: (context, state) => const BookingsScreen(),
                routes: [
                  GoRoute(
                    path: ':bookingId',
                    builder: (context, state) => BookingDetailScreen(bookingId: state.pathParameters['bookingId']!),
                    routes: [
                      GoRoute(
                        path: 'gallery/:galleryId',
                        builder: (context, state) => SelectionGalleryScreen(
                          galleryId: state.pathParameters['galleryId']!,
                          bookingId: state.pathParameters['bookingId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'photos/:galleryId',
                        builder: (context, state) => DeliveredGalleryScreen(
                          galleryId: state.pathParameters['galleryId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ClientRoute.messages,
                builder: (context, state) => const MessagesScreen(),
                routes: [
                  GoRoute(
                    path: ':threadId',
                    builder: (context, state) => ThreadScreen(threadId: state.pathParameters['threadId']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ClientRoute.account,
                builder: (context, state) => const AccountScreen(verifyEmailPath: ClientRoute.verifyEmail),
                routes: [
                  GoRoute(path: 'verify-email', builder: (context, state) => const VerifyEmailScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
