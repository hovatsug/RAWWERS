// Post-processes generated lib/api/api_client/*.g.dart files to fix a
// confirmed swagger_to_dart/retrofit_generator bug: wherever a response
// contains a free-form object (`additionalProperties`, no `properties`) the
// generator emits a call to a `.fromJson` constructor that does not exist.
// It is not valid Dart, so the whole file fails to compile the moment
// anything imports its class.
//
// Two shapes of the same bug, both seen in this schema:
//
//   1. A bare free-form object response (`-> dict` on the FastAPI side)
//      generates `dynamic.fromJson(...)` - `dynamic` is not a class and has
//      no such constructor.
//   2. An array of free-form objects (`-> list[dict]`) generates
//      `Map<String, dynamic>.fromJson(...)` - Map has no `fromJson`
//      constructor either.
//
// In both cases the already-decoded response body *is* the value: there is
// nothing to deserialize per entry, because the entries have no schema. So
// the fixes are a plain assignment and a `cast`, respectively.
//
// IMPORTANT: avoiding the *call site* does not avoid the error. Dart compiles
// every method body in a class when anything imports that class, so a single
// broken method breaks every consumer of the client. That is why these are
// worth fixing rather than routing around - and why a newly-imported client
// can surface a latent break that was sitting in generated code for weeks.
//
// Run as part of `make gen-api`, after swagger_to_dart + build_runner, so
// this survives regeneration instead of being silently reverted by the next
// run - a one-off hand-edit to a generated file would violate "lib/api is
// generated, never hand-edited" by definition; a deterministic
// post-processing step run every time does not. Note that a bare
// `dart run build_runner build` does NOT apply these fixes; use `make
// gen-api`, or run this script afterwards.
import 'dart:io';

/// Each entry is (broken source, replacement). Matching is exact-substring on
/// the generator's formatted output rather than a regex: a loose pattern here
/// would rewrite correct deserialization for real models, which is a far
/// worse failure than leaving a compile error in place.
const _fixes = <(String, String)>[
  // 1. Free-form object response. Target variable is declared
  //    `late Map<String, dynamic> _value;` directly above.
  (
    '''
      _value = _result.data!.map(
        (k, dynamic v) =>
            MapEntry(k, dynamic.fromJson(v as Map<String, dynamic>)),
      );''',
    '      _value = _result.data!;',
  ),

  // 2. Array of free-form objects. Target is
  //    `late List<Map<String, dynamic>> _value;`. cast, not a map: the
  //    decoded list already holds Maps, it is only typed as List<dynamic>.
  (
    '''
      _value = _result.data!
          .map(
            (dynamic i) =>
                Map<String, dynamic>.fromJson(i as Map<String, dynamic>),
          )
          .toList();''',
    '      _value = _result.data!.cast<Map<String, dynamic>>();',
  ),
];

void main() {
  final dir = Directory('lib/api/api_client');
  if (!dir.existsSync()) {
    stderr.writeln('lib/api/api_client not found - run this from app/.');
    exit(2);
  }

  var filesFixed = 0;
  var occurrencesFixed = 0;

  for (final entity in dir.listSync()) {
    if (entity is! File || !entity.path.endsWith('.g.dart')) continue;
    final original = entity.readAsStringSync();
    var content = original;
    var fileCount = 0;

    for (final (broken, fixed) in _fixes) {
      final count = broken.allMatches(content).length;
      if (count == 0) continue;
      content = content.replaceAll(broken, fixed);
      fileCount += count;
    }

    if (fileCount == 0) continue;
    entity.writeAsStringSync(content);
    filesFixed++;
    occurrencesFixed += fileCount;
  }

  stdout.writeln('fix_generated_client_bugs: fixed $occurrencesFixed occurrence(s) across $filesFixed file(s)');

  // A leftover means the generator produced a variant these patterns don't
  // match. Failing here is the point: the alternative is a confusing compile
  // error in generated code much later, with no hint that this script is
  // where the fix belongs.
  final leftovers = <String>[];
  for (final entity in dir.listSync()) {
    if (entity is! File || !entity.path.endsWith('.g.dart')) continue;
    final content = entity.readAsStringSync();
    if (content.contains('dynamic.fromJson') || content.contains('Map<String, dynamic>.fromJson')) {
      leftovers.add(entity.path);
    }
  }
  if (leftovers.isNotEmpty) {
    stderr.writeln(
      'fix_generated_client_bugs: unfixed .fromJson calls remain in:\n  ${leftovers.join('\n  ')}\n'
      'The generator emitted a variant this script does not match. Add it to _fixes.',
    );
    exit(1);
  }
}
