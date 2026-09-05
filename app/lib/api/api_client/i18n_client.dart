library i18n_client;

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import '../models/models.dart';
part 'i18n_client.g.dart';

@RestApi()
abstract class I18nClient {
  factory I18nClient(
    Dio dio, {
    ParseErrorLogger? errorLogger,
    String? baseUrl,
  }) = _I18nClient;

  @GET("/v1/i18n/bundles")
  Future<HttpResponse<I18nBundleFetchResponse>> getI18nBundleV1I18nBundlesGet({
    @Query("locale") required String? locale,
    @Query("namespace") String namespace = 'core',
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['i18n'],
      'summary': 'Get I18N Bundle',
      'operationId': 'get_i18n_bundle_v1_i18n_bundles_get',
      'parameters': [
        {
          'name': 'locale',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'Locale',
          },
        },
        {
          'name': 'namespace',
          'in': 'query',
          'required': false,
          'schema': {'type': 'string', 'default': 'core', 'title': 'Namespace'},
        },
      ],
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {
                '\$ref': '#/components/schemas/I18nBundleFetchResponse',
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
