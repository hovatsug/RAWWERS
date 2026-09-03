library client_launch_client;

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import '../models/models.dart';
part 'client_launch_client.g.dart';

@RestApi()
abstract class ClientLaunchClient {
  factory ClientLaunchClient(
    Dio dio, {
    ParseErrorLogger? errorLogger,
    String? baseUrl,
  }) = _ClientLaunchClient;

  @GET("/v1/client/access")
  Future<HttpResponse<ClientAccessResponse>> getClientAccessV1ClientAccessGet({
    @Query("country") required String country,
    @Query("city") required String city,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['client_launch'],
      'summary': 'Get Client Access',
      'operationId': 'get_client_access_v1_client_access_get',
      'parameters': [
        {
          'name': 'country',
          'in': 'query',
          'required': true,
          'schema': {'type': 'string', 'title': 'Country'},
        },
        {
          'name': 'city',
          'in': 'query',
          'required': true,
          'schema': {'type': 'string', 'title': 'City'},
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
              'schema': {'\$ref': '#/components/schemas/ClientAccessResponse'},
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
  @POST("/v1/client/waitlist")
  Future<HttpResponse<ClientWaitlistCreateResponse>>
  createWaitlistEntryV1ClientWaitlistPost({
    @Body() required ClientWaitlistCreateRequest requestBody,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['client_launch'],
      'summary': 'Create Waitlist Entry',
      'operationId': 'create_waitlist_entry_v1_client_waitlist_post',
      'requestBody': {
        'content': {
          'application/json': {
            'schema': {
              '\$ref': '#/components/schemas/ClientWaitlistCreateRequest',
            },
          },
        },
        'required': true,
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {
                '\$ref': '#/components/schemas/ClientWaitlistCreateResponse',
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
  @GET("/v1/client/discover")
  Future<HttpResponse<ClientDiscoverResponse>>
  clientDiscoverV1ClientDiscoverGet({
    @Query("country") required String country,
    @Query("city") required String city,
    @Query("niche_slug") required String? nicheSlug,
    @Query("q") required String? q,
    @Query("min_price") required double? minPrice,
    @Query("max_price") required double? maxPrice,
    @Query("sort") String sort = 'rank',
    @Query("limit") int limit = 20,
    @Query("offset") int offset = 0,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['client_launch'],
      'summary': 'Client Discover',
      'operationId': 'client_discover_v1_client_discover_get',
      'parameters': [
        {
          'name': 'country',
          'in': 'query',
          'required': true,
          'schema': {'type': 'string', 'title': 'Country'},
        },
        {
          'name': 'city',
          'in': 'query',
          'required': true,
          'schema': {'type': 'string', 'title': 'City'},
        },
        {
          'name': 'niche_slug',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'Niche Slug',
          },
        },
        {
          'name': 'q',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'Q',
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
          'name': 'limit',
          'in': 'query',
          'required': false,
          'schema': {
            'type': 'integer',
            'maximum': 40,
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
              'schema': {
                '\$ref': '#/components/schemas/ClientDiscoverResponse',
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
  @POST("/v1/client/match")
  Future<HttpResponse<ClientMatchResponse>> clientMatchV1ClientMatchPost({
    @Body() required ClientMatchCreateRequest requestBody,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['client_launch'],
      'summary': 'Client Match',
      'operationId': 'client_match_v1_client_match_post',
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
            'schema': {
              '\$ref': '#/components/schemas/ClientMatchCreateRequest',
            },
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/ClientMatchResponse'},
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
  @GET("/v1/client/pros/{pro_user_id}")
  Future<HttpResponse<ClientProProfileResponse>>
  clientProProfileV1ClientProsProUserIdGet({
    @Path("pro_user_id") required String proUserId,
    @Query("country") required String country,
    @Query("city") required String city,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['client_launch'],
      'summary': 'Client Pro Profile',
      'operationId': 'client_pro_profile_v1_client_pros__pro_user_id__get',
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
          'name': 'country',
          'in': 'query',
          'required': true,
          'schema': {'type': 'string', 'title': 'Country'},
        },
        {
          'name': 'city',
          'in': 'query',
          'required': true,
          'schema': {'type': 'string', 'title': 'City'},
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
                '\$ref': '#/components/schemas/ClientProProfileResponse',
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
  @POST("/v1/client/bookings/request")
  Future<HttpResponse<ClientBookingRequestCreateResponse>>
  clientBookingRequestV1ClientBookingsRequestPost({
    @Body() required ClientBookingRequestCreateRequest requestBody,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['client_launch'],
      'summary': 'Client Booking Request',
      'operationId': 'client_booking_request_v1_client_bookings_request_post',
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
            'schema': {
              '\$ref': '#/components/schemas/ClientBookingRequestCreateRequest',
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
                '\$ref':
                    '#/components/schemas/ClientBookingRequestCreateResponse',
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
  @GET("/v1/client/bookings/{booking_id}")
  Future<HttpResponse<ClientBookingStatusResponse>>
  clientBookingStatusV1ClientBookingsBookingIdGet({
    @Path("booking_id") required String bookingId,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['client_launch'],
      'summary': 'Client Booking Status',
      'operationId':
          'client_booking_status_v1_client_bookings__booking_id__get',
      'parameters': [
        {
          'name': 'booking_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Booking Id'},
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
                '\$ref': '#/components/schemas/ClientBookingStatusResponse',
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
  @POST("/v1/client/bookings/{booking_id}/pay")
  Future<HttpResponse<ClientBookingPayResponse>>
  clientBookingPayV1ClientBookingsBookingIdPayPost({
    @Body() required ClientBookingPayRequest requestBody,
    @Path("booking_id") required String bookingId,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['client_launch'],
      'summary': 'Client Booking Pay',
      'operationId':
          'client_booking_pay_v1_client_bookings__booking_id__pay_post',
      'parameters': [
        {
          'name': 'booking_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Booking Id'},
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
            'schema': {'\$ref': '#/components/schemas/ClientBookingPayRequest'},
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {
                '\$ref': '#/components/schemas/ClientBookingPayResponse',
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
  @GET("/v1/me/client-preference")
  Future<HttpResponse<ClientPreferenceView>>
  getClientPreferenceV1MeClientPreferenceGet({
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['client_launch'],
      'summary': 'Get Client Preference',
      'operationId': 'get_client_preference_v1_me_client_preference_get',
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
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/ClientPreferenceView'},
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
  @PUT("/v1/me/client-preference")
  Future<HttpResponse<ClientPreferenceView>>
  putClientPreferenceV1MeClientPreferencePut({
    @Body() required ClientPreferenceUpdateRequest requestBody,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['client_launch'],
      'summary': 'Put Client Preference',
      'operationId': 'put_client_preference_v1_me_client_preference_put',
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
            'schema': {
              '\$ref': '#/components/schemas/ClientPreferenceUpdateRequest',
            },
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/ClientPreferenceView'},
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
