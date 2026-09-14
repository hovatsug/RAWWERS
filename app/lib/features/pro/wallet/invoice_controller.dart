import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/gig_invoice_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'invoice_controller.g.dart';

/// One gig's invoice.
///
/// Fetched rather than assembled from the ledger row that opened it: the
/// ledger carries gross, fee and net, and every other line - the split inside
/// the fee, the client's credit, the photo count - exists only on the server.
/// Reconstructing them here would be the app doing arithmetic the server
/// already did, which is how two answers to one question appear.
@riverpod
Future<GigInvoiceView> invoice(Ref ref, {required String gigId}) async {
  final client = ref.read(payoutsClientProvider);
  final result = await apiCall(
    () => client.getMyInvoiceV1ProEarningsInvoicesGigIdGet(
      gigId: gigId,
      authorization: null,
      xMinusUserMinusId: null,
    ),
  );
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}
