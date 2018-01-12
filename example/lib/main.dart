import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usage_stats/usage_stats.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _usageToday = "0:00";
  String _usageYesterday = "0:00";

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  getUsageToday() async  {
      return "0:00";
  }

  calcDuration(List<String> list)
  {
      num duration = 0;
      for (var s in list) {
        var entry = s.split(";");
        if (entry.length == 2)
        {
          var t = int.parse(entry[0]);
          if (t > 1000 && !entry[1].endsWith("launcher")) {
            duration += num.parse(entry[0]);
          }
        }
      }
      num seconds = duration ~/ 1000;
      return (seconds ~/ 60).toString() + ":" +  (seconds % 60).toString();
  }

  updateUsage() async {
    var usage = await getUsageToday();
    var yesterday = new  DateTime.now();  
    var oneDay = new Duration(days: 1, hours: yesterday.hour, minutes: yesterday.minute, seconds: yesterday.second);
    var usagList = await UsageStats.usageStats(yesterday.millisecondsSinceEpoch,new  DateTime.now().millisecondsSinceEpoch);
    yesterday.subtract(oneDay) ;
    setState(() {
      _usageToday : usage;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    String platformVersion;
    String usageToday;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await UsageStats.platformVersion;
      usageToday = await getUsageToday();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted)
      return;

    setState(() {
      _platformVersion = platformVersion;
      _usageToday = usageToday;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Column(children: <Widget>[
            new Text('Running on: $_platformVersion\n'),
            new Text('Usage today: $_usageToday\n'),
            new FloatingActionButton(
              child: new Text("refresh"),
              onPressed: () => updateUsage())
          ]),
        ),
      ),
    );
  }
}
