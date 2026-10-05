import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/core/env.dart';

part 'payment_sheet_launcher.g.dart';

/// How a trip through the payment sheet ended.
sealed class PaymentSheetResult {
  const PaymentSheetResult();
}

/// Stripe confirmed the intent. That is not our backend recording it - the
/// `payment_intent.succeeded` webhook does that - so callers refetch rather
/// than assume state has already moved.
final class PaymentSheetCompleted extends PaymentSheetResult {
  const PaymentSheetCompleted();
}

/// Backing out of the sheet. A decision, not a failure.
final class PaymentSheetCancelled extends PaymentSheetResult {
  const PaymentSheetCancelled();
}

final class PaymentSheetFailed extends PaymentSheetResult {
  const PaymentSheetFailed(this.message);

  final String message;
}

/// The one place the app talks to Stripe's payment sheet.
///
/// Exists as a seam. The sheet is a platform singleton that cannot run in a
/// test, so payment code that called it directly could only be checked by
/// hand - which is how money paths go unverified. Everything that takes a
/// payment goes through here, and tests substitute this.
abstract interface class PaymentSheetLauncher {
  /// False when this build has no Stripe key. Checked before any request is
  /// made, so a build that cannot take payment does not create a
  /// PaymentIntent it has no way to confirm.
  bool get isConfigured;

  Future<PaymentSheetResult> present(String clientSecret);
}

class StripePaymentSheetLauncher implements PaymentSheetLauncher {
  const StripePaymentSheetLauncher();

  @override
  bool get isConfigured => Env.hasStripe;

  @override
  Future<PaymentSheetResult> present(String clientSecret) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'RAWWERS',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (error) {
      if (error.error.code == FailureCode.Canceled) return const PaymentSheetCancelled();
      return PaymentSheetFailed(error.error.localizedMessage ?? 'That payment could not be completed.');
    } catch (_) {
      return const PaymentSheetFailed('That payment could not be completed.');
    }
    return const PaymentSheetCompleted();
  }
}

@Riverpod(keepAlive: true)
PaymentSheetLauncher paymentSheetLauncher(Ref ref) => const StripePaymentSheetLauncher();
