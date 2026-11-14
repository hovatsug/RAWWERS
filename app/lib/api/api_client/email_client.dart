library email_client;

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import '../models/models.dart';
part 'email_client.g.dart';

@RestApi()
abstract class EmailClient {
  factory EmailClient(
    Dio dio, {
    ParseErrorLogger? errorLogger,
    String? baseUrl,
  }) = _EmailClient;

  @GET("/v1/email/unsubscribe")
  Future<HttpResponse<UnsubscribeLinkView>>
  checkUnsubscribeLinkV1EmailUnsubscribeGet({
    @Query("u") required String u,
    @Query("t") required String t,
    @Query("k") required String k,
    @Query("s") required String s,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['email'],
      'summary': 'Check Unsubscribe Link',
      'description':
          'What the link would stop. Changes nothing: mail scanners open links.',
      'operationId': 'check_unsubscribe_link_v1_email_unsubscribe_get',
      'parameters': [
        {
          'name': 'u',
          'in': 'query',
          'required': true,
          'schema': {'type': 'string', 'title': 'U'},
        },
        {
          'name': 't',
          'in': 'query',
          'required': true,
          'schema': {'type': 'string', 'maxLength': 64, 'title': 'T'},
        },
        {
          'name': 'k',
          'in': 'query',
          'required': true,
          'schema': {'type': 'string', 'maxLength': 64, 'title': 'K'},
        },
        {
          'name': 's',
          'in': 'query',
          'required': true,
          'schema': {'type': 'string', 'maxLength': 128, 'title': 'S'},
        },
      ],
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/UnsubscribeLinkView'},
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
  @POST("/v1/email/unsubscribe")
  Future<HttpResponse<UnsubscribedView>>
  unsubscribeFromLinkV1EmailUnsubscribePost({
    @Query("u") required String u,
    @Query("t") required String t,
    @Query("k") required String k,
    @Query("s") required String s,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['email'],
      'summary': 'Unsubscribe From Link',
      'description':
          'Stop that email. The link\'s parameters are in the query, so a mail\nclient\'s one-click POST (body "List-Unsubscribe=One-Click") works as it is.',
      'operationId': 'unsubscribe_from_link_v1_email_unsubscribe_post',
      'parameters': [
        {
          'name': 'u',
          'in': 'query',
          'required': true,
          'schema': {'type': 'string', 'title': 'U'},
        },
        {
          'name': 't',
          'in': 'query',
          'required': true,
          'schema': {'type': 'string', 'maxLength': 64, 'title': 'T'},
        },
        {
          'name': 'k',
          'in': 'query',
          'required': true,
          'schema': {'type': 'string', 'maxLength': 64, 'title': 'K'},
        },
        {
          'name': 's',
          'in': 'query',
          'required': true,
          'schema': {'type': 'string', 'maxLength': 128, 'title': 'S'},
        },
      ],
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/UnsubscribedView'},
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
