import 'app_config.dart';

class AdminLinks {
  AdminLinks._();

  static const String laravelBaseUrl = AppConfig.laravelBaseUrl;

  static String get panel => '$laravelBaseUrl/admin';
  static String get createEducationalContent =>
      '$laravelBaseUrl/admin/contents/create';
  static String get createMicrobusiness =>
      '$laravelBaseUrl/admin/microbusinesses/create';
}
