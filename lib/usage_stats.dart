import 'dart:async';
import 'package:flutter/services.dart';
import 'usage_stats_data.dart';

class UsageStats {
  static const MethodChannel _channel =
      const MethodChannel('usage_stats');

  static Future<UsageStatsData> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');
  
  static Future<List<UsageStatsData>> usageStats(int start, int end) async {
      dynamic args = new Map();
      args["start"] = start;
      args["end"] = end;
      List<String> list =  await _channel.invokeMethod('usageStats', args);
      return list.map((s) => new UsageStatsData.fromCsv(s)).toList();
  }
}
