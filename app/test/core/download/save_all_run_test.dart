// Saving a whole gallery to the device.
//
// What matters: a photo saved before is not downloaded again; a failure is
// retried once with fresh links and then listed, and never stops the photos
// after it; only the failures every photo would share (permission, space, no
// links at all) stop the run; cancelling stops it between photos; there is
// never more than one download at a time; and the downloads endpoint is not
// asked more often than its limit allows.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/download/photo_saver.dart';
import 'package:rawwers/core/download/save_all_run.dart';
import 'package:rawwers/core/download/saved_photos.dart';

class _MemorySaved implements SavedPhotos {
  _MemorySaved([Map<String, Set<String>>? initial]) : byGallery = initial ?? {};
  final Map<String, Set<String>> byGallery;

  @override
  Future<Set<String>> savedIn(String galleryId) async => {...?byGallery[galleryId]};

  @override
  Future<void> markSaved(String galleryId, String assetId) async => (byGallery[galleryId] ??= {}).add(assetId);
}

/// The downloads endpoint and the saver, together, with a clock.
class _World {
  _World(int count, {this.linksFail = false}) : ids = [for (var i = 1; i <= count; i++) 'a$i'];

  final List<String> ids;
  bool linksFail;
  var now = DateTime.utc(2026, 10, 31, 12);
  var linkCalls = 0;
  final linkCallTimes = <DateTime>[];

  /// What each save attempt does, per asset, in order; Saved when the list
  /// runs out.
  final scripted = <String, List<SaveOutcome>>{};
  final attempts = <String>[];
  final urlsUsed = <String>[];
  var inFlight = 0;
  var maxInFlight = 0;

  /// Each save takes this long on the clock.
  var saveTakes = Duration.zero;

  Future<Map<String, String>?> fetchLinks() async {
    linkCalls++;
    linkCallTimes.add(now);
    if (linksFail) return null;
    return {for (final id in ids) id: 'https://r2.test/$id.jpg?v=$linkCalls'};
  }

  Future<SaveOutcome> save(String url, String assetId) async {
    inFlight++;
    maxInFlight = inFlight > maxInFlight ? inFlight : maxInFlight;
    attempts.add(assetId);
    urlsUsed.add(url);
    await Future<void>.delayed(Duration.zero);
    now = now.add(saveTakes);
    inFlight--;
    final queue = scripted[assetId];
    if (queue != null && queue.isNotEmpty) return queue.removeAt(0);
    return const Saved();
  }

  SaveAllRun run({SavedPhotos? saved}) => SaveAllRun(
    galleryId: 'g1',
    assetIds: ids,
    fetchLinks: fetchLinks,
    save: save,
    savedPhotos: saved ?? _MemorySaved(),
    now: () => now,
  );
}

const _network = SaveFailed(SaveFailure.network);

void main() {
  test('saves every photo, one at a time, and remembers each', () async {
    final world = _World(5);
    final saved = _MemorySaved();
    final result = await world.run(saved: saved).run();

    expect(result.saved, 5);
    expect(result.failed, isEmpty);
    expect(world.attempts, world.ids, reason: 'gallery order, each once');
    expect(world.maxInFlight, 1, reason: 'more than one original downloading at once');
    expect(saved.byGallery['g1'], world.ids.toSet());
  });

  test('a photo saved before is skipped, not downloaded again', () async {
    final world = _World(4);
    final saved = _MemorySaved({
      'g1': {'a2', 'a3'},
    });
    final result = await world.run(saved: saved).run();

    expect(world.attempts, ['a1', 'a4']);
    expect(result.saved, 2);
    expect(result.skipped, 2);
  });

  test('saving again anyway includes the ones saved before', () async {
    final world = _World(3);
    final saved = _MemorySaved({
      'g1': {'a1', 'a2', 'a3'},
    });
    final first = await world.run(saved: saved).run();
    expect(first.allAlreadySaved, isTrue);
    expect(world.attempts, isEmpty);

    final again = await world.run(saved: saved).run(includeSaved: true);
    expect(again.saved, 3);
    expect(world.attempts, ['a1', 'a2', 'a3']);
  });

  test('a failed photo is retried once with a fresh link, then the rest carry on', () async {
    final world = _World(4)
      ..scripted['a2'] = [_network]
      ..saveTakes = const Duration(minutes: 1);
    final result = await world.run().run();

    expect(world.attempts, ['a1', 'a2', 'a2', 'a3', 'a4']);
    expect(world.urlsUsed[2], isNot(world.urlsUsed[1]), reason: 'the retry reused the link that just failed');
    expect(result.saved, 4);
    expect(result.failed, isEmpty);
  });

  test('a photo that fails twice is listed by its position, and never stops the others', () async {
    final world = _World(5)
      ..scripted['a2'] = [_network, _network]
      ..scripted['a4'] = [const SaveFailed(SaveFailure.linkUnavailable), const SaveFailed(SaveFailure.storage)];
    final result = await world.run().run();

    expect(result.failed, [2, 4]);
    expect(result.saved, 3);
    expect(world.attempts.where((a) => a == 'a5'), hasLength(1), reason: 'the photo after a failure was not tried');
    expect(result.stoppedBy, isNull);
  });

  test('a failed photo is not remembered as saved', () async {
    final world = _World(2)..scripted['a1'] = [_network, _network];
    final saved = _MemorySaved();
    await world.run(saved: saved).run();
    expect(saved.byGallery['g1'], {'a2'});
  });

  test('the library refusing stops the run: every photo after would be refused too', () async {
    final world = _World(4)..scripted['a2'] = [const SaveFailed(SaveFailure.permissionDenied)];
    final result = await world.run().run();

    expect(result.stoppedBy, SaveFailure.permissionDenied);
    expect(world.attempts, ['a1', 'a2'], reason: 'kept going after the library said no, or retried it');
    expect(result.saved, 1);
  });

  test('a full device stops the run and lists the photo it was on', () async {
    final world = _World(3)..scripted['a2'] = [const SaveFailed(SaveFailure.notEnoughSpace)];
    final result = await world.run().run();

    expect(result.stoppedBy, SaveFailure.notEnoughSpace);
    expect(result.failed, [2]);
    expect(world.attempts, ['a1', 'a2']);
  });

  test('no links at all stops before downloading anything', () async {
    final world = _World(3, linksFail: true);
    final result = await world.run().run();

    expect(result.stoppedBy, SaveFailure.linkUnavailable);
    expect(world.attempts, isEmpty);
  });

  test('cancelling stops between photos and says how far it got', () async {
    final world = _World(5);
    final run = world.run();
    final reached = <int>[];
    final result = await run.run(
      onProgress: (done, total) {
        reached.add(done);
        if (done == 2) run.cancel();
      },
    );

    expect(result.cancelled, isTrue);
    expect(world.attempts, ['a1', 'a2', 'a3'], reason: 'the photo in progress finishes; none after it starts');
    expect(result.reached, 3);
  });

  test('progress counts up to the total', () async {
    final world = _World(3);
    final seen = <(int, int)>[];
    await world.run().run(onProgress: (done, total) => seen.add((done, total)));
    expect(seen, [(0, 3), (1, 3), (2, 3), (3, 3)]);
  });

  test('links are fetched once for the gallery, then again only once they age', () async {
    final world = _World(13)..saveTakes = const Duration(minutes: 1);
    await world.run().run();

    // One call to start; with a minute per photo, a fresh set after each
    // five minutes, inside the ten minutes a link lasts.
    expect(world.linkCalls, 3);
    final gaps = [
      for (var i = 1; i < world.linkCallTimes.length; i++)
        world.linkCallTimes[i].difference(world.linkCallTimes[i - 1]),
    ];
    expect(gaps.every((g) => g <= const Duration(minutes: 10)), isTrue);
  });

  test('a run of failures cannot reach the endpoint\'s limit of 20 a minute', () async {
    // Every photo fails at once; nothing moves the clock.
    final world = _World(60);
    for (final id in world.ids) {
      world.scripted[id] = [_network, _network];
    }
    final result = await world.run().run();

    expect(result.failed, hasLength(60));
    expect(world.linkCalls, 1, reason: 'each failure fetched new links, within seconds of the last');
  });

  test('a run that fails partway can be run again, and only the failures are tried', () async {
    final world = _World(4)..scripted['a3'] = [_network, _network];
    final saved = _MemorySaved();
    final first = await world.run(saved: saved).run();
    expect(first.failed, [3]);

    world.attempts.clear();
    final second = await world.run(saved: saved).run();
    expect(world.attempts, ['a3']);
    expect(second.saved, 1);
    expect(second.skipped, 3);
  });

  test('a save in progress is awaited before the next starts', () async {
    final gate = Completer<void>();
    final started = <String>[];
    final run = SaveAllRun(
      galleryId: 'g1',
      assetIds: const ['a1', 'a2'],
      fetchLinks: () async => {'a1': 'u1', 'a2': 'u2'},
      save: (url, id) async {
        started.add(id);
        if (id == 'a1') await gate.future;
        return const Saved();
      },
      savedPhotos: _MemorySaved(),
    );
    final done = run.run();
    await Future<void>.delayed(Duration.zero);
    expect(started, ['a1']);
    gate.complete();
    await done;
    expect(started, ['a1', 'a2']);
  });
}
