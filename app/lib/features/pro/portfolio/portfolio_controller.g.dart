// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$portfolioControllerHash() =>
    r'58cbb691c388ecf7debdc4f970b26c1152df670b';

/// See also [PortfolioController].
@ProviderFor(PortfolioController)
final portfolioControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      PortfolioController,
      ProPortfolioResponse
    >.internal(
      PortfolioController.new,
      name: r'portfolioControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$portfolioControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PortfolioController = AutoDisposeAsyncNotifier<ProPortfolioResponse>;
String _$portfolioUploadControllerHash() =>
    r'541f088ac69824d5cfc5f4e6d8f9849da82aa505';

/// Progress for the batch currently uploading, keyed by a per-file id.
///
/// Separate from [PortfolioController] on purpose: the grid should keep
/// rendering what is already uploaded while new files climb, and folding
/// progress into the list's AsyncValue would blank it on every tick.
///
/// Copied from [PortfolioUploadController].
@ProviderFor(PortfolioUploadController)
final portfolioUploadControllerProvider =
    AutoDisposeNotifierProvider<
      PortfolioUploadController,
      Map<String, UploadProgress>
    >.internal(
      PortfolioUploadController.new,
      name: r'portfolioUploadControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$portfolioUploadControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PortfolioUploadController =
    AutoDisposeNotifier<Map<String, UploadProgress>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
