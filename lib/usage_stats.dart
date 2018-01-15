    import 'dart:async';

import 'package:flutter/services.dart';

class UsageStats {
  static const MethodChannel _channel =
      const MethodChannel('usage_stats');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');
  
  static Future<List<String>> usageStats(int start, int end) async {
      dynamic args = new Map();
      args["start"] = start;
      args["end"] = end;
      return await _channel.invokeMethod('usageStats', args);
  }
}
