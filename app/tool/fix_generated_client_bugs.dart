// Post-processes generated lib/api/api_client/*.g.dart files to fix a
// confirmed swagger_to_dart/retrofit_generator bug: an endpoint whose
// response is a free-form object (`additionalProperties: true`, no
// `properties`) gets a deserializer that calls `dynamic.fromJson(...)`,
// which isn't valid Dart - `dynamic` has no such static method, so the
// whole file fails to compile the moment anything imports its class.
//
// The generator's own target type for these is `Map<String, dynamic>`
// (confirmed for every occurrence found - see the `late Map<String,
// dynamic> _value;` declaration immediately above each broken block), so
// the fix is simpler than what it attempted: the already-decoded response
// body IS the right value, with no per-entry deserialization needed.
//
// Run as part of `make gen-api`, after swagger_to_dart + build_runner, so
// this survives regeneration instead of being silently reverted by the
// next run - a one-off hand-edit to a generated file would violate "lib/api
// is generated, never hand-edited" by definition; a deterministic
// post-processing step run every time does not.
import 'dart:io';

const _broken = '''
      _value = _result.data!.map(
        (k, dynamic v) =>
            MapEntry(k, dynamic.fromJson(v as Map<String, dynamic>)),
      );''';

const _fixed = '      _value = _result.data!;';

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
    final content = entity.readAsStringSync();
    if (!content.contains(_broken)) continue;

    final count = _broken.allMatches(content).length;
    entity.writeAsStringSync(content.replaceAll(_broken, _fixed));
    filesFixed++;
    occurrencesFixed += count;
  }

  stdout.writeln('fix_generated_client_bugs: fixed $occurrencesFixed occurrence(s) across $filesFixed file(s)');
}
