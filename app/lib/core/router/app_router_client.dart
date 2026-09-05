import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';
import 'package:rawwers/core/launch/launch_screen.dart';
import 'package:rawwers/features/client/account/account_screen.dart';
import 'package:rawwers/features/client/bookings/booking_detail_screen.dart';
import 'package:rawwers/features/client/bookings/bookings_screen.dart';
import 'package:rawwers/features/client/client_shell.dart';
import 'package:rawwers/features/client/discover/discover_screen.dart';
import 'package:rawwers/features/client/messages/messages_screen.dart';
import 'package:rawwers/features/client/messages/thread_screen.dart';
import 'package:rawwers/features/client/pro_profile/pro_profile_screen.dart';
import 'package:rawwers/features/shared/auth/forgot_password_screen.dart';
import 'package:rawwers/features/shared/auth/login_screen.dart';
import 'package:rawwers/features/shared/auth/register_screen.dart';
import 'package:rawwers/features/shared/auth/reset_password_screen.dart';
import 'package:rawwers/features/shared/auth/verify_email_screen.dart';

part 'app_router_client.g.dart';

/// Route paths for the client flavor. Kept as named constants rather than
/// string literals scattered through the app, so a typo in a path is a
/// compile error at the call site, not a runtime 404.
abstract final class ClientRoute {
  static const launch = '/launch';
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
  static const verifyEmail = '/verify-email';
  static const discover = '/discover';
  static const bookings = '/bookings';
  static const messages = '/messages';
  static const account = '/account';

  /// Nested under Discover so the bottom nav stays put and back returns to
  /// the results the client was browsing, at the scroll position they left.
  static String proProfile(String proUserId) => '$discover/pro/$proUserId';

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
      GoRoute(path: ClientRoute.launch, builder: (context, state) => const LaunchScreen(title: 'RAWWERS')),
      GoRoute(path: ClientRoute.register, builder: (context, state) => const RegisterScreen(loginPath: ClientRoute.login)),
      GoRoute(path: ClientRoute.login, builder: (context, state) => const LoginScreen(registerPath: ClientRoute.register, forgotPasswordPath: ClientRoute.forgotPassword)),
      GoRoute(
        path: ClientRoute.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(resetPasswordPath: ClientRoute.resetPassword),
      ),
      GoRoute(path: ClientRoute.resetPassword, builder: (context, state) => const ResetPasswordScreen(loginPath: ClientRoute.login)),
      GoRoute(path: ClientRoute.verifyEmail, builder: (context, state) => const VerifyEmailScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ClientShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: ClientRoute.discover,
                builder: (context, state) => const DiscoverScreen(),
                routes: [
                  GoRoute(
                    path: 'pro/:proUserId',
                    builder: (context, state) => ProProfileScreen(proUserId: state.pathParameters['proUserId']!),
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
            routes: [GoRoute(path: ClientRoute.account, builder: (context, state) => const AccountScreen(verifyEmailPath: ClientRoute.verifyEmail))],
          ),
        ],
      ),
    ],
  );
}
