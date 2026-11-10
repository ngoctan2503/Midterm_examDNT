import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl =>
      kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
  static const String appName = 'LibraCard';
  static const String author = '23IT.EB089 - Đặng Ngọc Tân';
}
