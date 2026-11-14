// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter

class _EmailClient implements EmailClient {
  _EmailClient(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<HttpResponse<UnsubscribeLinkView>>
  checkUnsubscribeLinkV1EmailUnsubscribeGet({
    required String u,
    required String t,
    required String k,
    required String s,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{
      r'u': u,
      r't': t,
      r'k': k,
      r's': s,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<UnsubscribeLinkView>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/email/unsubscribe',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late UnsubscribeLinkView _value;
    try {
      _value = UnsubscribeLinkView.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<UnsubscribedView>>
  unsubscribeFromLinkV1EmailUnsubscribePost({
    required String u,
    required String t,
    required String k,
    required String s,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{
      r'u': u,
      r't': t,
      r'k': k,
      r's': s,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<UnsubscribedView>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/email/unsubscribe',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late UnsubscribedView _value;
    try {
      _value = UnsubscribedView.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
