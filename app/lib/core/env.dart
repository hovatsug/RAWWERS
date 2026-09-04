/// Values injected via `--dart-define-from-file=env/<flavor>.json`. Never
/// hardcode a real value here — the env/*.json files are gitignored and
/// env/*.example.json documents the shape.
abstract final class Env {
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');

  /// Stripe's publishable key (`pk_test_…` / `pk_live_…`). Publishable by
  /// design - it identifies the account to the SDK and cannot move money -
  /// but it is still environment-specific, so it is injected rather than
  /// committed. Empty means Stripe was never configured for this build; the
  /// payment step says so instead of failing inside the SDK.
  static const stripePublishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  static bool get hasStripe => stripePublishableKey.isNotEmpty;
}
