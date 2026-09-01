import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/pro_login_screen.dart';
import '../features/auth/pro_register_screen.dart';
import '../features/auth/providers.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/reset_password_screen.dart';
import '../features/auth/verify_email_screen.dart';
import '../features/client_workspace/screens.dart';
import '../features/discover/discover_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/pro_onboarding/pro_onboarding_screen.dart';
import '../features/pro_workspace/pro_calendar_screen.dart';
import '../features/pro_workspace/pro_dashboard_screen.dart';
import '../features/pro_workspace/pro_gigs_screen.dart';
import '../features/pro_workspace/pro_leads_screen.dart';
import '../features/pro_workspace/pro_packages_screen.dart';
import '../features/pro_workspace/pro_portfolio_screen.dart';
import '../features/pro_workspace/pro_profile_screen.dart';
import '../features/pro_workspace/pro_wallet_screen.dart';
import '../features/pros/listing_card_screen.dart';
import '../features/pros/pro_profile_screen.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppConfig.isProApp ? '/pro/login' : '/home',
    redirect: (context, state) {
      final onAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/pro/login' ||
          state.matchedLocation == '/pro/register' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/verify-email' ||
          state.matchedLocation == '/reset-password';

      final isProAuth = state.matchedLocation == '/pro/login' || state.matchedLocation == '/pro/register';
      final isPublicClientPath = state.matchedLocation.startsWith('/home') ||
          state.matchedLocation.startsWith('/search') ||
          state.matchedLocation.startsWith('/discover') ||
          state.matchedLocation.startsWith('/pros/');
      final requiresAuth = (!isPublicClientPath &&
              (state.matchedLocation.startsWith('/bookings') ||
                  state.matchedLocation.startsWith('/notifications') ||
                  state.matchedLocation.startsWith('/rewards') ||
                  state.matchedLocation.startsWith('/settings') ||
                  state.matchedLocation.startsWith('/disputes') ||
                  state.matchedLocation.startsWith('/gigs/'))) ||
          (state.matchedLocation.startsWith('/pro/') && !isProAuth) ||
          state.matchedLocation.startsWith('/profile/listing-card');

      if (session.loading) {
        return null;
      }

      if (!session.isAuthenticated && requiresAuth) {
        if (state.matchedLocation.startsWith('/pro/')) return '/pro/login';
        return '/login';
      }

      if (session.isAuthenticated && onAuth) {
        if (AppConfig.isProApp) return '/pro/dashboard';
        if (session.isPro && state.matchedLocation.startsWith('/pro')) return '/pro/dashboard';
        return '/home';
      }

      if (state.matchedLocation.startsWith('/pro/onboarding') && !session.isPro) {
        return '/home';
      }
      if (state.matchedLocation.startsWith('/profile/listing-card') && !session.isPro) {
        return '/home';
      }
      if (state.matchedLocation.startsWith('/pro/') && !session.isPro) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/pro/login', builder: (_, __) => const ProLoginScreen()),
      GoRoute(path: '/pro/register', builder: (_, __) => const ProRegisterScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/verify-email', builder: (_, __) => const VerifyEmailScreen()),
      GoRoute(path: '/reset-password', builder: (_, __) => const ResetPasswordScreen()),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(location: state.matchedLocation, session: session, child: child);
        },
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const ClientHomeScreen()),
          GoRoute(path: '/search', builder: (_, __) => const ClientSearchScreen()),
          GoRoute(path: '/bookings', builder: (_, __) => const ClientBookingsScreen()),
          GoRoute(
            path: '/bookings/:bookingId',
            builder: (_, state) {
              final bookingId = state.pathParameters['bookingId'] ?? '';
              return ClientBookingDetailScreen(bookingId: bookingId);
            },
          ),
          GoRoute(path: '/notifications', builder: (_, __) => const ClientNotificationsScreen()),
          GoRoute(path: '/rewards', builder: (_, __) => const ClientRewardsScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const ClientSettingsScreen()),
          GoRoute(path: '/waitlist', builder: (_, __) => const ClientWaitlistScreen()),
          GoRoute(path: '/disputes', builder: (_, __) => const ClientDisputesScreen()),
          GoRoute(
            path: '/gigs/:gigId',
            builder: (_, state) {
              final gigId = state.pathParameters['gigId'] ?? '';
              return ClientGigScreen(gigId: gigId);
            },
          ),
          GoRoute(
            path: '/gigs/:gigId/gallery/:galleryId',
            builder: (_, state) {
              final galleryId = state.pathParameters['galleryId'] ?? '';
              return ClientGalleryScreen(galleryId: galleryId);
            },
          ),
          GoRoute(
            path: '/gigs/:gigId/delivery',
            builder: (_, state) {
              final gigId = state.pathParameters['gigId'] ?? '';
              return ClientDeliveryScreen(gigId: gigId);
            },
          ),
          GoRoute(path: '/discover', builder: (_, __) => const DiscoverScreen()),
          GoRoute(path: '/notifications-legacy', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/pro/dashboard', builder: (_, __) => const ProDashboardScreen()),
          GoRoute(path: '/pro/leads', builder: (_, __) => const ProLeadsScreen()),
          GoRoute(path: '/pro/gigs', builder: (_, __) => const ProGigsScreen()),
          GoRoute(path: '/pro/calendar', builder: (_, __) => const ProCalendarScreen()),
          GoRoute(path: '/pro/wallet', builder: (_, __) => const ProWalletScreen()),
          GoRoute(path: '/pro/profile', builder: (_, __) => const ProProfileWorkspaceScreen()),
          GoRoute(path: '/pro/profile/packages', builder: (_, __) => const ProPackagesScreen()),
          GoRoute(path: '/pro/profile/portfolio', builder: (_, __) => const ProPortfolioScreen()),
          GoRoute(path: '/pro/onboarding', builder: (_, __) => const ProOnboardingScreen()),
          GoRoute(path: '/profile/listing-card', builder: (_, __) => const ListingCardScreen()),
          GoRoute(
            path: '/pros/:id',
            builder: (_, state) {
              final id = state.pathParameters['id'] ?? '';
              return ProProfileScreen(proId: id);
            },
          ),
        ],
      ),
    ],
  );
});
