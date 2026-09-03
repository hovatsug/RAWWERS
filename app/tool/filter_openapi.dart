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
      if (excludedByPrefix || tags.intersection(_excludedTags).isNotEmpty) {
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

  final outFile = File(outPath);
  await outFile.create(recursive: true);
  await outFile.writeAsString(jsonEncode(doc));

  stdout.writeln('kept $keptOps ops, dropped $droppedOps ops');
  stdout.writeln('kept ${prunedSchemas.length} of ${schemas.length} component schemas');
  stdout.writeln('wrote $outPath');
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
