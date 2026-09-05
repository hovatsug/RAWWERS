// Filters the backend's OpenAPI 3.1 document down to the MVP surface these
// two Flutter apps actually need, before handing it to swagger_to_dart:
//   - drops every operation whose tags intersect _excludedTags
//   - drops every operation under _excludedPathPrefixes, regardless of tag
//     (some /v1/admin/* endpoints are tagged with a domain tag instead of
//     "admin" - tag filtering alone misses them)
//   - prunes component schemas no longer referenced by what's left
//
// Usage:
//   dart run tool/filter_openapi.dart --source <url-or-file-path> --out <path>
import 'dart:convert';
import 'dart:io';

const _excludedTags = {
  'prints_fulfillment', 'store', 'studioverse', 'repairs',
  'legacy_shoot', 'courses', 'referrals_rewards', 'admin',
};

const _excludedPathPrefixes = ['/v1/admin/'];

// Rescued from an excluded tag. Gear registration is tagged "repairs"
// because the repairs marketplace consumes it, but to a photographer it is
// profile data - the bodies and lenses they own - and the pro app needs it
// without pulling in repair tickets, partners and loaner requests. An
// allowlist entry here beats re-tagging the backend, which would rename
// every generated method for the sake of a client-side concern.
const _includedPathPrefixes = ['/v1/pro/me/gear-items'];

const _httpMethods = {'get', 'post', 'put', 'patch', 'delete', 'head', 'options'};

Future<void> main(List<String> arguments) async {
  final args = _parseArgs(arguments);
  final source = args['source'];
  final outPath = args['out'] ?? 'openapi/schema.filtered.json';
  if (source == null) {
    stderr.writeln('Usage: dart run tool/filter_openapi.dart --source <url-or-file-path> --out <path>');
    exit(2);
  }

  final raw = source.startsWith('http://') || source.startsWith('https://')
      ? await _fetch(source)
      : await File(source).readAsString();

  final doc = jsonDecode(raw) as Map<String, dynamic>;
  final paths = (doc['paths'] as Map<String, dynamic>? ?? {});

  var keptOps = 0;
  var droppedOps = 0;
  final keptPaths = <String, dynamic>{};

  paths.forEach((path, item) {
    final itemMap = item as Map<String, dynamic>;
    final excludedByPrefix = _excludedPathPrefixes.any(path.startsWith);
    final newItem = <String, dynamic>{};
    itemMap.forEach((method, op) {
      if (!_httpMethods.contains(method)) {
        newItem[method] = op;
        return;
      }
      final opMap = op as Map<String, dynamic>;
      final tags = (opMap['tags'] as List?)?.cast<String>().toSet() ?? {};
      final rescued = _includedPathPrefixes.any(path.startsWith);
      if (!rescued && (excludedByPrefix || tags.intersection(_excludedTags).isNotEmpty)) {
        droppedOps++;
        return;
      }
      newItem[method] = op;
      keptOps++;
    });
    if (newItem.isNotEmpty) {
      keptPaths[path] = newItem;
    }
  });

  doc['paths'] = keptPaths;

  // FastAPI qualifies a schema name only when two modules define classes
  // with the same name: app__schemas__scheduling__AvailabilityRuleView vs
  // app__schemas__onboarding__AvailabilityRuleView. The Dart generator
  // takes the last path segment as the class name, so both collapse into
  // one AvailabilityRuleView - and whichever loses is silently wrong.
  // It cost a runtime "Null is not a subtype of num" on the first read of
  // /v1/pro/scheduling/availability-rules, invisible to flutter analyze.
  // Renaming them apart here gives the generator two distinct classes.
  _disambiguateQualifiedSchemas(doc);

  final components = doc['components'] as Map<String, dynamic>? ?? {};
  final schemas = (components['schemas'] as Map<String, dynamic>? ?? {});

  final live = <String>{};
  var frontier = <String>{};
  _collectRefs(keptPaths, frontier);
  while (frontier.isNotEmpty) {
    live.addAll(frontier);
    final next = <String>{};
    for (final name in frontier) {
      _collectRefs(schemas[name], next);
    }
    next.removeAll(live);
    frontier = next;
  }

  final prunedSchemas = <String, dynamic>{
    for (final entry in schemas.entries)
      if (live.contains(entry.key)) entry.key: entry.value,
  };
  components['schemas'] = prunedSchemas;
  doc['components'] = components;

  // After pruning: only the schemas that actually reach the generator can
  // clash into one Dart class. Excluded surface (admin, referrals) has its
  // own duplicate titles that are none of this app's business.
  _assertTitlesUnique(prunedSchemas);

  final outFile = File(outPath);
  await outFile.create(recursive: true);
  await outFile.writeAsString(jsonEncode(doc));

  stdout.writeln('kept $keptOps ops, dropped $droppedOps ops');
  stdout.writeln('kept ${prunedSchemas.length} of ${schemas.length} component schemas');
  stdout.writeln('wrote $outPath');
}

/// Rewrites `app__schemas__<module>__<Name>` schema names to `<Module><Name>`
/// and updates every `$ref` that points at them.
void _disambiguateQualifiedSchemas(Map<String, dynamic> doc) {
  final components = doc['components'] as Map<String, dynamic>? ?? {};
  final schemas = components['schemas'] as Map<String, dynamic>? ?? {};

  final renames = <String, String>{};
  for (final name in schemas.keys) {
    if (!name.startsWith('app__schemas__')) continue;
    final parts = name.split('__').where((p) => p.isNotEmpty).toList();
    if (parts.length < 4) continue;
    final module = parts[parts.length - 2];
    final className = parts.last;
    final prefix = module
        .split('_')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join();
    var candidate = '$prefix$className';
    // Do not collide with an existing schema while fixing a collision.
    var suffix = 2;
    while (schemas.containsKey(candidate) || renames.containsValue(candidate)) {
      candidate = '$prefix$className$suffix';
      suffix++;
    }
    renames[name] = candidate;
  }
  if (renames.isEmpty) return;

  for (final entry in renames.entries) {
    final schema = schemas.remove(entry.key);
    // swagger_to_dart names the Dart class from `title`, not the schema
    // key, and FastAPI leaves both collided schemas titled identically -
    // so renaming the key alone regenerates the very same clash.
    if (schema is Map<String, dynamic>) schema['title'] = entry.value;
    schemas[entry.value] = schema;
  }
  _rewriteRefs(doc, renames);
  components['schemas'] = schemas;
  doc['components'] = components;

  renames.forEach((from, to) => stdout.writeln('disambiguated schema $from -> $to'));
}

/// swagger_to_dart derives the Dart class name from `title`, so two schemas
/// sharing one produce a single class and whichever loses is silently the
/// wrong shape. Renaming above fixes the case FastAPI flags; this catches
/// any other duplicate before it reaches the generator, where it would only
/// surface as a runtime cast error on whichever screen reads it first.
void _assertTitlesUnique(Map<String, dynamic> schemas) {
  final byTitle = <String, List<String>>{};
  schemas.forEach((name, schema) {
    if (schema is! Map) return;
    final title = schema['title'];
    if (title is String) byTitle.putIfAbsent(title, () => []).add(name);
  });

  final clashes = byTitle.entries.where((e) => e.value.length > 1).toList();
  if (clashes.isEmpty) return;

  stderr.writeln('Schema titles must be unique - they become Dart class names:');
  for (final clash in clashes) {
    stderr.writeln('  "${clash.key}" claimed by: ${clash.value.join(', ')}');
  }
  stderr.writeln('Rename one of the backend schema classes, or extend');
  stderr.writeln('_disambiguateQualifiedSchemas to cover this case.');
  exit(1);
}

void _rewriteRefs(dynamic node, Map<String, String> renames) {
  if (node is Map) {
    final ref = node[r'$ref'];
    if (ref is String && ref.startsWith('#/components/schemas/')) {
      final target = ref.split('/').last;
      final replacement = renames[target];
      if (replacement != null) {
        node[r'$ref'] = '#/components/schemas/$replacement';
      }
    }
    for (final value in node.values) {
      _rewriteRefs(value, renames);
    }
  } else if (node is List) {
    for (final value in node) {
      _rewriteRefs(value, renames);
    }
  }
}

Future<String> _fetch(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      throw StateError('GET $url failed: HTTP ${response.statusCode}');
    }
    return await response.transform(utf8.decoder).join();
  } finally {
    client.close();
  }
}

void _collectRefs(dynamic node, Set<String> refs) {
  if (node is Map) {
    final ref = node[r'$ref'];
    if (ref is String && ref.startsWith('#/components/schemas/')) {
      refs.add(ref.split('/').last);
    }
    for (final value in node.values) {
      _collectRefs(value, refs);
    }
  } else if (node is List) {
    for (final value in node) {
      _collectRefs(value, refs);
    }
  }
}

Map<String, String> _parseArgs(List<String> arguments) {
  final result = <String, String>{};
  for (var i = 0; i < arguments.length - 1; i++) {
    if (arguments[i] == '--source') result['source'] = arguments[i + 1];
    if (arguments[i] == '--out') result['out'] = arguments[i + 1];
  }
  return result;
}
