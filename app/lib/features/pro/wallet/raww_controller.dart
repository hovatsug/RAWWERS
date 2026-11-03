import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/models/pro_raww_view.dart';
import 'package:rawwers/core/api/api_call.dart';
import 'package:rawwers/core/api/providers.dart';
import 'package:rawwers/core/api/result.dart';

part 'raww_controller.g.dart';

/// The photographer's RAWW: spendable, pending with the dates they settle,
/// and when the spendable balance expires. Its own request, so a failure
/// here never takes the rest of the Wallet down with it.
@riverpod
Future<ProRawwView> raww(Ref ref) async {
  final result = await apiCall(
    () => ref.read(shelfClientProvider).myRawwV1ProRawwGet(authorization: null, xMinusUserMinusId: null),
  );
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}
