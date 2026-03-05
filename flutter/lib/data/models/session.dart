import 'auth_models.dart';

class SessionState {
  SessionState({
    required this.loading,
    required this.accessToken,
    required this.refreshToken,
    required this.me,
    required this.error,
  });

  final bool loading;
  final String? accessToken;
  final String? refreshToken;
  final MeResponse? me;
  final String? error;

  bool get isAuthenticated => accessToken != null && me != null;
  bool get isPro => me?.roles.contains('pro') ?? false;
  bool get isClient => me?.roles.contains('client') ?? false;

  SessionState copyWith({
    bool? loading,
    String? accessToken,
    String? refreshToken,
    MeResponse? me,
    String? error,
    bool clearError = false,
    bool clearSession = false,
  }) {
    if (clearSession) {
      return SessionState(loading: loading ?? false, accessToken: null, refreshToken: null, me: null, error: error);
    }
    return SessionState(
      loading: loading ?? this.loading,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      me: me ?? this.me,
      error: clearError ? null : (error ?? this.error),
    );
  }

  static SessionState initial() => SessionState(
        loading: true,
        accessToken: null,
        refreshToken: null,
        me: null,
        error: null,
      );
}
