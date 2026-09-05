library search_client;

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import '../models/models.dart';
part 'search_client.g.dart';

@RestApi()
abstract class SearchClient {
  factory SearchClient(
    Dio dio, {
    ParseErrorLogger? errorLogger,
    String? baseUrl,
  }) = _SearchClient;

  @GET("/v1/search/pros")
  Future<HttpResponse<SearchResponse>> searchProsV1SearchProsGet({
    @Query("q") required String? q,
    @Query("niche") required String? niche,
    @Query("city") required String? city,
    @Query("country") required String? country,
    @Query("min_price") required double? minPrice,
    @Query("max_price") required double? maxPrice,
    @Query("tier_min") required SkillTier? tierMin,
    @Query("sort") String sort = 'relevance',
    @Query("limit") int limit = 20,
    @Query("offset") int offset = 0,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
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
  });
  @GET("/v1/search/courses")
  Future<HttpResponse<SearchResponse>> searchCoursesV1SearchCoursesGet({
    @Query("q") required String? q,
    @Query("niche") required String? niche,
    @Query("level") required CourseLevel? level,
    @Query("free_only") bool freeOnly = false,
    @Query("mandatory_only") bool mandatoryOnly = false,
    @Query("sort") String sort = 'relevance',
    @Query("limit") int limit = 20,
    @Query("offset") int offset = 0,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
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
  });
  @GET("/v1/search/products")
  Future<HttpResponse<SearchResponse>> searchProductsV1SearchProductsGet({
    @Query("q") required String? q,
    @Query("category") required String? category,
    @Query("brand") required String? brand,
    @Query("min_price") required double? minPrice,
    @Query("max_price") required double? maxPrice,
    @Query("in_stock_only") bool inStockOnly = false,
    @Query("limit") int limit = 20,
    @Query("offset") int offset = 0,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
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
  });
  @GET("/v1/search/repair-partners")
  Future<HttpResponse<SearchResponse>>
  searchRepairPartnersV1SearchRepairPartnersGet({
    @Query("q") required String? q,
    @Query("country") required String? country,
    @Query("city") required String? city,
    @Query("category") required GearCategory? category,
    @Query("brand") required String? brand,
    @Query("loaner_only") bool loanerOnly = false,
    @Query("limit") int limit = 20,
    @Query("offset") int offset = 0,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
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
  });
}
