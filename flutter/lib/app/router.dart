import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/providers.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/reset_password_screen.dart';
import '../features/auth/verify_email_screen.dart';
import '../features/discover/discover_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/pro_onboarding/pro_onboarding_screen.dart';
import '../features/pros/pro_profile_screen.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/discover',
    redirect: (context, state) {
      final onAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/verify-email' ||
          state.matchedLocation == '/reset-password';

      final requiresAuth = state.matchedLocation.startsWith('/discover') ||
          state.matchedLocation.startsWith('/notifications') ||
          state.matchedLocation.startsWith('/pros/') ||
          state.matchedLocation.startsWith('/pro/onboarding');

      if (session.loading) {
        return null;
      }

      if (!session.isAuthenticated && requiresAuth) {
        return '/login';
      }

      if (session.isAuthenticated && onAuth) {
        return '/discover';
      }

      if (state.matchedLocation.startsWith('/pro/onboarding') && !session.isPro) {
        return '/discover';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/verify-email', builder: (_, __) => const VerifyEmailScreen()),
      GoRoute(path: '/reset-password', builder: (_, __) => const ResetPasswordScreen()),
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(location: state.matchedLocation, session: session, child: child);
        },
        routes: [
          GoRoute(path: '/discover', builder: (_, __) => const DiscoverScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/pro/onboarding', builder: (_, __) => const ProOnboardingScreen()),
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
