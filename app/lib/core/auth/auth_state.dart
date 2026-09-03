import 'package:rawwers/api/models/me_response.dart';

/// Flavor-agnostic - both apps share this. What "authenticated" means for
/// navigation purposes (e.g. the pro app additionally requiring the `pro`
/// role) is decided by each app's router redirect, not by this state.
///
/// No separate "unknown/checking" variant here - AuthController.build()
/// is itself the check (read session storage, GET /v1/me), so the window
/// between reading storage and that resolving is exactly Riverpod's own
/// `AsyncLoading<AuthState>`, not a third AuthState value. The router
/// redirects on AsyncLoading directly (see app_router_client.dart /
/// app_router_pro.dart) rather than duplicating that signal here.
sealed class AuthState {
  const AuthState();
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.message});

  /// Carries a message through a state transition rather than a one-off
  /// navigation argument - e.g. "Your account was created. Log in to
  /// continue." after a register-succeeded-but-login-failed split, so the
  /// login screen can show it regardless of how the user got there.
  final String? message;
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.me);

  final MeResponse me;
}
