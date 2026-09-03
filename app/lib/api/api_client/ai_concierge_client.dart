library ai_concierge_client;

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import '../models/models.dart';
part 'ai_concierge_client.g.dart';

@RestApi()
abstract class AIConciergeClient {
  factory AIConciergeClient(
    Dio dio, {
    ParseErrorLogger? errorLogger,
    String? baseUrl,
  }) = _AIConciergeClient;

  @POST("/v1/chat/threads")
  Future<HttpResponse<ChatThreadSummary>> createChatThreadV1V1ChatThreadsPost({
    @Body() required ChatThreadCreateRequest requestBody,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['ai_concierge'],
      'summary': 'Create Chat Thread V1',
      'operationId': 'create_chat_thread_v1_v1_chat_threads_post',
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
            'schema': {'\$ref': '#/components/schemas/ChatThreadCreateRequest'},
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/ChatThreadSummary'},
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
  @GET("/v1/chat/threads/{thread_id}")
  Future<HttpResponse<ChatThreadDetailResponse>>
  getChatThreadV1V1ChatThreadsThreadIdGet({
    @Path("thread_id") required String threadId,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['ai_concierge'],
      'summary': 'Get Chat Thread V1',
      'operationId': 'get_chat_thread_v1_v1_chat_threads__thread_id__get',
      'parameters': [
        {
          'name': 'thread_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Thread Id'},
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
                '\$ref': '#/components/schemas/ChatThreadDetailResponse',
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
  @POST("/v1/chat/threads/{thread_id}/messages")
  Future<HttpResponse<ChatMessageV1View>>
  postChatMessageV1V1ChatThreadsThreadIdMessagesPost({
    @Body() required ChatMessageCreateV1Request requestBody,
    @Path("thread_id") required String threadId,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['ai_concierge'],
      'summary': 'Post Chat Message V1',
      'operationId':
          'post_chat_message_v1_v1_chat_threads__thread_id__messages_post',
      'parameters': [
        {
          'name': 'thread_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Thread Id'},
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
              '\$ref': '#/components/schemas/ChatMessageCreateV1Request',
            },
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/ChatMessageV1View'},
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
  @POST("/v1/chat/threads/{thread_id}/create-booking")
  Future<HttpResponse<CreateBookingFromChatResponse>>
  createBookingFromChatV1ChatThreadsThreadIdCreateBookingPost({
    @Body() required CreateBookingFromChatRequest requestBody,
    @Path("thread_id") required String threadId,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['ai_concierge'],
      'summary': 'Create Booking From Chat',
      'operationId':
          'create_booking_from_chat_v1_chat_threads__thread_id__create_booking_post',
      'parameters': [
        {
          'name': 'thread_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Thread Id'},
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
              '\$ref': '#/components/schemas/CreateBookingFromChatRequest',
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
                '\$ref': '#/components/schemas/CreateBookingFromChatResponse',
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
  @GET("/v1/pro/chat/threads")
  Future<HttpResponse<List<ChatThreadSummary>>>
  listProThreadsV1ProChatThreadsGet({
    @Query("status") required ChatThreadStatus? status,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['ai_concierge'],
      'summary': 'List Pro Threads',
      'operationId': 'list_pro_threads_v1_pro_chat_threads_get',
      'parameters': [
        {
          'name': 'status',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'\$ref': '#/components/schemas/ChatThreadStatus'},
              {'type': 'null'},
            ],
            'title': 'Status',
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
                'type': 'array',
                'items': {'\$ref': '#/components/schemas/ChatThreadSummary'},
                'title': 'Response List Pro Threads V1 Pro Chat Threads Get',
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
  @GET("/v1/pro/chat/threads/{thread_id}")
  Future<HttpResponse<ChatThreadDetailResponse>>
  getProThreadV1ProChatThreadsThreadIdGet({
    @Path("thread_id") required String threadId,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['ai_concierge'],
      'summary': 'Get Pro Thread',
      'operationId': 'get_pro_thread_v1_pro_chat_threads__thread_id__get',
      'parameters': [
        {
          'name': 'thread_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Thread Id'},
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
                '\$ref': '#/components/schemas/ChatThreadDetailResponse',
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
  @POST("/v1/pro/chat/threads/{thread_id}/messages")
  Future<HttpResponse<ChatMessageV1View>>
  postProMessageV1ProChatThreadsThreadIdMessagesPost({
    @Body() required ChatMessageCreateV1Request requestBody,
    @Path("thread_id") required String threadId,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['ai_concierge'],
      'summary': 'Post Pro Message',
      'operationId':
          'post_pro_message_v1_pro_chat_threads__thread_id__messages_post',
      'parameters': [
        {
          'name': 'thread_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Thread Id'},
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
              '\$ref': '#/components/schemas/ChatMessageCreateV1Request',
            },
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/ChatMessageV1View'},
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
  @POST("/v1/pro/chat/threads/{thread_id}/ai-draft")
  Future<HttpResponse<AIDraftResponse>>
  aIDraftForProV1ProChatThreadsThreadIdAIDraftPost({
    @Body() required AIDraftRequest requestBody,
    @Path("thread_id") required String threadId,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['ai_concierge'],
      'summary': 'Ai Draft For Pro',
      'operationId':
          'ai_draft_for_pro_v1_pro_chat_threads__thread_id__ai_draft_post',
      'parameters': [
        {
          'name': 'thread_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Thread Id'},
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
            'schema': {'\$ref': '#/components/schemas/AIDraftRequest'},
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/AIDraftResponse'},
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
