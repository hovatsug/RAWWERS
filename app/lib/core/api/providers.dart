import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rawwers/api/api_client/ai_concierge_client.dart';
import 'package:rawwers/api/api_client/auth_client.dart';
import 'package:rawwers/api/api_client/client_launch_client.dart';
import 'package:rawwers/api/api_client/gigs_client.dart';
import 'package:rawwers/api/api_client/media_client.dart';
import 'package:rawwers/api/api_client/notifications_client.dart';
import 'package:rawwers/api/api_client/repairs_client.dart';
import 'package:rawwers/api/api_client/proof_galleries_client.dart';
import 'package:rawwers/api/api_client/scheduling_client.dart';
import 'package:rawwers/core/upload/photo_upload_service.dart';
import 'package:rawwers/api/api_client/payouts_client.dart';
import 'package:rawwers/api/api_client/pro_onboarding_client.dart';
import 'package:rawwers/core/api/dio_client.dart';
import 'package:rawwers/core/api/session.dart';
import 'package:rawwers/core/env.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
SessionStorage sessionStorage(Ref ref) => SecureSessionStorage();

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  return createDio(baseUrl: Env.apiBaseUrl, sessionStorage: ref.watch(sessionStorageProvider));
}

@riverpod
AuthClient authClient(Ref ref) => AuthClient(ref.watch(dioProvider));

@riverpod
ProOnboardingClient proOnboardingClient(Ref ref) => ProOnboardingClient(ref.watch(dioProvider));

@riverpod
GigsClient gigsClient(Ref ref) => GigsClient(ref.watch(dioProvider));

@riverpod
PayoutsClient payoutsClient(Ref ref) => PayoutsClient(ref.watch(dioProvider));

@riverpod
ClientLaunchClient clientLaunchClient(Ref ref) => ClientLaunchClient(ref.watch(dioProvider));

@riverpod
AIConciergeClient aiConciergeClient(Ref ref) => AIConciergeClient(ref.watch(dioProvider));

@riverpod
NotificationsClient notificationsClient(Ref ref) => NotificationsClient(ref.watch(dioProvider));

@riverpod
SchedulingClient schedulingClient(Ref ref) => SchedulingClient(ref.watch(dioProvider));

/// Gear lives under the repairs tag because the repairs marketplace
/// consumes it; to a photographer it is just the kit they own.
@riverpod
RepairsClient repairsClient(Ref ref) => RepairsClient(ref.watch(dioProvider));


@riverpod
MediaClient mediaClient(Ref ref) => MediaClient(ref.watch(dioProvider));

/// Uploads photos through the presigned-PUT flow.
///
/// The storage Dio is deliberately bare - no baseUrl, no auth or refresh
/// interceptors. A presigned URL authenticates itself through its query
/// string, and attaching our Authorization header to a third-party host
/// would leak the session token to R2.
@riverpod
PhotoUploadService photoUploadService(Ref ref) => PhotoUploadService(
      mediaClient: ref.watch(mediaClientProvider),
      storageDio: Dio(),
    );

@riverpod
ProofGalleriesClient proofGalleriesClient(Ref ref) => ProofGalleriesClient(ref.watch(dioProvider));
