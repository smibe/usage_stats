package com.smibe.usagestats

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.*
import java.util.Calendar.HOUR_OF_DAY


class UsageStatsPlugin(registrar: Registrar): MethodCallHandler {
  val _registrar = registrar

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar): Unit {
      val channel = MethodChannel(registrar.messenger(), "usage_stats")
      channel.setMethodCallHandler(UsageStatsPlugin(registrar))

    }
  }

    fun checkUsageStatsGranted() : Boolean {
        var granted = false
        var ctx = _registrar.context()
        val appOps = ctx
                .getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(), ctx.getPackageName())

        if (mode == AppOpsManager.MODE_DEFAULT) {
            granted = ctx.checkCallingOrSelfPermission(android.Manifest.permission.PACKAGE_USAGE_STATS) === PackageManager.PERMISSION_GRANTED
        } else {
            granted = mode == AppOpsManager.MODE_ALLOWED
        }
        return granted;
    }

    fun getAppName(packageName : String) : String {
        val pm = _registrar.context().getPackageManager()
        var ai: ApplicationInfo?
        try {
            ai = pm.getApplicationInfo(packageName, 0)
        } catch (e: PackageManager.NameNotFoundException) {
            ai = null
        }

        return if (ai != null)  pm.getApplicationLabel(ai).toString() else "(unknown)"
    }

  fun getUsageStats(start : Long, end : Long) : ArrayList<String>
  {
       var mgr =  _registrar.context().getSystemService(Context.USAGE_STATS_SERVICE);
       var list : ArrayList<String> = ArrayList()
       if (mgr is UsageStatsManager)
       {

        Log.d("usage-stats", "queryUsageStats ${start} : ${end}")
        val queryUsageStats = mgr.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, start, end)

        if (!checkUsageStatsGranted()) {
          Log.d("usage-stats", "queryUsageStats- permission not granted")
          _registrar.context().startActivity(Intent("android.settings.USAGE_ACCESS_SETTINGS"))
        }
        else {
          for (item in queryUsageStats) {
            Log.d("usage-stats", "Item: ${item.totalTimeInForeground};${item.packageName}")
            list.add("${item.totalTimeInForeground};${item.packageName};${getAppName(item.packageName)}")
          }
        }
       }
       return list
  }

  override fun onMethodCall(call: MethodCall, result: Result): Unit {
      Log.d("usage-stats", "Got methodcall ${call.method}")
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "usageToday") {
        val start = Calendar.getInstance()
        start.set(HOUR_OF_DAY, 0)
        val end = System.currentTimeMillis()
        val list = getUsageStats(start.timeInMillis, end)
      result.success(list)
    } else if (call.method == "usageStats") {
        Log.d("usage-stats", "Now: ${System.currentTimeMillis()}")
        try {
            //Log.d("usage-stats", "Got call: ${call.arguments<>()}")
            var startL : Long = call.argument("start");
            var endL : Long = call.argument("end");

                Log.d("usage-stats", "Got arguments ${startL} : ${endL}")
            val list = getUsageStats(startL, endL)
            result.success(list)
        }
        catch (e : Exception) {
            Log.d("usage-stats", "failed: ${e}")
        }
    } else {
      result.notImplemented()
    }
  }
}
