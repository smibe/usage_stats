#import "UsageStatsPlugin.h"
#import <usage_stats/usage_stats-Swift.h>

@implementation UsageStatsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftUsageStatsPlugin registerWithRegistrar:registrar];
}
@end
