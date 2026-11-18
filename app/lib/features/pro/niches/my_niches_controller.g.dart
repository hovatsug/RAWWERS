// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_niches_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myNichesControllerHash() =>
    r'd7da6772a349fbb680cc59f79115a8ee50e177af';

/// The photographer's own niches (GET /v1/pro/niches/mine), with the
/// fewest and most they may have.
///
/// Every change sends the whole list (PUT /v1/pro/me/niches) and the
/// server decides: the maximum, the minimum, exactly one main niche, and no
/// niche removed while a booking in it is not finished. A refusal comes
/// back as the server's own sentence, shown as it is.
///
/// Copied from [MyNichesController].
@ProviderFor(MyNichesController)
final myNichesControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      MyNichesController,
      UpdateMyNichesResponse
    >.internal(
      MyNichesController.new,
      name: r'myNichesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$myNichesControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MyNichesController = AutoDisposeAsyncNotifier<UpdateMyNichesResponse>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
