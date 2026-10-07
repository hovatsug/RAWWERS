/// How many files of a batch are sent at once.
///
/// Two, not one and not twenty. One at a time left a fast connection idle
/// between files - every file's create, PUT and complete as separate round
/// trips in a row. Twenty at once on a phone connection means every file
/// fails together when it dips. On a slow link two at a time is no faster
/// (the bandwidth is the limit, shared between them), but nothing is lost:
/// each upload has its own stall watchdog, so sharing bandwidth slows a file
/// without being mistaken for a stall.
const uploadConcurrency = 2;

/// Runs [action] for every item, at most [concurrency] at a time, and
/// completes when all have finished. Each item's outcome is its own: one
/// failing does not stop the rest.
Future<void> forEachConcurrently<T>(
  Iterable<T> items,
  Future<void> Function(T item) action, {
  int concurrency = uploadConcurrency,
}) async {
  // One shared iterator: each worker takes the next item when it is free.
  // Safe without locking - moveNext and current run between awaits, on one
  // isolate.
  final pending = items.iterator;
  Future<void> worker() async {
    while (pending.moveNext()) {
      await action(pending.current);
    }
  }

  await Future.wait([for (var i = 0; i < concurrency; i++) worker()]);
}
