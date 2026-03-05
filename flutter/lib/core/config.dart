class AppConfig {
  AppConfig._();

  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000');
  static const defaultCountry = String.fromEnvironment('DEFAULT_COUNTRY', defaultValue: 'US');
  static const defaultCity = String.fromEnvironment('DEFAULT_CITY', defaultValue: 'New York');
}
