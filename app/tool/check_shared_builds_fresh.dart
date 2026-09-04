// Guards the failure that cost an hour: a shared screen was changed, one
// flavor was rebuilt and checked on the simulator, and the other kept
// running a build from before the change. The source was correct the whole
// time; the app on the device was not, so tapping through the pro app
// "proved" a bug that had already been fixed.
//
// CI already builds both flavors on every commit, so shipping stale code
// was never the risk - being misled while verifying locally was. This
// checks the built artifacts against the shared sources they came from:
//
//   dart run tool/check_shared_builds_fresh.dart
//
// Wired into CI too, where it is nearly free and catches the case of a
// build step being reordered or dropped so that one flavor's artifact
// predates a shared change.
import 'dart:io';

/// Changing anything under these is visible in both apps, so verifying one
/// says nothing about the other.
const _sharedPaths = ['lib/features/shared/', 'lib/design/', 'lib/core/'];

/// Where each flavor's build lands, newest wins. Simulator and device
/// builds both count - the point is that something was built after the
/// change, not which target it was for.
const _flavorArtifacts = {
  'client': [
    'build/ios/iphonesimulator/RAWWERS.app',
    'build/app/outputs/flutter-apk/app-client-debug.apk',
  ],
  'pro': [
    'build/ios/iphonesimulator/RAWWERS Pro.app',
    'build/app/outputs/flutter-apk/app-pro-debug.apk',
  ],
};

void main() {
  if (!Directory('lib').existsSync()) {
    stderr.writeln('Run this from the app/ directory (lib/ not found).');
    exit(2);
  }

  final newestShared = _newestSharedChange();
  if (newestShared == null) {
    stdout.writeln('OK: no shared sources found to check.');
    return;
  }

  // Nothing built yet is not a failure - a clean checkout has no artifacts
  // and nothing stale to be misled by.
  final built = <String, DateTime>{};
  for (final entry in _flavorArtifacts.entries) {
    final stamp = _newestArtifact(entry.value);
    if (stamp != null) built[entry.key] = stamp;
  }
  if (built.isEmpty) {
    stdout.writeln('OK: neither flavor has been built yet, so neither can be stale.');
    return;
  }

  final stale = <String>[];
  for (final entry in built.entries) {
    if (entry.value.isBefore(newestShared.$2)) {
      stale.add('  ${entry.key}: built ${_ago(entry.value)}, but ${newestShared.$1} changed ${_ago(newestShared.$2)}');
    }
  }

  // One flavor built and the other never built is the exact shape of the
  // original bug: you verify the one you rebuilt and trust the other.
  final missing = _flavorArtifacts.keys.where((f) => !built.containsKey(f)).toList();
  if (missing.isNotEmpty && built.isNotEmpty) {
    for (final flavor in missing) {
      stale.add('  $flavor: never built, while the other flavor has been');
    }
  }

  if (stale.isEmpty) {
    stdout.writeln('OK: both flavors were built after the last shared change.');
    return;
  }

  stderr.writeln('Shared code changed but a flavor build is older than the change:');
  stderr.writeln(stale.join('\n'));
  stderr.writeln('');
  stderr.writeln('Anything you check in that app is showing you pre-change behaviour.');
  stderr.writeln('Rebuild both before trusting a tap-through:');
  stderr.writeln('  flutter build ios --simulator --flavor client -t lib/main_client.dart');
  stderr.writeln('  flutter build ios --simulator --flavor pro -t lib/main_pro.dart');
  exit(1);
}

/// The most recently modified file under any shared path, with its path.
(String, DateTime)? _newestSharedChange() {
  String? newestPath;
  DateTime? newest;
  for (final path in _sharedPaths) {
    final dir = Directory(path);
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      // Generated files are rewritten by codegen runs that change nothing a
      // person would look at, and would make every build look stale.
      if (entity.path.endsWith('.g.dart') || entity.path.endsWith('.freezed.dart')) continue;
      final modified = entity.statSync().modified;
      if (newest == null || modified.isAfter(newest)) {
        newest = modified;
        newestPath = entity.path;
      }
    }
  }
  return (newestPath == null || newest == null) ? null : (newestPath, newest);
}

DateTime? _newestArtifact(List<String> candidates) {
  DateTime? newest;
  for (final path in candidates) {
    final dir = Directory(path);
    final file = File(path);
    DateTime? stamp;
    if (dir.existsSync()) {
      stamp = dir.statSync().modified;
    } else if (file.existsSync()) {
      stamp = file.statSync().modified;
    }
    if (stamp != null && (newest == null || stamp.isAfter(newest))) newest = stamp;
  }
  return newest;
}

String _ago(DateTime when) {
  final delta = DateTime.now().difference(when);
  if (delta.inMinutes < 1) return 'just now';
  if (delta.inHours < 1) return '${delta.inMinutes}m ago';
  if (delta.inDays < 1) return '${delta.inHours}h ago';
  return '${delta.inDays}d ago';
}
