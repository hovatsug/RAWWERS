class AppConfig {
  AppConfig._();

  static const appFlavor = String.fromEnvironment('APP_FLAVOR', defaultValue: 'client');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');
  static const defaultCountry = String.fromEnvironment('DEFAULT_COUNTRY', defaultValue: 'US');
  static const defaultCity = String.fromEnvironment('DEFAULT_CITY', defaultValue: 'New York');

  static bool get isProApp => appFlavor == 'pro';
  static bool get isClientApp => appFlavor == 'client';
  static String get appDisplayName => isProApp ? 'RAWWERS Pro' : 'RAWWERS';
}
