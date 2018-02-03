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

