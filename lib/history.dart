import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'common/database.dart';
import 'common/RecordData.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  MonitorDatabase database;
  String ahi = '--';
  String beatsCount = '--';
  String eventCount = '--';

  Map oxygenChart = {
    'average': '--',
    'discription': '睡眠品質不佳 🐣(假資料)',
    'chart': null,
  };

  Map breatheChart = {
    'hours': '--',
    'minutes': '--',
    'seconds': '--',
    'compare': '比平均 -- -- 分鐘(假資料)',
    'chart': null,
  };

  Map eventsChart = {
    'low': 1,
    'mid': 1,
    'high': 1,
  };

  @override
  void initState() {
    super.initState();
    database = new MonitorDatabase();
    _drawOxygenChart();
    _drawBreatheChart();
    _drawBeats();
    //睡眠事件圖表及AHI指數
    _drawEventsChartAndAHI();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _drawOxygenChart() async {
    Map lastSleep = await database.getLatestSleepRecord();
    List oxygenList = await database.getLatestOxygenRecord(
        lastSleep['starttime'], lastSleep['endtime']);

    setState(() {
      List<RecordData> data = [];
      int sum = 0;
      for (int i = 0; i < oxygenList.length; i++) {
        if (oxygenList[i]['value'] > 0) sum += oxygenList[i]['value'];
        data.add(new RecordData(i, oxygenList[i]['value'].toDouble()));
      }
      var chartdata = [
        new charts.Series<RecordData, int>(
          id: 'Records',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (RecordData rec, _) => rec.sec,
          measureFn: (RecordData rec, _) => rec.value,
          data: data,
        )
      ];
      oxygenChart['chart'] = charts.LineChart(chartdata, animate: false);
      oxygenChart['average'] =
          (data.length > 0) ? (sum ~/ data.length).toString() : '--';
    });
  }

  Future _drawEventsChartAndAHI() async {
    int count = 0;
    eventsChart['low'] = eventsChart['mid'] = eventsChart['high'] = 0;

    Map lastSleep = await database.getLatestSleepRecord();
    int hour = (lastSleep['endtime'] - lastSleep['starttime']) ~/ 3600;
    List risk = await database.getRiskRecord(
        lastSleep['starttime'], lastSleep['endtime']);

    setState(() {
      for (int i = 0; i < risk.length; i++) {
        if (risk[i]['value'] > 80) {
          eventsChart['high']++;
        } else if (risk[i]['value'] > 40) {
          eventsChart['mid']++;
        } else if (risk[i]['value'] > 0) {
          eventsChart['low']++;
        }
        if (i + 1 < risk.length &&
            risk[i]['value'] > 80 &&
            risk[i + 1]['value'] < 80) {
          count++;
        }
      }
      ahi = (hour > 0) ? (count ~/ hour).toString() : count.toString();
    });
  }

  Future _drawBeats() async {
    Map lastSleep = await database.getLatestSleepRecord();
    List beatsList = await database.getBeatsRecord(
        lastSleep['starttime'], lastSleep['endtime']);

    setState(() {
      double sum = 0;
      int count = 0;
      for (int i = 0; i < beatsList.length; i++) {
        if (beatsList[i]['value'] - 1 > 0) {
          sum += beatsList[i]['value'];
          count++;
        }
      }
      beatsCount = (count > 0) ? (sum ~/ count).toString() : '--';
    });
  }

  Future _drawBreatheChart() async {
    Map lastSleep = await database.getLatestSleepRecord();

    int hour = (lastSleep['endtime'] - lastSleep['starttime']) ~/ 3600;
    int minute = (lastSleep['endtime'] - lastSleep['starttime']) % 3600 ~/ 60;
    int second = (lastSleep['endtime'] - lastSleep['starttime']) % 60;

    List breatheList = await database.getLatestBreatheRecord(
        lastSleep['starttime'], lastSleep['endtime']);
    setState(() {
      List<RecordData> data = [];
      for (int i = 0; i < breatheList.length; i++) {
        if (breatheList[i]['value1'] > 0 && breatheList[i]['value9'] > 0) {
          data.add(new RecordData(i, breatheList[i]['value1']));
          data.add(new RecordData(i, breatheList[i]['value2']));
          data.add(new RecordData(i, breatheList[i]['value3']));
          data.add(new RecordData(i, breatheList[i]['value4']));
          data.add(new RecordData(i, breatheList[i]['value5']));
          data.add(new RecordData(i, breatheList[i]['value6']));
          data.add(new RecordData(i, breatheList[i]['value7']));
          data.add(new RecordData(i, breatheList[i]['value8']));
          data.add(new RecordData(i, breatheList[i]['value9']));
          data.add(new RecordData(i, breatheList[i]['value10']));
          data.add(new RecordData(i, breatheList[i]['value11']));
          data.add(new RecordData(i, breatheList[i]['value12']));
          data.add(new RecordData(i, breatheList[i]['value13']));
          data.add(new RecordData(i, breatheList[i]['value14']));
          data.add(new RecordData(i, breatheList[i]['value15']));
          data.add(new RecordData(i, breatheList[i]['value16']));
        }
      }
      var chartdata = [
        new charts.Series<RecordData, int>(
          id: 'Records',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (RecordData rec, _) => rec.sec,
          measureFn: (RecordData rec, _) => rec.value,
          data: data,
        )
      ];
      breatheChart['hours'] = hour.toString();
      breatheChart['minutes'] = minute.toString();
      breatheChart['seconds'] = second.toString();
      breatheChart['chart'] = charts.LineChart(chartdata, animate: false);
    });
  }

  List<charts.Series<RecordData, int>> _createEventsData() {
    final data = [
      new RecordData(1, eventsChart['low'].toDouble()),
      new RecordData(2, eventsChart['mid'].toDouble()),
      new RecordData(3, eventsChart['high'].toDouble()),
    ];
    return [
      new charts.Series<RecordData, int>(
        id: 'Events',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (RecordData sales, _) =>
            sales.sec, //map key instead of second
        measureFn: (RecordData sales, _) => sales.value,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    Widget row1 = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: new Material(
              borderRadius: new BorderRadius.all(Radius.circular(15.0)),
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/history/oxygen');
                },
                child: new Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      Text(
                        '整夜血氧數據',
                        style: TextStyle(fontSize: 24.0, color: Colors.blue),
                      ),
                      Text(
                        '平均血氧值 ' + oxygenChart['average'],
                        style:
                            TextStyle(fontSize: 20.0, color: Colors.grey[800]),
                      ),
                      Text(
                        oxygenChart['discription'],
                        style:
                            TextStyle(fontSize: 20.0, color: Colors.grey[600]),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: ConstrainedBox(
                          constraints: BoxConstraints.expand(height: 200.0),
                          child: oxygenChart['chart'],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Widget row2 = Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 5),
              child: new Material(
                borderRadius: new BorderRadius.all(Radius.circular(15.0)),
                color: Colors.white,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/history/events');
                  },
                  child: new Container(
                    padding: EdgeInsets.only(top: 20.0),
                    alignment: Alignment.center,
                    child: Column(
                      children: <Widget>[
                        Text(
                          '睡眠事件所占比',
                          style: TextStyle(fontSize: 20.0, color: Colors.blue),
                        ),
                        Text(
                          '共' + eventCount + '次',
                          style: TextStyle(
                              fontSize: 18.0, color: Colors.grey[800]),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints.expand(height: 160.0),
                          child: charts.PieChart(_createEventsData(),
                              animate: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 10, left: 10),
                  child: Material(
                    borderRadius: new BorderRadius.all(Radius.circular(15.0)),
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/history/ahi');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 25.0),
                        alignment: Alignment.center,
                        child: Column(
                          children: <Widget>[
                            Text(
                              'AHI指數',
                              style:
                                  TextStyle(fontSize: 20.0, color: Colors.blue),
                            ),
                            Text(
                              ahi + ' 次/hr',
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.grey[800]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, left: 10),
                  child: Material(
                    borderRadius: new BorderRadius.all(Radius.circular(15.0)),
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/history/beat');
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 25.0),
                        alignment: Alignment.center,
                        child: Column(
                          children: <Widget>[
                            Text(
                              '心跳次數❤️',
                              style:
                                  TextStyle(fontSize: 20.0, color: Colors.blue),
                            ),
                            Text(
                              beatsCount + ' 次',
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.grey[800]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    Widget row3 = Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: new Material(
              borderRadius: new BorderRadius.all(Radius.circular(15.0)),
              color: Colors.white,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/history/breathe');
                },
                child: new Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      Text(
                        '整夜呼吸數據',
                        style: TextStyle(fontSize: 24.0, color: Colors.blue),
                      ),
                      Text(
                        '睡眠時間 ' +
                            breatheChart['hours'] +
                            ' 小時 ' +
                            breatheChart['minutes'] +
                            ' 分鐘 ' +
                            breatheChart['seconds'] +
                            ' 秒',
                        style:
                            TextStyle(fontSize: 20.0, color: Colors.grey[800]),
                      ),
                      Text(
                        breatheChart['compare'],
                        style:
                            TextStyle(fontSize: 20.0, color: Colors.grey[600]),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: ConstrainedBox(
                          constraints: BoxConstraints.expand(height: 200.0),
                          child: breatheChart['chart'],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Widget body = Container(
      padding: EdgeInsets.all(15),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: ListView(
        children: <Widget>[row1, row2, row3],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('睡眠呼吸檢測數據', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orangeAccent,
      ),
      body: body,
    );
  }
}
