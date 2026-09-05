library base_api_client;

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'exports.dart';

/// {
///     "title": "RAWWERS API",
///     "version": "0.1.0"
/// }
class BaseApiClient {
  BaseApiClient(this.dio, {this.baseUrl, this.errorLogger});

  final String? baseUrl;

  final Dio dio;

  final ParseErrorLogger? errorLogger;

  AuthClient get authClient {
    return AuthClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  AIConciergeClient get aIConciergeClient {
    return AIConciergeClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  ChatsClient get chatsClient {
    return ChatsClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  ClientLaunchClient get clientLaunchClient {
    return ClientLaunchClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  CommunicationsClient get communicationsClient {
    return CommunicationsClient(
      dio,
      baseUrl: baseUrl,
      errorLogger: errorLogger,
    );
  }

  DiscoveryClient get discoveryClient {
    return DiscoveryClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  DisputesClient get disputesClient {
    return DisputesClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  GamificationClient get gamificationClient {
    return GamificationClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  GigsClient get gigsClient {
    return GigsClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  MediaClient get mediaClient {
    return MediaClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  MediaRightsClient get mediaRightsClient {
    return MediaRightsClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  NotificationsClient get notificationsClient {
    return NotificationsClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  ProOnboardingClient get proOnboardingClient {
    return ProOnboardingClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  ProofGalleriesClient get proofGalleriesClient {
    return ProofGalleriesClient(
      dio,
      baseUrl: baseUrl,
      errorLogger: errorLogger,
    );
  }

  RepairsClient get repairsClient {
    return RepairsClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  ReviewsClient get reviewsClient {
    return ReviewsClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  SearchClient get searchClient {
    return SearchClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  SchedulingClient get schedulingClient {
    return SchedulingClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  WebhooksClient get webhooksClient {
    return WebhooksClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  PayoutsClient get payoutsClient {
    return PayoutsClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  I18nClient get i18nClient {
    return I18nClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }

  DefaultClient get defaultClient {
    return DefaultClient(dio, baseUrl: baseUrl, errorLogger: errorLogger);
  }
}
