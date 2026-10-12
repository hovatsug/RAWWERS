import 'dart:io';

/// The local backend the `integration`-tagged tests run against.
const localBackendUrl = 'http://localhost:8000';

/// Why an integration test cannot run here, or null when it can.
///
/// These tests prove the real transport stack against a running `api/`
/// (`docker compose up`). Without one they used to fail with "No connection",
/// which reads as a regression in whatever change was being verified. Now
/// they skip, and say why - a skip is visible in the run summary, so a green
/// run without a backend does not claim they passed.
Future<String?> localBackendSkipReason({required int tests}) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 2);
  try {
    final request = await client.getUrl(Uri.parse('$localBackendUrl/healthz'));
    final response = await request.close().timeout(const Duration(seconds: 2));
    await response.drain<void>();
    if (response.statusCode == HttpStatus.ok) return null;
    return '$tests integration ${tests == 1 ? 'test' : 'tests'} in this file skipped: '
        'the local backend answered /healthz with ${response.statusCode}';
  } catch (_) {
    return '$tests integration ${tests == 1 ? 'test' : 'tests'} in this file skipped: '
        'no backend at $localBackendUrl - start api/ with docker compose up to run them';
  } finally {
    client.close(force: true);
  }
}
