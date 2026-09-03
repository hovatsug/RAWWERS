/// Values injected via `--dart-define-from-file=env/<flavor>.json`. Never
/// hardcode a real value here — the env/*.json files are gitignored and
/// env/*.example.json documents the shape.
abstract final class Env {
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');
}
