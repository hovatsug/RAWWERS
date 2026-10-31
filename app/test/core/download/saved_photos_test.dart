// What this device remembers having saved. The one way this can hurt is by
// skipping a photo that was never saved, so an unreadable file must count as
// nothing saved.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rawwers/core/download/saved_photos.dart';

void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('saved-photos'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('remembered across app starts, per gallery', () async {
    final first = FileSavedPhotos(() async => dir);
    await first.markSaved('g1', 'a1');
    await first.markSaved('g1', 'a2');
    await first.markSaved('g2', 'b1');

    final next = FileSavedPhotos(() async => dir);
    expect(await next.savedIn('g1'), {'a1', 'a2'});
    expect(await next.savedIn('g2'), {'b1'});
    expect(await next.savedIn('g3'), isEmpty);
  });

  test('saves finishing together are all kept', () async {
    final store = FileSavedPhotos(() async => dir);
    await Future.wait([for (var i = 0; i < 20; i++) store.markSaved('g1', 'a$i')]);
    expect(await FileSavedPhotos(() async => dir).savedIn('g1'), hasLength(20));
  });

  test('an unreadable file counts as nothing saved', () async {
    File('${dir.path}/saved-photos.json').writeAsStringSync('{not json');
    expect(await FileSavedPhotos(() async => dir).savedIn('g1'), isEmpty);
  });

  test('the set handed out is a copy', () async {
    final store = FileSavedPhotos(() async => dir);
    await store.markSaved('g1', 'a1');
    (await store.savedIn('g1')).add('a2');
    expect(await store.savedIn('g1'), {'a1'});
  });
}
