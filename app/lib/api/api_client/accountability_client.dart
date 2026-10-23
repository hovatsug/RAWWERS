library accountability_client;

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import '../models/models.dart';
part 'accountability_client.g.dart';

@RestApi()
abstract class AccountabilityClient {
  factory AccountabilityClient(
    Dio dio, {
    ParseErrorLogger? errorLogger,
    String? baseUrl,
  }) = _AccountabilityClient;

  @GET("/v1/pro/findings")
  Future<HttpResponse<MyFindingsResponse>> myFindingsV1ProFindingsGet({
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['accountability'],
      'summary': 'My Findings',
      'operationId': 'my_findings_v1_pro_findings_get',
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
              'schema': {'\$ref': '#/components/schemas/MyFindingsResponse'},
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
  @POST("/v1/pro/findings/{finding_id}/seen")
  Future<HttpResponse<FindingView>>
  markFindingSeenV1ProFindingsFindingIdSeenPost({
    @Path("finding_id") required String findingId,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['accountability'],
      'summary': 'Mark Finding Seen',
      'operationId': 'mark_finding_seen_v1_pro_findings__finding_id__seen_post',
      'parameters': [
        {
          'name': 'finding_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Finding Id'},
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
              'schema': {'\$ref': '#/components/schemas/FindingView'},
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
  @POST("/v1/pro/findings/{finding_id}/response")
  Future<HttpResponse<FindingView>>
  respondToFindingV1ProFindingsFindingIdResponsePost({
    @Body() required ResponseIn requestBody,
    @Path("finding_id") required String findingId,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['accountability'],
      'summary': 'Respond To Finding',
      'operationId':
          'respond_to_finding_v1_pro_findings__finding_id__response_post',
      'parameters': [
        {
          'name': 'finding_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Finding Id'},
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
            'schema': {'\$ref': '#/components/schemas/ResponseIn'},
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/FindingView'},
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
