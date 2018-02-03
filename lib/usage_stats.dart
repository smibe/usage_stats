import 'dart:async';
import 'package:flutter/services.dart';
import 'usage_stats_data.dart';

class EventData
{
  String packageName;
  String appName;
  int timestamp;
  int eventType;

  static const int  MOVE_TO_FOREGROUND = 1;
  static const int  MOVE_TO_BACKGROUND = 2;
  static const int CONFIGURATION_CHANGE = 5;

  EventData(this.timestamp, this.eventType, this.packageName, this.appName, );

  EventData.fromCsv(String csvString) {
  
    var entry = csvString.split(";");
    if (entry.length == 4) {
      this.timestamp = int.parse(entry[0]);
      this.eventType = int.parse(entry[1]);
      this.packageName = entry[2];
      this.appName = entry[3];

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
