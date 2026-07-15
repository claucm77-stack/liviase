class AppConfig {
  AppConfig._();

  static const String laravelBaseUrl = String.fromEnvironment(
    'LARAVEL_BASE_URL',
    defaultValue: 'https://liviase.sanmartin.edu.co',
  );

  static String get laravelApiBaseUrl => '$laravelBaseUrl/api';
}
