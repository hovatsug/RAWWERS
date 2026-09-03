library discovery_client;

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import '../models/models.dart';
part 'discovery_client.g.dart';

@RestApi()
abstract class DiscoveryClient {
  factory DiscoveryClient(
    Dio dio, {
    ParseErrorLogger? errorLogger,
    String? baseUrl,
  }) = _DiscoveryClient;

  @GET("/v1/discover/pros")
  Future<HttpResponse<DiscoverProsResponse>> discoverProsV1DiscoverProsGet({
    @Query("city") required String? city,
    @Query("country") required String? country,
    @Query("styles") required String? styles,
    @Query("min_price") required double? minPrice,
    @Query("max_price") required double? maxPrice,
    @Query("sort") String sort = 'rank',
    @Query("niche") required String? niche,
    @Query("limit") int limit = 20,
    @Query("offset") int offset = 0,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['discovery'],
      'summary': 'Discover Pros',
      'operationId': 'discover_pros_v1_discover_pros_get',
      'parameters': [
        {
          'name': 'city',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'City',
          },
        },
        {
          'name': 'country',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'Country',
          },
        },
        {
          'name': 'styles',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'Styles',
          },
        },
        {
          'name': 'min_price',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'number'},
              {'type': 'null'},
            ],
            'title': 'Min Price',
          },
        },
        {
          'name': 'max_price',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'number'},
              {'type': 'null'},
            ],
            'title': 'Max Price',
          },
        },
        {
          'name': 'sort',
          'in': 'query',
          'required': false,
          'schema': {'type': 'string', 'default': 'rank', 'title': 'Sort'},
        },
        {
          'name': 'niche',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'Niche',
          },
        },
        {
          'name': 'limit',
          'in': 'query',
          'required': false,
          'schema': {
            'type': 'integer',
            'maximum': 50,
            'minimum': 1,
            'default': 20,
            'title': 'Limit',
          },
        },
        {
          'name': 'offset',
          'in': 'query',
          'required': false,
          'schema': {
            'type': 'integer',
            'minimum': 0,
            'default': 0,
            'title': 'Offset',
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
              'schema': {'\$ref': '#/components/schemas/DiscoverProsResponse'},
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
  @GET("/v1/pros/{pro_user_id}/public")
  Future<HttpResponse<ProPublicProfileResponse>>
  getPublicProProfileV1ProsProUserIdPublicGet({
    @Path("pro_user_id") required String proUserId,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['discovery'],
      'summary': 'Get Public Pro Profile',
      'operationId': 'get_public_pro_profile_v1_pros__pro_user_id__public_get',
      'parameters': [
        {
          'name': 'pro_user_id',
          'in': 'path',
          'required': true,
          'schema': {
            'type': 'string',
            'format': 'uuid',
            'title': 'Pro User Id',
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
              'schema': {
                '\$ref': '#/components/schemas/ProPublicProfileResponse',
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
  @GET("/v1/pros/{pro_user_id}/niches/{niche_id}/pricing-preview")
  Future<HttpResponse<NichePricingPreviewResponse>>
  getNichePricingPreviewV1ProsProUserIdNichesNicheIdPricingPreviewGet({
    @Path("pro_user_id") required String proUserId,
    @Path("niche_id") required String nicheId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['discovery'],
      'summary': 'Get Niche Pricing Preview',
      'operationId':
          'get_niche_pricing_preview_v1_pros__pro_user_id__niches__niche_id__pricing_preview_get',
      'parameters': [
        {
          'name': 'pro_user_id',
          'in': 'path',
          'required': true,
          'schema': {
            'type': 'string',
            'format': 'uuid',
            'title': 'Pro User Id',
          },
        },
        {
          'name': 'niche_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Niche Id'},
        },
      ],
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {
                '\$ref': '#/components/schemas/NichePricingPreviewResponse',
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
  @POST("/v1/discover/match")
  Future<HttpResponse<MatchResponse>> discoverMatchV1DiscoverMatchPost({
    @Body() required MatchRequest requestBody,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['discovery'],
      'summary': 'Discover Match',
      'operationId': 'discover_match_v1_discover_match_post',
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
            'schema': {'\$ref': '#/components/schemas/MatchRequest'},
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/MatchResponse'},
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
  @POST("/v1/analytics")
  Future<HttpResponse<Map<String, dynamic>>>
  createAnalyticsEventV1AnalyticsPost({
    @Body() required AnalyticsCreateRequest requestBody,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['discovery'],
      'summary': 'Create Analytics Event',
      'operationId': 'create_analytics_event_v1_analytics_post',
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
            'schema': {'\$ref': '#/components/schemas/AnalyticsCreateRequest'},
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {
                'type': 'object',
                'additionalProperties': true,
                'title': 'Response Create Analytics Event V1 Analytics Post',
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
}
