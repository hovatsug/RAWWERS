import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/invoice_summary_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'summary_controller.g.dart';

/// Totals across every completed gig.
///
/// A separate request rather than something derived from the ledger the
/// Wallet already has. The ledger carries gross, fee and net per entry and
/// nothing about how the fee divides, so totalling it here would produce
/// numbers the invoices behind them do not agree with.
@riverpod
Future<InvoiceSummaryView> earningsSummary(Ref ref) async {
  final client = ref.read(payoutsClientProvider);
  final result = await apiCall(
    () => client.getMyEarningsSummaryV1ProEarningsSummaryGet(
      authorization: null,
      xMinusUserMinusId: null,
    ),
  );
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}
