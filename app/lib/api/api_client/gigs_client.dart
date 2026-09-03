library gigs_client;

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import '../models/models.dart';
part 'gigs_client.g.dart';

@RestApi()
abstract class GigsClient {
  factory GigsClient(
    Dio dio, {
    ParseErrorLogger? errorLogger,
    String? baseUrl,
  }) = _GigsClient;

  @POST("/v1/gigs")
  Future<HttpResponse<GigResponse>> createGigV1GigsPost({
    @Body() required CreateGigRequest requestBody,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['gigs'],
      'summary': 'Create Gig',
      'operationId': 'create_gig_v1_gigs_post',
      'parameters': [
        {
          'name': 'Authorization',
          'in': 'header',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'Authorization',
          },
        },
        {
          'name': 'X-User-Id',
          'in': 'header',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'X-User-Id',
          },
        },
      ],
      'requestBody': {
        'required': true,
        'content': {
          'application/json': {
            'schema': {'\$ref': '#/components/schemas/CreateGigRequest'},
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/GigResponse'},
            },
          },
        },
        '422': {
          'description': 'Validation Error',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/HTTPValidationError'},
            },
          },
        },
      },
    },
  });
  @GET("/v1/gigs")
  Future<HttpResponse<GigListResponse>> listGigsV1GigsGet({
    @Query("status") required GigStatus? status,
    @Query("scheduled_from") required DateTime? scheduledFrom,
    @Query("scheduled_to") required DateTime? scheduledTo,
    @Query("cursor") required String? cursor,
    @Query("limit") int limit = 20,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['gigs'],
      'summary': 'List Gigs',
      'description':
          'Gigs the caller is party to, newest first.\n\nScoped by participation rather than by role: a gig has exactly one pro\nand one client, so `pro_user_id == me OR client_user_id == me` returns\neach side its own gigs from one route, mirroring `_ensure_gig_access` on\nthe detail route. No role lookup is needed and a user who is both a pro\nand a client (the common case - every pro registers as a client first)\ncorrectly sees both sides.\n\nThe date range filters on `scheduled_start`, which is the field a\ncalendar screen orders by, and is nullable: an unscheduled gig has no\ndate, so passing either bound excludes gigs that aren\'t scheduled yet.\nOrdering stays on `created_at` regardless, so the keyset cursor remains\ntotal and stable across pages.',
      'operationId': 'list_gigs_v1_gigs_get',
      'parameters': [
        {
          'name': 'status',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'\$ref': '#/components/schemas/GigStatus'},
              {'type': 'null'},
            ],
            'title': 'Status',
          },
        },
        {
          'name': 'scheduled_from',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string', 'format': 'date-time'},
              {'type': 'null'},
            ],
            'title': 'Scheduled From',
          },
        },
        {
          'name': 'scheduled_to',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string', 'format': 'date-time'},
              {'type': 'null'},
            ],
            'title': 'Scheduled To',
          },
        },
        {
          'name': 'cursor',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'Cursor',
          },
        },
        {
          'name': 'limit',
          'in': 'query',
          'required': false,
          'schema': {
            'type': 'integer',
            'maximum': 100,
            'minimum': 1,
            'default': 20,
            'title': 'Limit',
          },
        },
        {
          'name': 'Authorization',
          'in': 'header',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'Authorization',
          },
        },
        {
          'name': 'X-User-Id',
          'in': 'header',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'X-User-Id',
          },
        },
      ],
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/GigListResponse'},
            },
          },
        },
        '422': {
          'description': 'Validation Error',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/HTTPValidationError'},
            },
          },
        },
      },
    },
  });
  @GET("/v1/gigs/{gig_id}")
  Future<HttpResponse<GigDetailResponse>> getGigV1GigsGigIdGet({
    @Path("gig_id") required String gigId,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['gigs'],
      'summary': 'Get Gig',
      'operationId': 'get_gig_v1_gigs__gig_id__get',
      'parameters': [
        {
          'name': 'gig_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Gig Id'},
        },
        {
          'name': 'Authorization',
          'in': 'header',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'Authorization',
          },
        },
        {
          'name': 'X-User-Id',
          'in': 'header',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'X-User-Id',
          },
        },
      ],
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/GigDetailResponse'},
            },
          },
        },
        '422': {
          'description': 'Validation Error',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/HTTPValidationError'},
            },
          },
        },
      },
    },
  });
  @POST("/v1/gigs/{gig_id}/payments/stripe/create-intent")
  Future<HttpResponse<CreatePaymentIntentResponse>>
  createPaymentIntentV1GigsGigIdPaymentsStripeCreateIntentPost({
    @Body() required CreatePaymentIntentRequest requestBody,
    @Path("gig_id") required String gigId,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['gigs'],
      'summary': 'Create Payment Intent',
      'operationId':
          'create_payment_intent_v1_gigs__gig_id__payments_stripe_create_intent_post',
      'parameters': [
        {
          'name': 'gig_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Gig Id'},
        },
        {
          'name': 'Authorization',
          'in': 'header',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'Authorization',
          },
        },
        {
          'name': 'X-User-Id',
          'in': 'header',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'X-User-Id',
          },
        },
      ],
      'requestBody': {
        'required': true,
        'content': {
          'application/json': {
            'schema': {
              '\$ref': '#/components/schemas/CreatePaymentIntentRequest',
            },
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {
                '\$ref': '#/components/schemas/CreatePaymentIntentResponse',
              },
            },
          },
        },
        '422': {
          'description': 'Validation Error',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/HTTPValidationError'},
            },
          },
        },
      },
    },
  });
  @POST("/v1/gigs/{gig_id}/refunds/stripe")
  Future<HttpResponse<CreateRefundResponse>>
  createRefundV1GigsGigIdRefundsStripePost({
    @Body() required CreateRefundRequest requestBody,
    @Path("gig_id") required String gigId,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['gigs'],
      'summary': 'Create Refund',
      'operationId': 'create_refund_v1_gigs__gig_id__refunds_stripe_post',
      'parameters': [
        {
          'name': 'gig_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Gig Id'},
        },
        {
          'name': 'Authorization',
          'in': 'header',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'Authorization',
          },
        },
        {
          'name': 'X-User-Id',
          'in': 'header',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'X-User-Id',
          },
        },
      ],
      'requestBody': {
        'required': true,
        'content': {
          'application/json': {
            'schema': {'\$ref': '#/components/schemas/CreateRefundRequest'},
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/CreateRefundResponse'},
            },
          },
        },
        '422': {
          'description': 'Validation Error',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/HTTPValidationError'},
            },
          },
        },
      },
    },
  });
}
