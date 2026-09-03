library default_client;

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import '../models/models.dart';
part 'default_client.g.dart';

@RestApi()
abstract class DefaultClient {
  factory DefaultClient(
    Dio dio, {
    ParseErrorLogger? errorLogger,
    String? baseUrl,
  }) = _DefaultClient;

  @GET("/healthz")
  Future<HttpResponse<Map<String, dynamic>>> healthcheckHealthzGet({
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'summary': 'Healthcheck',
      'operationId': 'healthcheck_healthz_get',
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {
                'additionalProperties': {'type': 'string'},
                'type': 'object',
                'title': 'Response Healthcheck Healthz Get',
              },
            },
          },
        },
      },
    },
  });
  @GET("/health/ready")
  Future<HttpResponse<Map<String, dynamic>>> healthReadyHealthReadyGet({
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'summary': 'Health Ready',
      'operationId': 'health_ready_health_ready_get',
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {
                'additionalProperties': true,
                'type': 'object',
                'title': 'Response Health Ready Health Ready Get',
              },
            },
          },
        },
      },
    },
  });
  @GET("/health/replica")
  Future<HttpResponse<Map<String, dynamic>>> healthReplicaHealthReplicaGet({
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'summary': 'Health Replica',
      'operationId': 'health_replica_health_replica_get',
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {
                'additionalProperties': true,
                'type': 'object',
                'title': 'Response Health Replica Health Replica Get',
              },
            },
          },
        },
      },
    },
  });
  @GET("/metrics")
  Future<HttpResponse<dynamic>> metricsMetricsGet({
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'summary': 'Metrics',
      'operationId': 'metrics_metrics_get',
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {'schema': {}},
          },
        },
      },
    },
  });
}
