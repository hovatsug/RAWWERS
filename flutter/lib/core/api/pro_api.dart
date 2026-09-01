import 'package:dio/dio.dart';

import '../../data/api/models/api_error.dart';

class ProApiResult<T> {
  const ProApiResult._({this.data, this.error});

  final T? data;
  final ProApiFailure? error;

  bool get ok => error == null;

  static ProApiResult<T> success<T>(T data) => ProApiResult<T>._(data: data);
  static ProApiResult<T> failure<T>(ProApiFailure error) => ProApiResult<T>._(error: error);
}

class ProApiFailure {
  const ProApiFailure({required this.kind, required this.code, required this.message, this.status});

  final String kind;
  final String code;
  final String message;
  final int? status;
}

class ProApi {
  ProApi(this._dio);

  final Dio _dio;

  ProApiFailure _mapError(Object error) {
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
        return ProApiFailure(kind: kind, code: payloadError.code, message: payloadError.message, status: status);
      }
      return ProApiFailure(kind: 'network', code: 'network_error', message: error.message ?? 'Network error', status: status);
    }
    return const ProApiFailure(kind: 'unknown', code: 'unknown_error', message: 'Unknown error');
  }

  Future<ProApiResult<T>> _wrap<T>(Future<T> Function() fn) async {
    try {
      final data = await fn();
      return ProApiResult.success(data);
    } catch (error) {
      return ProApiResult.failure(_mapError(error));
    }
  }

  Future<ProApiResult<Map<String, dynamic>>> me() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/me')).data ?? {});
  Future<ProApiResult<void>> logout(String refreshToken) => _wrap(() async => _dio.post('/auth/logout', data: {'refresh_token': refreshToken, 'revoke_family': true}));
  Future<ProApiResult<Map<String, dynamic>>> refresh(String refreshToken) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/auth/refresh', data: {'refresh_token': refreshToken})).data ?? {});
  Future<ProApiResult<void>> requestVerifyEmail(String email) => _wrap(() async => _dio.post('/auth/verify-email/request', data: {'email': email}));
  Future<ProApiResult<void>> confirmVerifyEmail(String code) => _wrap(() async => _dio.post('/auth/verify-email/confirm', data: {'code': code}));

  Future<ProApiResult<Map<String, dynamic>>> getMyProProfile() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/pro/me/profile')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> updateMyProProfile(Map<String, dynamic> payload) => _wrap(() async => (await _dio.put<Map<String, dynamic>>('/pro/me/profile', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getOnboarding() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/pro/onboarding')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getOnboardingChecks() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/pro/onboarding/checks')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> onboardingStart() => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/pro/onboarding/start')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> onboardingCompleteProfile(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/pro/onboarding/complete-profile', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> onboardingSelectNiches(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/pro/onboarding/select-niches', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> onboardingConfigurePackages(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/pro/onboarding/configure-packages', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> onboardingUploadPortfolio(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/pro/onboarding/upload-portfolio', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> onboardingSubmitKyc(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/pro/onboarding/submit-kyc', data: payload)).data ?? {});
  Future<ProApiResult<List<dynamic>>> listNiches() => _wrap(() async => (await _dio.get<List<dynamic>>('/niches')).data ?? <dynamic>[]);
  Future<ProApiResult<Map<String, dynamic>>> getMyNiches() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/pro/niches/mine')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> putMyNiches(Map<String, dynamic> payload) => _wrap(() async => (await _dio.put<Map<String, dynamic>>('/pro/niches/mine', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> createPackage(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/pro/me/packages', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> updatePackage(String packageId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.put<Map<String, dynamic>>('/pro/me/packages/$packageId', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> disablePackage(String packageId) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/pro/me/packages/$packageId/disable')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> tagPortfolioMediaNiches(String mediaAssetId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/pro/me/portfolio/$mediaAssetId/niches', data: payload)).data ?? {});

  Future<ProApiResult<Map<String, dynamic>>> searchPros(Map<String, dynamic> params) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/search/pros', queryParameters: params)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getPublicProProfile(String proUserId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/pros/$proUserId/public')).data ?? {});

  Future<ProApiResult<Map<String, dynamic>>> getAvailabilityRules() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/pro/scheduling/availability-rules')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> putAvailabilityRules(Map<String, dynamic> payload) => _wrap(() async => (await _dio.put<Map<String, dynamic>>('/pro/scheduling/availability-rules', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getSchedulingExceptions() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/pro/scheduling/exceptions')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> putSchedulingExceptions(Map<String, dynamic> payload) => _wrap(() async => (await _dio.put<Map<String, dynamic>>('/pro/scheduling/exceptions', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getSchedulingPolicy() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/pro/scheduling/policy')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> putSchedulingPolicy(Map<String, dynamic> payload) => _wrap(() async => (await _dio.put<Map<String, dynamic>>('/pro/scheduling/policy', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getCandidateSlots(Map<String, dynamic> params) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/pro/scheduling/slots', queryParameters: params)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getPublicAvailability(String proUserId, Map<String, dynamic> params) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/pro/$proUserId/availability', queryParameters: params)).data ?? {});

  Future<ProApiResult<Map<String, dynamic>>> getBookingRequest(String requestId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/booking-requests/$requestId')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> acceptBookingRequest(String requestId) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/booking-requests/$requestId/accept')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> declineBookingRequest(String requestId, {String? reason}) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/booking-requests/$requestId/decline', data: reason == null ? {} : {'reason': reason})).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> cancelBookingRequest(String requestId) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/booking-requests/$requestId/cancel')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> confirmSlot(String bookingRequestId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/pro/bookings/$bookingRequestId/confirm-slot', data: payload)).data ?? {});

  Future<ProApiResult<Map<String, dynamic>>> createGig(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/gigs', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getGig(String gigId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/gigs/$gigId')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> cancelGigSlot(String gigId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/gigs/$gigId/cancel-slot', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> requestReschedule(String gigId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/gigs/$gigId/reschedule-request', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getGigConsent(String gigId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/gigs/$gigId/consent')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> putGigConsent(String gigId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.put<Map<String, dynamic>>('/gigs/$gigId/consent', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> listGigMedia(String gigId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/gigs/$gigId/media')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getGigMediaSignedUrl(String gigId, String mediaAssetId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/gigs/$gigId/media/$mediaAssetId/signed-url')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> downloadGigMedia(String gigId, String mediaAssetId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/gigs/$gigId/media/$mediaAssetId/download')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> createGigShareLink(String gigId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/gigs/$gigId/share-links', data: payload)).data ?? {});

  Future<ProApiResult<Map<String, dynamic>>> createProofGalleryForGig(String gigId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/gigs/$gigId/proof-gallery', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getProofGallery(String galleryId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/proof-galleries/$galleryId')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> addProofGalleryItems(String galleryId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/proof-galleries/$galleryId/items', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> publishProofGallery(String galleryId) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/proof-galleries/$galleryId/publish')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> saveGallerySelection(String galleryId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/proof-galleries/$galleryId/selections', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> submitGallerySelection(String galleryId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/proof-galleries/$galleryId/selections/submit', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> createUpsellIntent(String galleryId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/proof-galleries/$galleryId/upsell/create-intent', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getProofGalleryDownloads(String galleryId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/proof-galleries/$galleryId/downloads')).data ?? {});

  Future<ProApiResult<Map<String, dynamic>>> createPhotoUpload(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/media/photos/uploads', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> completePhotoUpload(String mediaAssetId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/media/photos/$mediaAssetId/complete', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getMediaAsset(String mediaAssetId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/media/$mediaAssetId')).data ?? {});

  Future<ProApiResult<Map<String, dynamic>>> listProThreads(Map<String, dynamic> params) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/pro/chat/threads', queryParameters: params)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getProThread(String threadId) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/pro/chat/threads/$threadId')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> sendProMessage(String threadId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/pro/chat/threads/$threadId/messages', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getAIDraft(String threadId, Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/pro/chat/threads/$threadId/ai-draft', data: payload)).data ?? {});

  Future<ProApiResult<Map<String, dynamic>>> getEarningsBalance() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/pro/earnings/balance')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getEarningsLedger(Map<String, dynamic> params) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/pro/earnings/ledger', queryParameters: params)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getPayouts(Map<String, dynamic> params) => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/pro/payouts', queryParameters: params)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> getPayoutAccount() => _wrap(() async => (await _dio.get<Map<String, dynamic>>('/pro/payouts/account')).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> putPayoutAccount(Map<String, dynamic> payload) => _wrap(() async => (await _dio.put<Map<String, dynamic>>('/pro/payouts/account', data: payload)).data ?? {});
  Future<ProApiResult<Map<String, dynamic>>> requestPayout(Map<String, dynamic> payload) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/pro/payouts/request', data: payload)).data ?? {});

  Future<ProApiResult<Map<String, dynamic>>> track(String name, Map<String, dynamic> props) => _wrap(() async => (await _dio.post<Map<String, dynamic>>('/analytics', data: {'name': name, 'props': props})).data ?? {});
}
