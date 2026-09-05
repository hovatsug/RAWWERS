import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/media_purpose.dart';
import 'package:rawwers/api/models/media_visibility.dart';
import 'package:rawwers/api/models/portfolio_niche_tags_request.dart';
import 'package:rawwers/api/models/pro_portfolio_response.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/api_failure.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'portfolio_controller.g.dart';

/// One photo on its way up.
@immutable
class UploadProgress {
  const UploadProgress({required this.fileName, required this.sent, required this.total, this.error});

  final String fileName;
  final int sent;
  final int total;
  final String? error;

  double get fraction => total <= 0 ? 0 : (sent / total).clamp(0, 1).toDouble();
  bool get isDone => error == null && total > 0 && sent >= total;

  UploadProgress copyWith({int? sent, String? error}) =>
      UploadProgress(fileName: fileName, sent: sent ?? this.sent, total: total, error: error ?? this.error);
}

@riverpod
class PortfolioController extends _$PortfolioController {
  @override
  Future<ProPortfolioResponse> build() async {
    final client = ref.read(proOnboardingClientProvider);
    final result = await apiCall(
      () => client.getMyPortfolioV1ProMePortfolioGet(authorization: null, xMinusUserMinusId: null),
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,
    };
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  Future<String?> tagNiches({required String mediaAssetId, required List<String> nicheSlugs}) async {
    final client = ref.read(proOnboardingClientProvider);
    final result = await apiCall(
      () => client.tagPortfolioMediaNichesV1ProMePortfolioMediaAssetIdNichesPost(
        mediaAssetId: mediaAssetId,
        requestBody: PortfolioNicheTagsRequest(nicheSlugs: nicheSlugs),
        authorization: null,
        xMinusUserMinusId: null,
      ),
    );
    switch (result) {
      case Ok():
        await refresh();
        return null;
      case Err(:final failure):
        return switch (failure) {
          NetworkError() || Timeout() => 'Could not reach the server. Check your connection.',
          BusinessError(:final message) => message,
          _ => 'Could not save those tags.',
        };
    }
  }
}

/// Progress for the batch currently uploading, keyed by a per-file id.
///
/// Separate from [PortfolioController] on purpose: the grid should keep
/// rendering what is already uploaded while new files climb, and folding
/// progress into the list's AsyncValue would blank it on every tick.
@riverpod
class PortfolioUploadController extends _$PortfolioUploadController {
  @override
  Map<String, UploadProgress> build() => const {};

  /// Picks photos and uploads them one at a time.
  ///
  /// Sequential rather than parallel: a photographer picking twenty
  /// full-resolution frames on a phone connection would otherwise open
  /// twenty concurrent PUTs, and the first thing to fail would be all of
  /// them. Each file's outcome is independent - one failure does not
  /// abandon the rest.
  Future<void> pickAndUpload() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isEmpty) return;

    final service = ref.read(photoUploadServiceProvider);

    for (final file in files) {
      final key = '${DateTime.now().microsecondsSinceEpoch}-${file.name}';
      final length = await file.length();
      state = {
        ...state,
        key: UploadProgress(fileName: file.name, sent: 0, total: length),
      };

      final result = await service.uploadPhoto(
        openFile: () => File(file.path).openRead().map(Uint8List.fromList),
        fileSize: length,
        purpose: MediaPurpose.portfolioReel,
        // Explicit rather than relying on the server default. A portfolio
        // photo nobody can see is the bug this whole feature exists to
        // avoid, and the default lives in a different codebase.
        visibility: MediaVisibility.public,
        contentType: _contentTypeFor(file.name),
        fileName: file.name,
        onSendProgress: (sent, total) {
          final current = state[key];
          if (current == null) return;
          state = {...state, key: current.copyWith(sent: sent)};
        },
      );

      switch (result) {
        case Ok():
          final current = state[key];
          if (current != null) {
            state = {...state, key: current.copyWith(sent: current.total)};
          }
        case Err(:final failure):
          final current = state[key];
          if (current != null) {
            state = {...state, key: current.copyWith(error: _explain(failure))};
          }
      }
    }

    await ref.read(portfolioControllerProvider.notifier).refresh();
    // Finished rows are cleared, failures stay: a photographer needs to
    // know which of the twenty did not make it.
    state = {
      for (final entry in state.entries)
        if (entry.value.error != null) entry.key: entry.value,
    };
  }

  void dismiss(String key) => state = {...state}..remove(key);

  String _explain(ApiFailure failure) => switch (failure) {
        NetworkError() || Timeout() => 'Upload failed - check your connection.',
        BusinessError(:final message) => message,
        Validation() => 'That file was rejected.',
        _ => 'Upload failed.',
      };

  /// R2 stores what we declare, and a wrong type makes the image unusable
  /// later even though the bytes are fine.
  String _contentTypeFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'image/heic';
    return 'image/jpeg';
  }
}
