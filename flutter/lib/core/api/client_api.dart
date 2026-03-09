import 'package:dio/dio.dart';

import '../../data/api/models/api_error.dart';

class ClientApiResult<T> {
  const ClientApiResult._({this.data, this.error});

  final T? data;
  final ClientApiFailure? error;

  bool get ok => error == null;

  static ClientApiResult<T> success<T>(T data) => ClientApiResult<T>._(data: data);
  static ClientApiResult<T> failure<T>(ClientApiFailure error) => ClientApiResult<T>._(error: error);
}

class ClientApiFailure {
  const ClientApiFailure({required this.kind, required this.code, required this.message, this.status});

  final String kind;
  final String code;
  final String message;
  final int? status;
}

class ClientApi {
  ClientApi(this._dio);

  final Dio _dio;

  ClientApiFailure _mapError(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      final payloadError = error.error;
      if (payloadError is ApiError) {
        final kind = switch (status) {
          401 => 'unauthorized',
          403 => 'forbidden',
          422 => 'validation',
          429 => 'rate_limited',
          int s when s >= 500 => 'server',
          _ => 'unknown'
        };
        return ClientApiFailure(kind: kind, code: payloadError.code, message: payloadError.message, status: status);
      }
      return ClientApiFailure(kind: 'network', code: 'network_error', message: error.message ?? 'Network error', status: status);
    }
    return const ClientApiFailure(kind: 'unknown', code: 'unknown_error', message: 'Unknown error');
  }

  Future<ClientApiResult<T>> _wrap<T>(Future<T> Function() fn) async {
    try {
      return ClientApiResult.success(await fn());
    } catch (error) {
      return ClientApiResult.failure(_mapError(error));
    }
  }

  Future<ClientApiResult<Map<String, dynamic>>> me() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/me')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> login(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/auth/login', data: payload)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> register(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/auth/register', data: payload)).data ?? {});
  Future<ClientApiResult<void>> logout(Map<String, dynamic> payload) => _wrap(() async => _dio.post('/auth/logout', data: payload));
  Future<ClientApiResult<Map<String, dynamic>>> refresh(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/auth/refresh', data: payload)).data ?? {});
  Future<ClientApiResult<void>> requestPasswordReset(Map<String, dynamic> payload) => _wrap(() async => _dio.post('/auth/password-reset/request', data: payload));
  Future<ClientApiResult<void>> confirmPasswordReset(Map<String, dynamic> payload) => _wrap(() async => _dio.post('/auth/password-reset/confirm', data: payload));
  Future<ClientApiResult<void>> requestVerifyEmail(Map<String, dynamic> payload) => _wrap(() async => _dio.post('/auth/verify-email/request', data: payload));
  Future<ClientApiResult<void>> confirmVerifyEmail(Map<String, dynamic> payload) => _wrap(() async => _dio.post('/auth/verify-email/confirm', data: payload));

  Future<ClientApiResult<Map<String, dynamic>>> getClientAccess() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/client/access')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> clientDiscover(Map<String, dynamic> params) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/client/discover', queryParameters: params)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> clientMatch(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/client/match', data: payload)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> searchPros(Map<String, dynamic> params) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/search/pros', queryParameters: params)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> getProPublic(String proUserId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/pros/$proUserId/public')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> getClientProProfile(String proUserId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/client/pros/$proUserId')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> joinWaitlist(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/client/waitlist', data: payload)).data ?? {});

  Future<ClientApiResult<Map<String, dynamic>>> createBookingRequest(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/client/bookings/request', data: payload)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> getClientBooking(String bookingId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/client/bookings/$bookingId')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> payClientBooking(String bookingId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/client/bookings/$bookingId/pay', data: payload)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> submitTimeWindows(String bookingRequestId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/client/bookings/$bookingRequestId/time-windows', data: payload)).data ?? {});

  Future<ClientApiResult<Map<String, dynamic>>> getBookingRequest(String requestId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/booking-requests/$requestId')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> cancelBookingRequest(String requestId) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/booking-requests/$requestId/cancel')).data ?? {});

  Future<ClientApiResult<Map<String, dynamic>>> getGig(String gigId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/gigs/$gigId')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> getGigConsent(String gigId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/gigs/$gigId/consent')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> putGigConsent(String gigId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.put<Map<String, dynamic>>('/gigs/$gigId/consent', data: payload)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> createGigStripeIntent(String gigId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/gigs/$gigId/payments/stripe/create-intent', data: payload)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> createGigReview(String gigId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/gigs/$gigId/review', data: payload)).data ?? {});

  Future<ClientApiResult<Map<String, dynamic>>> listGigMedia(String gigId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/gigs/$gigId/media')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> getGigMediaSignedUrl(String gigId, String mediaAssetId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/gigs/$gigId/media/$mediaAssetId/signed-url')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> downloadGigMedia(String gigId, String mediaAssetId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/gigs/$gigId/media/$mediaAssetId/download')).data ?? {});

  Future<ClientApiResult<Map<String, dynamic>>> getProofGallery(String galleryId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/proof-galleries/$galleryId')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> saveSelection(String galleryId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/proof-galleries/$galleryId/selections', data: payload)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> submitSelection(String galleryId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/proof-galleries/$galleryId/selections/submit', data: payload)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> createUpsellIntent(String galleryId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/proof-galleries/$galleryId/upsell/create-intent', data: payload)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> getGalleryDownloads(String galleryId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/proof-galleries/$galleryId/downloads')).data ?? {});

  Future<ClientApiResult<Map<String, dynamic>>> listDisputes(Map<String, dynamic> params) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/disputes', queryParameters: params)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> createDispute(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/disputes', data: payload)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> getDispute(String disputeId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/disputes/$disputeId')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> cancelDispute(String disputeId) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/disputes/$disputeId/cancel')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> addDisputeEvidence(String disputeId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/disputes/$disputeId/evidence', data: payload)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> addDisputeMessage(String disputeId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/disputes/$disputeId/messages', data: payload)).data ?? {});

  Future<ClientApiResult<Map<String, dynamic>>> putContact(Map<String, dynamic> payload) => _wrap(() async => (await _dio.put<Map<String, dynamic>>('/me/contact', data: payload)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> getClientPreference() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/me/client-preference')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> putClientPreference(Map<String, dynamic> payload) => _wrap(() async => (await _dio.put<Map<String, dynamic>>('/me/client-preference', data: payload)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> getNotificationPreferences() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/me/notification-preferences')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> putNotificationPreferences(Map<String, dynamic> payload) => _wrap(() async => (await _dio.put<Map<String, dynamic>>('/me/notification-preferences', data: payload)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> listNotifications(Map<String, dynamic> params) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/me/notifications', queryParameters: params)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> readAllNotifications() => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/me/notifications/read-all')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> readNotification(String notificationId) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/me/notifications/$notificationId/read')).data ?? {});

  Future<ClientApiResult<Map<String, dynamic>>> rewardsBalance() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/me/rewards/balance')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> rewardsBalanceShared() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/rewards/balance')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> rewardsLedger(Map<String, dynamic> params) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/rewards/ledger', queryParameters: params)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> rewardsSpend(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/rewards/spend', data: payload)).data ?? {});

  Future<ClientApiResult<Map<String, dynamic>>> printsCatalog() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/prints/catalog')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> myPrintOrders(Map<String, dynamic> params) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/prints/orders/mine', queryParameters: params)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> printOrderDetail(String orderId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/prints/orders/$orderId')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> payPrintOrder(String orderId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/prints/orders/$orderId/pay', data: payload)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> updatePrintOrder(String orderId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.put<Map<String, dynamic>>('/prints/orders/$orderId', data: payload)).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> createGigPrintOrder(String gigId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/gigs/$gigId/prints/orders', data: payload)).data ?? {});

  Future<ClientApiResult<Map<String, dynamic>>> myReferralCode() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/me/referral-code')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> regenerateReferralCode() => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/me/referral-code/regenerate')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> referralStats() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/me/referrals/stats')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> referralLanding(String code) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/ref/$code')).data ?? {});
  Future<ClientApiResult<Map<String, dynamic>>> claimReferral(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/referrals/claim', data: payload)).data ?? {});

  Future<ClientApiResult<Map<String, dynamic>>> track(String name, Map<String, dynamic> props) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/analytics', data: {'name': name, 'props': props})).data ?? {});
}
