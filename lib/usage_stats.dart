import 'dart:async';
import 'usage_stats_data.dart';
import 'event_data.dart';

abstract class IUsageStats {
  Future<List<UsageStatsData>> usageStats(int start, int end);
  Future<List<EventData>> getEvents(int start, int end);
  Future<List<UsageStatsData>> buildUsageStats(int start, int end);
}
