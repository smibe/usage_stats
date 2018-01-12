import 'dart:async';

import 'package:flutter/services.dart';

class UsageStats {
  static const MethodChannel _channel =
      const MethodChannel('usage_stats');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');
  
  static Future<List<String>> usageStats(int start, int end) {
      _channel.invokeMethod('usageStats', {start:start, end: end });
  }
}
