// Fails if main_client.dart's import graph reaches into lib/features/pro/,
// or main_pro.dart's reaches into lib/features/client/. Run via:
//   dart run tool/check_flavor_isolation.dart
// Wired into CI as its own step (see .github/workflows/ci.yml).
import 'dart:io';

const _packageName = 'rawwers';

final _importPattern = RegExp(r'''(?:import|export)\s+['"]([^'"]+)['"]''');

class _Entrypoint {
  const _Entrypoint(this.mainFile, this.forbiddenSegment, this.label);
  final String mainFile;
  final String forbiddenSegment;
  final String label;
}

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('Run this from the app/ directory (lib/ not found).');
    exit(2);
  }

  const entrypoints = [
    _Entrypoint('lib/main_client.dart', 'features/pro/', 'main_client.dart'),
    _Entrypoint('lib/main_pro.dart', 'features/client/', 'main_pro.dart'),
  ];

  var failed = false;

  for (final entry in entrypoints) {
    final visited = <String>{};
    final violations = <String>[];
    _walk(entry.mainFile, visited, violations, entry.forbiddenSegment);

    if (violations.isEmpty) {
      stdout.writeln('OK: ${entry.label} never imports ${entry.forbiddenSegment}');
    } else {
      failed = true;
      stderr.writeln('FAIL: ${entry.label} transitively imports files under ${entry.forbiddenSegment}:');
      for (final v in violations) {
        stderr.writeln('  - $v');
      }
    }
  }

  exit(failed ? 1 : 0);
}

void _walk(String filePath, Set<String> visited, List<String> violations, String forbiddenSegment) {
  final normalized = filePath.replaceAll('\\', '/');
  if (visited.contains(normalized)) return;
  visited.add(normalized);

  if (normalized.contains(forbiddenSegment)) {
    violations.add(normalized);
    // Still walk its imports too, so one violation doesn't hide siblings.
  }

  final file = File(normalized);
  if (!file.existsSync()) return;

  final content = file.readAsStringSync();
  final dir = normalized.contains('/') ? normalized.substring(0, normalized.lastIndexOf('/')) : '.';

  for (final match in _importPattern.allMatches(content)) {
    final target = match.group(1)!;
    if (target.startsWith('dart:')) continue;

    String? resolved;
    if (target.startsWith('package:$_packageName/')) {
      resolved = 'lib/${target.substring('package:$_packageName/'.length)}';
    } else if (target.startsWith('package:')) {
      continue; // external package, not part of this project's tree
    } else {
      resolved = _joinPath(dir, target);
    }

    _walk(resolved, visited, violations, forbiddenSegment);
  }
}

String _joinPath(String dir, String relative) {
  final parts = [...dir.split('/'), ...relative.split('/')];
  final stack = <String>[];
  for (final part in parts) {
    if (part.isEmpty || part == '.') continue;
    if (part == '..') {
      if (stack.isNotEmpty) stack.removeLast();
    } else {
      stack.add(part);
    }
  }
  return stack.join('/');
}
