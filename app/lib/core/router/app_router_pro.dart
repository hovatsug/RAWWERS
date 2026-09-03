import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/user_role_type.dart';
import 'package:rawwers/core/auth/auth_controller.dart';
import 'package:rawwers/core/auth/auth_state.dart';
import 'package:rawwers/core/launch/launch_screen.dart';
import 'package:rawwers/features/pro/gigs/gigs_screen.dart';
import 'package:rawwers/features/pro/pro_shell.dart';
import 'package:rawwers/features/pro/requests/requests_screen.dart';
import 'package:rawwers/features/pro/settings/pro_settings_screen.dart';
import 'package:rawwers/features/pro/today/today_screen.dart';
import 'package:rawwers/features/pro/upgrade/upgrade_to_pro_screen.dart';
import 'package:rawwers/features/pro/wallet/wallet_screen.dart';
import 'package:rawwers/features/shared/auth/forgot_password_screen.dart';
import 'package:rawwers/features/shared/auth/login_screen.dart';
import 'package:rawwers/features/shared/auth/register_screen.dart';
import 'package:rawwers/features/shared/auth/reset_password_screen.dart';
import 'package:rawwers/features/shared/auth/verify_email_screen.dart';

part 'app_router_pro.g.dart';

/// Route paths for the pro flavor. Kept as named constants rather than
/// string literals scattered through the app, so a typo in a path is a
/// compile error at the call site, not a runtime 404.
abstract final class ProRoute {
  static const launch = '/launch';
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
  static const verifyEmail = '/verify-email';
  static const upgradeToPro = '/upgrade-to-pro';
  static const today = '/today';
  static const requests = '/requests';
  static const gigs = '/gigs';
  static const wallet = '/wallet';
  static const settings = '/settings';
}

@Riverpod(keepAlive: true)
GoRouter proRouter(Ref ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
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

      return (isAuthRoute || isLaunch || isUpgrade) ? ProRoute.today : null;
    },
    routes: [
      GoRoute(path: ProRoute.launch, builder: (context, state) => const LaunchScreen(title: 'RAWWERS Pro')),
      GoRoute(path: ProRoute.register, builder: (context, state) => const RegisterScreen(loginPath: ProRoute.login)),
      GoRoute(path: ProRoute.login, builder: (context, state) => const LoginScreen(registerPath: ProRoute.register, forgotPasswordPath: ProRoute.forgotPassword)),
      GoRoute(
        path: ProRoute.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(resetPasswordPath: ProRoute.resetPassword),
      ),
      GoRoute(path: ProRoute.resetPassword, builder: (context, state) => const ResetPasswordScreen(loginPath: ProRoute.login)),
      GoRoute(path: ProRoute.verifyEmail, builder: (context, state) => const VerifyEmailScreen()),
      GoRoute(path: ProRoute.upgradeToPro, builder: (context, state) => const UpgradeToProScreen()),
      GoRoute(path: ProRoute.settings, builder: (context, state) => const ProSettingsScreen(verifyEmailPath: ProRoute.verifyEmail)),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ProShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: ProRoute.today, builder: (context, state) => const TodayScreen(settingsPath: ProRoute.settings))]),
          StatefulShellBranch(routes: [GoRoute(path: ProRoute.requests, builder: (context, state) => const RequestsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: ProRoute.gigs, builder: (context, state) => const GigsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: ProRoute.wallet, builder: (context, state) => const WalletScreen())]),
        ],
      ),
    ],
  );
}
