import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rawwers/design/components/r_button.dart';
import 'package:rawwers/design/tokens.dart';
import 'package:rawwers/features/pro/presentation_video/presentation_video_controller.dart';

/// How the in-app camera records the introduction video (owner, 2026-11-21:
/// never above 1080p, and small enough for the 100 MB limit).
///
/// - iOS: 1080p, 30 fps, video at 8 Mbit/s and sound at 128 kbit/s, so a
///   minute is about 61 MB. The iOS camera plugin honours the bit rate.
/// - Android: 720p, 30 fps. The Android camera plugin (CameraX) ignores a
///   bit rate and uses the phone's own for the quality, which at 1080p is
///   often 14-20 Mbit/s (100-150 MB a minute, over the limit); at 720p it is
///   usually 60-90 MB a minute. Clients are sent 720p at most anyway
///   (MUX_PLAYBACK_MAX_RESOLUTION).
class RecordingSettings {
  const RecordingSettings._();

  static ResolutionPreset get preset =>
      defaultTargetPlatform == TargetPlatform.android ? ResolutionPreset.high : ResolutionPreset.veryHigh;
  static const fps = 30;
  static const videoBitrate = 8000000;
  static const audioBitrate = 128000;
}

/// The camera behind the recording screen. A provider so widget tests record
/// without a camera.
abstract class VideoRecorderBackend {
  /// Opens a camera, the front one first (people record themselves).
  Future<void> open({required bool front});
  bool get canSwitch;
  Widget preview();
  Future<void> start();

  /// Stops and gives the file's path.
  Future<String> stop();
  Future<void> close();
}

final videoRecorderBackendProvider = Provider.autoDispose<VideoRecorderBackend>((ref) => CameraRecorderBackend());

/// Records with the in-app camera; returns the video, or null when the
/// photographer closes the screen. A provider so the screen's tests choose.
final videoRecorderProvider = Provider<Future<PickedVideo?> Function(BuildContext context, int maxSeconds)>((ref) {
  return (context, maxSeconds) => Navigator.of(context).push<PickedVideo>(
        MaterialPageRoute(fullscreenDialog: true, builder: (_) => RecordVideoScreen(maxSeconds: maxSeconds)),
      );
});

class CameraRecorderBackend implements VideoRecorderBackend {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];

  @override
  bool get canSwitch => _cameras.length > 1;

  @override
  Future<void> open({required bool front}) async {
    if (_cameras.isEmpty) _cameras = await availableCameras();
    if (_cameras.isEmpty) throw StateError('no camera');
    final wanted = front ? CameraLensDirection.front : CameraLensDirection.back;
    final camera = _cameras.firstWhere((c) => c.lensDirection == wanted, orElse: () => _cameras.first);
    await _controller?.dispose();
    final controller = CameraController(
      camera,
      RecordingSettings.preset,
      fps: RecordingSettings.fps,
      videoBitrate: RecordingSettings.videoBitrate,
      audioBitrate: RecordingSettings.audioBitrate,
    );
    _controller = controller;
    await controller.initialize();
    await controller.prepareForVideoRecording();
  }

  @override
  Widget preview() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return const SizedBox.shrink();
    return CameraPreview(controller);
  }

  @override
  Future<void> start() => _controller!.startVideoRecording();

  @override
  Future<String> stop() async => (await _controller!.stopVideoRecording()).path;

  @override
  Future<void> close() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }
}

/// Full screen: the camera's picture, one button to start and stop, the
/// time left. Stops by itself at the limit.
class RecordVideoScreen extends ConsumerStatefulWidget {
  const RecordVideoScreen({required this.maxSeconds, super.key});

  final int maxSeconds;

  @override
  ConsumerState<RecordVideoScreen> createState() => _RecordVideoScreenState();
}

class _RecordVideoScreenState extends ConsumerState<RecordVideoScreen> with WidgetsBindingObserver {
  late final VideoRecorderBackend _backend = ref.read(videoRecorderBackendProvider);
  bool _ready = false;
  bool _failed = false;
  bool _recording = false;
  bool _stopping = false;
  bool _front = true;
  int _elapsed = 0;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _open();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    _backend.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The camera is the system's: give it back when the app leaves, and
    // drop a recording cut short.
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _tick?.cancel();
      _backend.close();
      if (mounted) {
        setState(() {
          _ready = false;
          _recording = false;
          _elapsed = 0;
        });
      }
    } else if (state == AppLifecycleState.resumed && !_ready && !_failed) {
      _open();
    }
  }

  Future<void> _open() async {
    try {
      await _backend.open(front: _front);
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _start() async {
    try {
      await _backend.start();
    } catch (_) {
      if (mounted) setState(() => _failed = true);
      return;
    }
    setState(() {
      _recording = true;
      _elapsed = 0;
    });
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed++);
      if (_elapsed >= widget.maxSeconds) _stop();
    });
  }

  Future<void> _stop() async {
    if (_stopping) return;
    _stopping = true;
    _tick?.cancel();
    try {
      final path = await _backend.stop();
      final lower = path.toLowerCase();
      final video = PickedVideo(
        path: path,
        byteSize: await ref.read(fileSizeProvider)(path),
        contentType: lower.endsWith('.mov') ? 'video/quicktime' : 'video/mp4',
        durationSeconds: _elapsed.toDouble().clamp(1, widget.maxSeconds.toDouble()),
      );
      if (mounted) Navigator.of(context).pop(video);
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          _recording = false;
        });
      }
    } finally {
      _stopping = false;
    }
  }

  Future<void> _switch() async {
    setState(() {
      _ready = false;
      _front = !_front;
    });
    await _open();
  }

  String _clock(int seconds) => '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Record your video'),
        actions: [
          if (_ready && !_recording && _backend.canSwitch)
            IconButton(
              tooltip: 'Switch camera',
              icon: const Icon(Icons.cameraswitch_outlined),
              onPressed: _switch,
            ),
        ],
      ),
      body: _failed
          ? Center(
              key: const ValueKey('record-failed'),
              child: Padding(
                padding: const EdgeInsets.all(RSpace.s24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'The camera could not open. Allow RAWWERS to use the camera and microphone in Settings.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: RSpace.s16),
                    RButton(label: 'Close', onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: _ready ? Center(child: _backend.preview()) : const Center(child: CircularProgressIndicator()),
                ),
                Padding(
                  padding: const EdgeInsets.all(RSpace.s16),
                  child: Column(
                    children: [
                      Text(
                        _recording
                            ? '${_clock(_elapsed)} of ${_clock(widget.maxSeconds)}'
                            : 'Up to ${widget.maxSeconds} seconds. It stops by itself.',
                        key: const ValueKey('record-clock'),
                        style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: RSpace.s12),
                      RButton(
                        key: const ValueKey('record-button'),
                        label: _recording ? 'Stop' : 'Start recording',
                        onPressed: !_ready || _stopping ? null : (_recording ? _stop : _start),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// A file's size; a provider so tests need no file.
final fileSizeProvider = Provider<Future<int> Function(String path)>((ref) => (path) => File(path).length());
