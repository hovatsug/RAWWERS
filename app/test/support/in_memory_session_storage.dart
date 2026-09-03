import 'package:rawwers/core/api/session.dart';

class InMemorySessionStorage implements SessionStorage {
  InMemorySessionStorage([this._session]);

  Session? _session;

  /// Number of times [write] has been called - both tokens must land in a
  /// single write (see Session/SessionStorage docs), so tests can assert on
  /// this directly instead of only checking the end state.
  int writeCallCount = 0;

  @override
  Future<Session?> read() async => _session;

  @override
  Future<void> write(Session session) async {
    writeCallCount++;
    _session = session;
  }

  @override
  Future<void> clear() async => _session = null;
}
