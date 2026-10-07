import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/upload/upload_pool.dart';

void main() {
  test('a batch runs two at a time - not one, and not all at once', () async {
    var inFlight = 0;
    var peak = 0;
    final gates = <Completer<void>>[];

    final done = forEachConcurrently(List.generate(5, (i) => i), (_) async {
      inFlight++;
      peak = inFlight > peak ? inFlight : peak;
      final gate = Completer<void>();
      gates.add(gate);
      await gate.future;
      inFlight--;
    });

    // Let each finished slot take the next file, one at a time.
    while (gates.length < 5 || gates.any((g) => !g.isCompleted)) {
      await Future<void>.delayed(Duration.zero);
      expect(inFlight, lessThanOrEqualTo(uploadConcurrency));
      final open = gates.where((g) => !g.isCompleted).toList();
      if (open.isNotEmpty) open.first.complete();
    }
    await done;

    // The decided number, not the constant: a test that read the constant
    // would pass if someone set it back to one.
    expect(peak, 2, reason: 'two files moving at once, never more');
    expect(gates, hasLength(5), reason: 'every file was sent');
  });

  test("one file failing does not stop the rest", () async {
    final sent = <int>[];
    await forEachConcurrently([1, 2, 3, 4], (i) async {
      if (i == 2) {
        sent.add(-i);
        return; // a failed upload reports itself and returns, it does not throw
      }
      await Future<void>.delayed(Duration.zero);
      sent.add(i);
    });
    expect(sent..sort(), [-2, 1, 3, 4]);
  });
}
