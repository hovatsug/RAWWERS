// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fx_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fxRatesHash() => r'e891383f07aee8db016130afa06b6841b910b51e';

/// The day's display rates (GET /v1/fx/rates). On any failure: none, so
/// every approximation is dropped and "Charged in EUR" is shown instead.
/// Never used for money.
///
/// Copied from [fxRates].
@ProviderFor(fxRates)
final fxRatesProvider = FutureProvider<FxRates>.internal(
  fxRates,
  name: r'fxRatesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fxRatesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FxRatesRef = FutureProviderRef<FxRates>;
String _$displayCurrencyCodeHash() =>
    r'eccb1774d433c2a858f2709582dbd015b699ea3d';

/// The currency approximations are shown in now.
///
/// Copied from [displayCurrencyCode].
@ProviderFor(displayCurrencyCode)
final displayCurrencyCodeProvider = AutoDisposeProvider<String>.internal(
  displayCurrencyCode,
  name: r'displayCurrencyCodeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$displayCurrencyCodeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DisplayCurrencyCodeRef = AutoDisposeProviderRef<String>;
String _$displayCurrencyHash() => r'b34ac4a51460b4891fdfab99226b6e4fbe7ab770';

/// The signed-in user's display currency and what they may choose from
/// (Account > Display currency). Null for a guest.
///
/// Copied from [DisplayCurrency].
@ProviderFor(DisplayCurrency)
final displayCurrencyProvider =
    AutoDisposeAsyncNotifierProvider<
      DisplayCurrency,
      DisplayCurrencyView?
    >.internal(
      DisplayCurrency.new,
      name: r'displayCurrencyProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$displayCurrencyHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DisplayCurrency = AutoDisposeAsyncNotifier<DisplayCurrencyView?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
