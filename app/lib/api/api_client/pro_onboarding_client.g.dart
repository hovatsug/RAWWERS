// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_onboarding_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter

class _ProOnboardingClient implements ProOnboardingClient {
  _ProOnboardingClient(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<HttpResponse<ProOnboardingStatusResponse>>
  getMyOnboardingV1ProOnboardingGet({
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Get My Onboarding',
      'operationId': 'get_my_onboarding_v1_pro_onboarding_get',
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
              'schema': {
                '\$ref': '#/components/schemas/ProOnboardingStatusResponse',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<ProOnboardingStatusResponse>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/onboarding',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProOnboardingStatusResponse _value;
    try {
      _value = ProOnboardingStatusResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ProOnboardingStatusResponse>>
  startMyOnboardingV1ProOnboardingStartPost({
    required ProOnboardingStartRequest requestBody,
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Start My Onboarding',
      'operationId': 'start_my_onboarding_v1_pro_onboarding_start_post',
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
              '\$ref': '#/components/schemas/ProOnboardingStartRequest',
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
                '\$ref': '#/components/schemas/ProOnboardingStatusResponse',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(requestBody.toJson());
    final _options = _setStreamType<HttpResponse<ProOnboardingStatusResponse>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/onboarding/start',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProOnboardingStatusResponse _value;
    try {
      _value = ProOnboardingStatusResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ProOnboardingStatusResponse>>
  completeProfileOnboardingStageV1ProOnboardingCompleteProfilePost({
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Complete Profile Onboarding Stage',
      'operationId':
          'complete_profile_onboarding_stage_v1_pro_onboarding_complete_profile_post',
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
              'schema': {
                '\$ref': '#/components/schemas/ProOnboardingStatusResponse',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<ProOnboardingStatusResponse>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/onboarding/complete-profile',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProOnboardingStatusResponse _value;
    try {
      _value = ProOnboardingStatusResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ProOnboardingStatusResponse>>
  completePortfolioOnboardingStageV1ProOnboardingUploadPortfolioPost({
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Complete Portfolio Onboarding Stage',
      'operationId':
          'complete_portfolio_onboarding_stage_v1_pro_onboarding_upload_portfolio_post',
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
              'schema': {
                '\$ref': '#/components/schemas/ProOnboardingStatusResponse',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<ProOnboardingStatusResponse>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/onboarding/upload-portfolio',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProOnboardingStatusResponse _value;
    try {
      _value = ProOnboardingStatusResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ProOnboardingStatusResponse>>
  completePackagesOnboardingStageV1ProOnboardingConfigurePackagesPost({
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Complete Packages Onboarding Stage',
      'operationId':
          'complete_packages_onboarding_stage_v1_pro_onboarding_configure_packages_post',
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
              'schema': {
                '\$ref': '#/components/schemas/ProOnboardingStatusResponse',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<ProOnboardingStatusResponse>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/onboarding/configure-packages',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProOnboardingStatusResponse _value;
    try {
      _value = ProOnboardingStatusResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ProOnboardingStatusResponse>>
  completeNichesOnboardingStageV1ProOnboardingSelectNichesPost({
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Complete Niches Onboarding Stage',
      'operationId':
          'complete_niches_onboarding_stage_v1_pro_onboarding_select_niches_post',
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
              'schema': {
                '\$ref': '#/components/schemas/ProOnboardingStatusResponse',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<ProOnboardingStatusResponse>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/onboarding/select-niches',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProOnboardingStatusResponse _value;
    try {
      _value = ProOnboardingStatusResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ProOnboardingStatusResponse>>
  submitKycOnboardingStageV1ProOnboardingSubmitKycPost({
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Submit Kyc Onboarding Stage',
      'operationId':
          'submit_kyc_onboarding_stage_v1_pro_onboarding_submit_kyc_post',
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
              'schema': {
                '\$ref': '#/components/schemas/ProOnboardingStatusResponse',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<ProOnboardingStatusResponse>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/onboarding/submit-kyc',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProOnboardingStatusResponse _value;
    try {
      _value = ProOnboardingStatusResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ProOnboardingChecksResponse>>
  getOnboardingChecksV1ProOnboardingChecksGet({
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Get Onboarding Checks',
      'operationId': 'get_onboarding_checks_v1_pro_onboarding_checks_get',
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
              'schema': {
                '\$ref': '#/components/schemas/ProOnboardingChecksResponse',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<ProOnboardingChecksResponse>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/onboarding/checks',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProOnboardingChecksResponse _value;
    try {
      _value = ProOnboardingChecksResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ProProfileView>> getMyProProfileV1ProMeProfileGet({
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Get My Pro Profile',
      'operationId': 'get_my_pro_profile_v1_pro_me_profile_get',
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
              'schema': {'\$ref': '#/components/schemas/ProProfileView'},
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
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<ProProfileView>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/me/profile',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProProfileView _value;
    try {
      _value = ProProfileView.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ProProfileView>> updateMyProProfileV1ProMeProfilePut({
    required ProProfileUpdateRequest requestBody,
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Update My Pro Profile',
      'operationId': 'update_my_pro_profile_v1_pro_me_profile_put',
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
            'schema': {'\$ref': '#/components/schemas/ProProfileUpdateRequest'},
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/ProProfileView'},
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
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(requestBody.toJson());
    final _options = _setStreamType<HttpResponse<ProProfileView>>(
      Options(method: 'PUT', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/me/profile',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProProfileView _value;
    try {
      _value = ProProfileView.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ProActivateResponse>> activateProV1ProMeActivatePost({
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Activate Pro',
      'operationId': 'activate_pro_v1_pro_me_activate_post',
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
              'schema': {'\$ref': '#/components/schemas/ProActivateResponse'},
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
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<ProActivateResponse>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/me/activate',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProActivateResponse _value;
    try {
      _value = ProActivateResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ProPackageView>> createPackageV1ProMePackagesPost({
    required ProPackageCreateRequest requestBody,
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Create Package',
      'operationId': 'create_package_v1_pro_me_packages_post',
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
            'schema': {'\$ref': '#/components/schemas/ProPackageCreateRequest'},
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/ProPackageView'},
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
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(requestBody.toJson());
    final _options = _setStreamType<HttpResponse<ProPackageView>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/me/packages',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProPackageView _value;
    try {
      _value = ProPackageView.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<List<ProPackageView>>>
  listProPackagesV1ProProUserIdPackagesGet({
    required String proUserId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'List Pro Packages',
      'operationId': 'list_pro_packages_v1_pro__pro_user_id__packages_get',
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
      ],
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {
                'type': 'array',
                'items': {'\$ref': '#/components/schemas/ProPackageView'},
                'title':
                    'Response List Pro Packages V1 Pro  Pro User Id  Packages Get',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<List<ProPackageView>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/${proUserId}/packages',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<List<dynamic>>(_options);
    late List<ProPackageView> _value;
    try {
      _value = _result.data!
          .map(
            (dynamic i) => ProPackageView.fromJson(i as Map<String, dynamic>),
          )
          .toList();
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ProPackageView>>
  updatePackageV1ProMePackagesPackageIdPut({
    required ProPackageUpdateRequest requestBody,
    required String packageId,
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Update Package',
      'operationId': 'update_package_v1_pro_me_packages__package_id__put',
      'parameters': [
        {
          'name': 'package_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Package Id'},
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
            'schema': {'\$ref': '#/components/schemas/ProPackageUpdateRequest'},
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/ProPackageView'},
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
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(requestBody.toJson());
    final _options = _setStreamType<HttpResponse<ProPackageView>>(
      Options(method: 'PUT', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/me/packages/${packageId}',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProPackageView _value;
    try {
      _value = ProPackageView.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ProPackageView>>
  disablePackageV1ProMePackagesPackageIdDisablePost({
    required String packageId,
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Disable Package',
      'operationId':
          'disable_package_v1_pro_me_packages__package_id__disable_post',
      'parameters': [
        {
          'name': 'package_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Package Id'},
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
              'schema': {'\$ref': '#/components/schemas/ProPackageView'},
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
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<ProPackageView>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/me/packages/${packageId}/disable',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProPackageView _value;
    try {
      _value = ProPackageView.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>>
  replaceAvailabilityRulesV1ProMeAvailabilityRulesPost({
    required ReplaceAvailabilityRulesRequest requestBody,
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Replace Availability Rules',
      'operationId':
          'replace_availability_rules_v1_pro_me_availability_rules_post',
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
              '\$ref': '#/components/schemas/ReplaceAvailabilityRulesRequest',
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
                'type': 'object',
                'additionalProperties': true,
                'title':
                    'Response Replace Availability Rules V1 Pro Me Availability Rules Post',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(requestBody.toJson());
    final _options = _setStreamType<HttpResponse<Map<String, dynamic>>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/me/availability/rules',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late Map<String, dynamic> _value;
    try {
      _value = _result.data!;
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<BlackoutView>>
  createBlackoutV1ProMeAvailabilityBlackoutsPost({
    required BlackoutCreateRequest requestBody,
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Create Blackout',
      'operationId': 'create_blackout_v1_pro_me_availability_blackouts_post',
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
            'schema': {'\$ref': '#/components/schemas/BlackoutCreateRequest'},
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/BlackoutView'},
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
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(requestBody.toJson());
    final _options = _setStreamType<HttpResponse<BlackoutView>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/me/availability/blackouts',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BlackoutView _value;
    try {
      _value = BlackoutView.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<PublicAvailabilityResponse>>
  getPublicAvailabilityV1ProProUserIdAvailabilityGet({
    required String proUserId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Get Public Availability',
      'operationId':
          'get_public_availability_v1_pro__pro_user_id__availability_get',
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
      ],
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {
                '\$ref': '#/components/schemas/PublicAvailabilityResponse',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<PublicAvailabilityResponse>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/${proUserId}/availability',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PublicAvailabilityResponse _value;
    try {
      _value = PublicAvailabilityResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<List<Map<String, dynamic>>>> listNichesV1NichesGet({
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'List Niches',
      'operationId': 'list_niches_v1_niches_get',
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {
                'items': {
                  'additionalProperties': {'type': 'string'},
                  'type': 'object',
                },
                'type': 'array',
                'title': 'Response List Niches V1 Niches Get',
              },
            },
          },
        },
      },
    },
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<List<Map<String, dynamic>>>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/niches',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<List<dynamic>>(_options);
    late List<Map<String, dynamic>> _value;
    try {
      _value = _result.data!.cast<Map<String, dynamic>>();
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<UpdateMyNichesResponse>>
  getMySelectedNichesV1ProNichesMineGet({
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Get My Selected Niches',
      'operationId': 'get_my_selected_niches_v1_pro_niches_mine_get',
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
              'schema': {
                '\$ref': '#/components/schemas/UpdateMyNichesResponse',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<UpdateMyNichesResponse>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/niches/mine',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late UpdateMyNichesResponse _value;
    try {
      _value = UpdateMyNichesResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<UpdateMyNichesResponse>>
  putMySelectedNichesV1ProNichesMinePut({
    required UpdateMyNichesRequest requestBody,
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Put My Selected Niches',
      'operationId': 'put_my_selected_niches_v1_pro_niches_mine_put',
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
            'schema': {'\$ref': '#/components/schemas/UpdateMyNichesRequest'},
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {
                '\$ref': '#/components/schemas/UpdateMyNichesResponse',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(requestBody.toJson());
    final _options = _setStreamType<HttpResponse<UpdateMyNichesResponse>>(
      Options(method: 'PUT', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/niches/mine',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late UpdateMyNichesResponse _value;
    try {
      _value = UpdateMyNichesResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<UpdateMyNichesResponse>> updateMyNichesV1ProMeNichesPut({
    required UpdateMyNichesRequest requestBody,
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Update My Niches',
      'operationId': 'update_my_niches_v1_pro_me_niches_put',
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
            'schema': {'\$ref': '#/components/schemas/UpdateMyNichesRequest'},
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {
                '\$ref': '#/components/schemas/UpdateMyNichesResponse',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(requestBody.toJson());
    final _options = _setStreamType<HttpResponse<UpdateMyNichesResponse>>(
      Options(method: 'PUT', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/me/niches',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late UpdateMyNichesResponse _value;
    try {
      _value = UpdateMyNichesResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<PortfolioNicheTagsResponse>>
  tagPortfolioMediaNichesV1ProMePortfolioMediaAssetIdNichesPost({
    required PortfolioNicheTagsRequest requestBody,
    required String mediaAssetId,
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Tag Portfolio Media Niches',
      'operationId':
          'tag_portfolio_media_niches_v1_pro_me_portfolio__media_asset_id__niches_post',
      'parameters': [
        {
          'name': 'media_asset_id',
          'in': 'path',
          'required': true,
          'schema': {
            'type': 'string',
            'format': 'uuid',
            'title': 'Media Asset Id',
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
      'requestBody': {
        'required': true,
        'content': {
          'application/json': {
            'schema': {
              '\$ref': '#/components/schemas/PortfolioNicheTagsRequest',
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
                '\$ref': '#/components/schemas/PortfolioNicheTagsResponse',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(requestBody.toJson());
    final _options = _setStreamType<HttpResponse<PortfolioNicheTagsResponse>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/me/portfolio/${mediaAssetId}/niches',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PortfolioNicheTagsResponse _value;
    try {
      _value = PortfolioNicheTagsResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ProNicheSkillListResponse>>
  getProNicheSkillsV1ProsProUserIdSkillsGet({
    required String proUserId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Get Pro Niche Skills',
      'operationId': 'get_pro_niche_skills_v1_pros__pro_user_id__skills_get',
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
      ],
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {
                '\$ref': '#/components/schemas/ProNicheSkillListResponse',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<ProNicheSkillListResponse>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pros/${proUserId}/skills',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProNicheSkillListResponse _value;
    try {
      _value = ProNicheSkillListResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<ProNicheSkillListResponse>>
  getMyNicheSkillsV1ProMeSkillsGet({
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Get My Niche Skills',
      'operationId': 'get_my_niche_skills_v1_pro_me_skills_get',
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
              'schema': {
                '\$ref': '#/components/schemas/ProNicheSkillListResponse',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<ProNicheSkillListResponse>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pro/me/skills',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ProNicheSkillListResponse _value;
    try {
      _value = ProNicheSkillListResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<BookingRequestView>>
  createBookingRequestV1ProsProUserIdBookingRequestsPost({
    required BookingRequestCreateRequest requestBody,
    required String proUserId,
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Create Booking Request',
      'operationId':
          'create_booking_request_v1_pros__pro_user_id__booking_requests_post',
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
      'requestBody': {
        'required': true,
        'content': {
          'application/json': {
            'schema': {
              '\$ref': '#/components/schemas/BookingRequestCreateRequest',
            },
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/BookingRequestView'},
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
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(requestBody.toJson());
    final _options = _setStreamType<HttpResponse<BookingRequestView>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/pros/${proUserId}/booking-requests',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BookingRequestView _value;
    try {
      _value = BookingRequestView.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<BookingRequestListResponse>>
  listBookingRequestsV1BookingRequestsGet({
    required BookingRequestStatus? status,
    required String? cursor,
    int limit = 20,
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'List Booking Requests',
      'description':
          'The authenticated pro\'s own booking requests, newest first.\n\nScoped to `pro_user_id` only. The client side of the same underlying\nrows is served by `GET /v1/client/bookings`, which returns a different\nshape (booking/gig/payment status rolled together) because the two\naudiences are answering different questions: a pro asks "what needs my\ndecision", a client asks "where is my booking up to".',
      'operationId': 'list_booking_requests_v1_booking_requests_get',
      'parameters': [
        {
          'name': 'status',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'\$ref': '#/components/schemas/BookingRequestStatus'},
              {'type': 'null'},
            ],
            'title': 'Status',
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
              'schema': {
                '\$ref': '#/components/schemas/BookingRequestListResponse',
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
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extras ?? <String, dynamic>{});
    final queryParameters = <String, dynamic>{
      r'status': status?.toJson(),
      r'cursor': cursor,
      r'limit': limit,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<BookingRequestListResponse>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/booking-requests',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BookingRequestListResponse _value;
    try {
      _value = BookingRequestListResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<BookingRequestView>>
  getBookingRequestV1BookingRequestsRequestIdGet({
    required String requestId,
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Get Booking Request',
      'operationId': 'get_booking_request_v1_booking_requests__request_id__get',
      'parameters': [
        {
          'name': 'request_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Request Id'},
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
              'schema': {'\$ref': '#/components/schemas/BookingRequestView'},
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
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<BookingRequestView>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/booking-requests/${requestId}',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BookingRequestView _value;
    try {
      _value = BookingRequestView.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<AcceptBookingResponse>>
  acceptBookingRequestV1BookingRequestsRequestIdAcceptPost({
    required String requestId,
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Accept Booking Request',
      'operationId':
          'accept_booking_request_v1_booking_requests__request_id__accept_post',
      'parameters': [
        {
          'name': 'request_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Request Id'},
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
              'schema': {'\$ref': '#/components/schemas/AcceptBookingResponse'},
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
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<AcceptBookingResponse>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/booking-requests/${requestId}/accept',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late AcceptBookingResponse _value;
    try {
      _value = AcceptBookingResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<BookingRequestView>>
  declineBookingRequestV1BookingRequestsRequestIdDeclinePost({
    required BookingDecisionRequest requestBody,
    required String requestId,
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Decline Booking Request',
      'operationId':
          'decline_booking_request_v1_booking_requests__request_id__decline_post',
      'parameters': [
        {
          'name': 'request_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Request Id'},
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
            'schema': {'\$ref': '#/components/schemas/BookingDecisionRequest'},
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/BookingRequestView'},
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
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(requestBody.toJson());
    final _options = _setStreamType<HttpResponse<BookingRequestView>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/booking-requests/${requestId}/decline',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BookingRequestView _value;
    try {
      _value = BookingRequestView.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<BookingRequestView>>
  cancelBookingRequestV1BookingRequestsRequestIdCancelPost({
    required BookingDecisionRequest requestBody,
    required String requestId,
    required String? authorization,
    required String? xMinusUserMinusId,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['pro_onboarding'],
      'summary': 'Cancel Booking Request',
      'operationId':
          'cancel_booking_request_v1_booking_requests__request_id__cancel_post',
      'parameters': [
        {
          'name': 'request_id',
          'in': 'path',
          'required': true,
          'schema': {'type': 'string', 'format': 'uuid', 'title': 'Request Id'},
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
            'schema': {'\$ref': '#/components/schemas/BookingDecisionRequest'},
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/BookingRequestView'},
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
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Authorization': authorization,
      r'X-User-Id': xMinusUserMinusId,
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(requestBody.toJson());
    final _options = _setStreamType<HttpResponse<BookingRequestView>>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/booking-requests/${requestId}/cancel',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late BookingRequestView _value;
    try {
      _value = BookingRequestView.fromJson(_result.data!);
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
