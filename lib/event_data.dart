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

