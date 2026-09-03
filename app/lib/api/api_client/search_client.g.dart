// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter

class _SearchClient implements SearchClient {
  _SearchClient(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<HttpResponse<SearchResponse>> searchProsV1SearchProsGet({
    required String? q,
    required String? niche,
    required String? city,
    required String? country,
    required double? minPrice,
    required double? maxPrice,
    required SkillTier? tierMin,
    String sort = 'relevance',
    int limit = 20,
    int offset = 0,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['search'],
      'summary': 'Search Pros',
      'operationId': 'search_pros_v1_search_pros_get',
      'parameters': [
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
          'name': 'tier_min',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'\$ref': '#/components/schemas/SkillTier'},
              {'type': 'null'},
            ],
            'title': 'Tier Min',
          },
        },
        {
          'name': 'sort',
          'in': 'query',
          'required': false,
          'schema': {'type': 'string', 'default': 'relevance', 'title': 'Sort'},
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
      ],
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/SearchResponse'},
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
      r'q': q,
      r'niche': niche,
      r'city': city,
      r'country': country,
      r'min_price': minPrice,
      r'max_price': maxPrice,
      r'tier_min': tierMin?.toJson(),
      r'sort': sort,
      r'limit': limit,
      r'offset': offset,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<SearchResponse>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/search/pros',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SearchResponse _value;
    try {
      _value = SearchResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<SearchResponse>> searchCoursesV1SearchCoursesGet({
    required String? q,
    required String? niche,
    required CourseLevel? level,
    bool freeOnly = false,
    bool mandatoryOnly = false,
    String sort = 'relevance',
    int limit = 20,
    int offset = 0,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['search'],
      'summary': 'Search Courses',
      'operationId': 'search_courses_v1_search_courses_get',
      'parameters': [
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
          'name': 'level',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'\$ref': '#/components/schemas/CourseLevel'},
              {'type': 'null'},
            ],
            'title': 'Level',
          },
        },
        {
          'name': 'free_only',
          'in': 'query',
          'required': false,
          'schema': {'type': 'boolean', 'default': false, 'title': 'Free Only'},
        },
        {
          'name': 'mandatory_only',
          'in': 'query',
          'required': false,
          'schema': {
            'type': 'boolean',
            'default': false,
            'title': 'Mandatory Only',
          },
        },
        {
          'name': 'sort',
          'in': 'query',
          'required': false,
          'schema': {'type': 'string', 'default': 'relevance', 'title': 'Sort'},
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
      ],
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/SearchResponse'},
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
      r'q': q,
      r'niche': niche,
      r'level': level?.toJson(),
      r'free_only': freeOnly,
      r'mandatory_only': mandatoryOnly,
      r'sort': sort,
      r'limit': limit,
      r'offset': offset,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<SearchResponse>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/search/courses',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SearchResponse _value;
    try {
      _value = SearchResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<SearchResponse>> searchProductsV1SearchProductsGet({
    required String? q,
    required String? category,
    required String? brand,
    required double? minPrice,
    required double? maxPrice,
    bool inStockOnly = false,
    int limit = 20,
    int offset = 0,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['search'],
      'summary': 'Search Products',
      'operationId': 'search_products_v1_search_products_get',
      'parameters': [
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
          'name': 'category',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'Category',
          },
        },
        {
          'name': 'brand',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'Brand',
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
          'name': 'in_stock_only',
          'in': 'query',
          'required': false,
          'schema': {
            'type': 'boolean',
            'default': false,
            'title': 'In Stock Only',
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
      ],
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/SearchResponse'},
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
      r'q': q,
      r'category': category,
      r'brand': brand,
      r'min_price': minPrice,
      r'max_price': maxPrice,
      r'in_stock_only': inStockOnly,
      r'limit': limit,
      r'offset': offset,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<SearchResponse>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/search/products',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SearchResponse _value;
    try {
      _value = SearchResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    final httpResponse = HttpResponse(_value, _result);
    return httpResponse;
  }

  @override
  Future<HttpResponse<SearchResponse>>
  searchRepairPartnersV1SearchRepairPartnersGet({
    required String? q,
    required String? country,
    required String? city,
    required GearCategory? category,
    required String? brand,
    bool loanerOnly = false,
    int limit = 20,
    int offset = 0,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? extras = const {
      'tags': ['search'],
      'summary': 'Search Repair Partners',
      'operationId': 'search_repair_partners_v1_search_repair_partners_get',
      'parameters': [
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
          'name': 'category',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'\$ref': '#/components/schemas/GearCategory'},
              {'type': 'null'},
            ],
            'title': 'Category',
          },
        },
        {
          'name': 'brand',
          'in': 'query',
          'required': false,
          'schema': {
            'anyOf': [
              {'type': 'string'},
              {'type': 'null'},
            ],
            'title': 'Brand',
          },
        },
        {
          'name': 'loaner_only',
          'in': 'query',
          'required': false,
          'schema': {
            'type': 'boolean',
            'default': false,
            'title': 'Loaner Only',
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
      ],
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/SearchResponse'},
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
      r'q': q,
      r'country': country,
      r'city': city,
      r'category': category?.toJson(),
      r'brand': brand,
      r'loaner_only': loanerOnly,
      r'limit': limit,
      r'offset': offset,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<HttpResponse<SearchResponse>>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/v1/search/repair-partners',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SearchResponse _value;
    try {
      _value = SearchResponse.fromJson(_result.data!);
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
