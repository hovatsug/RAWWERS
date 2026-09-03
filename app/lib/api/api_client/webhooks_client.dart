library webhooks_client;

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import '../models/models.dart';
part 'webhooks_client.g.dart';

@RestApi()
abstract class WebhooksClient {
  factory WebhooksClient(
    Dio dio, {
    ParseErrorLogger? errorLogger,
    String? baseUrl,
  }) = _WebhooksClient;

  @POST("/v1/webhooks/mux")
  Future<HttpResponse<WebhookAckResponse>> muxWebhookV1WebhooksMuxPost({
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['webhooks'],
      'summary': 'Mux Webhook',
      'operationId': 'mux_webhook_v1_webhooks_mux_post',
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/WebhookAckResponse'},
            },
          },
        },
      },
    },
  });
  @POST("/v1/webhooks/stripe")
  Future<HttpResponse<WebhookAckResponse>> stripeWebhookV1WebhooksStripePost({
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['webhooks'],
      'summary': 'Stripe Webhook',
      'operationId': 'stripe_webhook_v1_webhooks_stripe_post',
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/WebhookAckResponse'},
            },
          },
        },
      },
    },
  });
}
