// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raww_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$rawwHash() => r'122439d74278bfbbec921d49be30d7a9c0c2f12d';

/// The photographer's RAWW: spendable, pending with the dates they settle,
/// and when the spendable balance expires. Its own request, so a failure
/// here never takes the rest of the Wallet down with it.
///
/// Copied from [raww].
@ProviderFor(raww)
final rawwProvider = AutoDisposeFutureProvider<ProRawwView>.internal(
  raww,
  name: r'rawwProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$rawwHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RawwRef = AutoDisposeFutureProviderRef<ProRawwView>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
