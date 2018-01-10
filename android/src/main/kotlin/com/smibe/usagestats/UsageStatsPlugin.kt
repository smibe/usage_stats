package com.smibe.usagestats

import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Intent
import java.util.*
import java.util.Calendar.HOUR_OF_DAY

import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.Registrar

class UsageStatsPlugin(registrar: Registrar): MethodCallHandler {
  val _registrar = registrar

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar): Unit {
      val channel = MethodChannel(registrar.messenger(), "usage_stats")
      channel.setMethodCallHandler(UsageStatsPlugin(registrar))
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result): Unit {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "usageToday") {
       var mgr =  _registrar.context().getSystemService("usagestats");
       var list : ArrayList<String> = ArrayList()
       if (mgr is UsageStatsManager)
       {
        val cal = Calendar.getInstance()
        cal.set(HOUR_OF_DAY, 0)

        val queryUsageStats = mgr.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, cal.timeInMillis, System.currentTimeMillis())

        if (queryUsageStats.size == 0) {          
          _registrar.context().startActivity(Intent("android.settings.USAGE_ACCESS_SETTINGS"))
        }
        else {
          for (item in queryUsageStats) {
            list.add("${item.totalTimeInForeground};${item.packageName}")
          }
        }
       }
      result.success(list)
    } else {
      result.notImplemented()
    }
  }
}
