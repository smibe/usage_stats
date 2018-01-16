    import 'dart:async';

import 'package:flutter/services.dart';

class UsageStatsData
{
  String packageName;
  String appName;
  int duration;

  UsageStatsData(this.packageName, this.appName, this.duration);

  UsageStatsData.fromCsv(String csvString) {
  
    var entry = csvString.split(";");
    if (entry.length >= 2) {
      this.duration = int.parse(entry[0]);
      this.packageName = entry[1];
    }

    if (entry.length >= 3) {
      this.appName = entry[2];
      if (this.appName == "(unknown)")
        this.appName = entry[1];
    }
  }
}


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
