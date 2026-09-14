// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$earningsSummaryHash() => r'15f6d8ab5da3ef7825432cb17d7a2113ee214cfc';

/// Totals across every completed gig.
///
/// A separate request rather than something derived from the ledger the
/// Wallet already has. The ledger carries gross, fee and net per entry and
/// nothing about how the fee divides, so totalling it here would produce
/// numbers the invoices behind them do not agree with.
///
/// Copied from [earningsSummary].
@ProviderFor(earningsSummary)
final earningsSummaryProvider =
    AutoDisposeFutureProvider<InvoiceSummaryView>.internal(
      earningsSummary,
      name: r'earningsSummaryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$earningsSummaryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EarningsSummaryRef = AutoDisposeFutureProviderRef<InvoiceSummaryView>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
