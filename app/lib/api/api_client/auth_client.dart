library auth_client;

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import '../models/models.dart';
part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(
    Dio dio, {
    ParseErrorLogger? errorLogger,
    String? baseUrl,
  }) = _AuthClient;

  @POST("/v1/auth/register")
  Future<HttpResponse<Map<String, dynamic>>> registerV1AuthRegisterPost({
    @Body() required RegisterRequest requestBody,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['auth'],
      'summary': 'Register',
      'operationId': 'register_v1_auth_register_post',
      'requestBody': {
        'content': {
          'application/json': {
            'schema': {'\$ref': '#/components/schemas/RegisterRequest'},
          },
        },
        'required': true,
      },
      'responses': {
        '201': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {
                'additionalProperties': true,
                'type': 'object',
                'title': 'Response Register V1 Auth Register Post',
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
  @POST("/v1/auth/login")
  Future<HttpResponse<TokenResponse>> loginV1AuthLoginPost({
    @Body() required LoginRequest requestBody,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['auth'],
      'summary': 'Login',
      'operationId': 'login_v1_auth_login_post',
      'requestBody': {
        'content': {
          'application/json': {
            'schema': {'\$ref': '#/components/schemas/LoginRequest'},
          },
        },
        'required': true,
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/TokenResponse'},
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
  @POST("/v1/auth/refresh")
  Future<HttpResponse<TokenResponse>> refreshV1AuthRefreshPost({
    @Body() required RefreshRequest requestBody,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['auth'],
      'summary': 'Refresh',
      'operationId': 'refresh_v1_auth_refresh_post',
      'requestBody': {
        'content': {
          'application/json': {
            'schema': {'\$ref': '#/components/schemas/RefreshRequest'},
          },
        },
        'required': true,
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/TokenResponse'},
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
  @POST("/v1/auth/logout")
  Future<HttpResponse> logoutV1AuthLogoutPost({
    @Body() required LogoutRequest requestBody,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['auth'],
      'summary': 'Logout',
      'operationId': 'logout_v1_auth_logout_post',
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
            'schema': {'\$ref': '#/components/schemas/LogoutRequest'},
          },
        },
      },
      'responses': {
        '204': {'description': 'Successful Response'},
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
  @POST("/v1/auth/verify-email/request")
  Future<HttpResponse> verifyEmailRequestV1AuthVerifyEmailRequestPost({
    @Body() required VerifyEmailRequest requestBody,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['auth'],
      'summary': 'Verify Email Request',
      'operationId': 'verify_email_request_v1_auth_verify_email_request_post',
      'requestBody': {
        'content': {
          'application/json': {
            'schema': {'\$ref': '#/components/schemas/VerifyEmailRequest'},
          },
        },
        'required': true,
      },
      'responses': {
        '204': {'description': 'Successful Response'},
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
  @POST("/v1/auth/verify-email/confirm")
  Future<HttpResponse> verifyEmailConfirmV1AuthVerifyEmailConfirmPost({
    @Body() required VerifyEmailConfirmRequest requestBody,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['auth'],
      'summary': 'Verify Email Confirm',
      'operationId': 'verify_email_confirm_v1_auth_verify_email_confirm_post',
      'requestBody': {
        'content': {
          'application/json': {
            'schema': {
              '\$ref': '#/components/schemas/VerifyEmailConfirmRequest',
            },
          },
        },
        'required': true,
      },
      'responses': {
        '204': {'description': 'Successful Response'},
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
  @POST("/v1/auth/password-reset/request")
  Future<HttpResponse> passwordResetRequestV1AuthPasswordResetRequestPost({
    @Body() required PasswordResetRequest requestBody,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['auth'],
      'summary': 'Password Reset Request',
      'operationId':
          'password_reset_request_v1_auth_password_reset_request_post',
      'requestBody': {
        'content': {
          'application/json': {
            'schema': {'\$ref': '#/components/schemas/PasswordResetRequest'},
          },
        },
        'required': true,
      },
      'responses': {
        '204': {'description': 'Successful Response'},
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
  @POST("/v1/auth/password-reset/confirm")
  Future<HttpResponse> passwordResetConfirmV1AuthPasswordResetConfirmPost({
    @Body() required PasswordResetConfirmRequest requestBody,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['auth'],
      'summary': 'Password Reset Confirm',
      'operationId':
          'password_reset_confirm_v1_auth_password_reset_confirm_post',
      'requestBody': {
        'content': {
          'application/json': {
            'schema': {
              '\$ref': '#/components/schemas/PasswordResetConfirmRequest',
            },
          },
        },
        'required': true,
      },
      'responses': {
        '204': {'description': 'Successful Response'},
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
  @GET("/v1/me")
  Future<HttpResponse<MeResponse>> meV1MeGet({
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['auth'],
      'summary': 'Me',
      'operationId': 'me_v1_me_get',
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
              'schema': {'\$ref': '#/components/schemas/MeResponse'},
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
  @GET("/v1/me/locale")
  Future<HttpResponse<LocalePreferenceView>> meLocaleV1MeLocaleGet({
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['auth'],
      'summary': 'Me Locale',
      'operationId': 'me_locale_v1_me_locale_get',
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
              'schema': {'\$ref': '#/components/schemas/LocalePreferenceView'},
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
  @PUT("/v1/me/locale")
  Future<HttpResponse<LocalePreferenceView>> updateMeLocaleV1MeLocalePut({
    @Body() required LocalePreferenceUpdateRequest requestBody,
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['auth'],
      'summary': 'Update Me Locale',
      'operationId': 'update_me_locale_v1_me_locale_put',
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
              '\$ref': '#/components/schemas/LocalePreferenceUpdateRequest',
            },
          },
        },
      },
      'responses': {
        '200': {
          'description': 'Successful Response',
          'content': {
            'application/json': {
              'schema': {'\$ref': '#/components/schemas/LocalePreferenceView'},
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
  @POST("/v1/me/upgrade-to-pro")
  Future<HttpResponse<UpgradeToProResponse>> upgradeToProV1MeUpgradeToProPost({
    @Header("Authorization") required String? authorization,
    @Header("X-User-Id") required String? xMinusUserMinusId,
    @CancelRequest() CancelToken? cancelToken,
    @SendProgress() ProgressCallback? onSendProgress,
    @ReceiveProgress() ProgressCallback? onReceiveProgress,
    @Extras()
    Map<String, dynamic>? extras = const {
      'tags': ['auth'],
      'summary': 'Upgrade To Pro',
      'operationId': 'upgrade_to_pro_v1_me_upgrade_to_pro_post',
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
              'schema': {'\$ref': '#/components/schemas/UpgradeToProResponse'},
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
