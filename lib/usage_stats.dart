import 'dart:async';
import 'package:flutter/services.dart';
import 'usage_stats_data.dart';
import 'event_data.dart';


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

  static Future<List<EventData>> getEvents(int start, int end) async {
      dynamic args = new Map();
      args["start"] = start;
      args["end"] = end;
      List<String> list =  await _channel.invokeMethod('getEvents', args);
      return list.map((s) => new EventData.fromCsv(s)).toList();
  }

  static void updateUsageData(Map<String, UsageStatsData> usages, EventData event, String packageName, int timestamp)
  {
    if (usages.containsKey(packageName))
    {
      var usageData = usages[packageName];
      usageData.duration += event.timestamp - timestamp;
    }
    else 
    {
      var usageData = new UsageStatsData(packageName, event.appName, 0);
      usageData.duration += event.timestamp - timestamp;
      usages[packageName] = usageData;
    }
  }

  static Future<List<UsageStatsData>>buildUsageStats(int start, int end) async
  {
    var events = await getEvents(start, end);
    int timestamp = start;
    String packageName = "";
    Map<String, UsageStatsData> usages = new Map<String, UsageStatsData>();
    var event = null;
    for (event in events)
    {
      if (event.eventType  == EventData.MOVE_TO_BACKGROUND && packageName == event.packageName)
      {
        updateUsageData(usages, event, packageName, timestamp);
        timestamp = event.timestamp;
        packageName = "";
      }

      if (event.eventType  == EventData.MOVE_TO_FOREGROUND)
      {
        if (packageName != "")
        {
          updateUsageData(usages, event, packageName, timestamp);
        }
        timestamp = event.timestamp;
        packageName = event.packageName;
      }
    }

    //update the last package
    if (packageName != "")
    {
      event.timestamp = end;
      event.eventType = EventData.MOVE_TO_BACKGROUND;
      updateUsageData(usages, event, packageName, timestamp);
    }
return  usages.values.toList();
  }
}
