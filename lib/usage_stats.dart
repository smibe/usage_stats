import 'dart:async';

import 'package:flutter/services.dart';

class UsageStats {
  static const MethodChannel _channel =
      const MethodChannel('usage_stats');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');
}
