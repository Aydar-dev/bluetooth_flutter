import 'package:sqflite/sqflite.dart';

class MonitorDatabase {
  Database database;

  Future _checkDatabaseInit() async {
    if (database == null) await initDatabase();
  }

  Future initDatabase() async {
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + '/sqflite.db';

    // open the database
    database = await openDatabase(path, version: 1);

    var beat = await database.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name="Beat"');
    var oxygen = await database.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name="Oxygen"');
    var breathe = await database.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name="Breathe"');
    var risk = await database.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name="Risk"');
    var sleep = await database.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name="Sleep"');

    if (beat.isEmpty) {
      await database.execute(
          'CREATE TABLE Beat (id INTEGER PRIMARY KEY, user CHAR(40), datetime INTEGER, value FLOAT)');
    }
    if (oxygen.isEmpty) {
      await database.execute(
          'CREATE TABLE Oxygen (id INTEGER PRIMARY KEY, user CHAR(40), datetime INTEGER, value INTEGER)');
    }
    if (breathe.isEmpty) {
      String valueSubquery = '';
      for (int i = 1; i <= 16; i++) {
        valueSubquery += ', value' + i.toString() + ' FLOAT';
      }
      await database.execute(
          'CREATE TABLE Breathe (id INTEGER PRIMARY KEY, user CHAR(40), datetime INTEGER' +
              valueSubquery +
              ')');
    }
    if (risk.isEmpty) {
      await database.execute(
          'CREATE TABLE Risk (id INTEGER PRIMARY KEY, user CHAR(40), datetime INTEGER, value INTEGER)');
    }
    if (sleep.isEmpty) {
      await database.execute(
          'CREATE TABLE Sleep (id INTEGER PRIMARY KEY, user CHAR(40), starttime INTEGER, endtime INTEGER)');
    }
  }

  void saveRecord(List values) async {
    await _checkDatabaseInit();
    int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await database.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Beat(user, datetime, value) VALUES("david", $now, ${values[0]})');
      int id2 = await txn.rawInsert(
          'INSERT INTO Oxygen(user, datetime, value) VALUES("david", $now, ${values[1]})');
      int id3 = await txn.rawInsert(
          'INSERT INTO Breathe(user, datetime, value1, value2, value3, value4, value5, value6, '
          'value7, value8, value9, value10, value11, value12, value13, value14, value15, value16) VALUES("david", $now, '
          '${values[2]}, ${values[3]}, ${values[4]}, ${values[5]}, ${values[6]}, ${values[7]}, ${values[8]}, '
          '${values[9]}, ${values[10]}, ${values[11]}, ${values[12]}, ${values[13]}, ${values[14]}, ${values[15]}, '
          '${values[16]}, ${values[17]})');
      int id4 = await txn.rawInsert(
          'INSERT INTO Risk(user, datetime, value) VALUES("david", $now, ${values[18]})');

      print('record inserted: $id1 $id2 $id3 $id4');
    });
  }

  Future<Map> getLatestSleepRecord() async {
    await _checkDatabaseInit();
    var sleep = await database
        .rawQuery('SELECT * FROM Sleep ORDER BY endtime DESC LIMIT 1;');
    return sleep.toList()[0];
  }

  Future getOxygenRecord(starttime, endtime) async {
    await _checkDatabaseInit();
    var oxygen = await database.rawQuery(
        'SELECT value FROM Oxygen WHERE datetime BETWEEN $starttime AND $endtime ORDER BY datetime;');
    return oxygen.toList();
  }

  Future getBreatheRecord(starttime, endtime) async {
    await _checkDatabaseInit();
    var breathe = await database.rawQuery(
        'SELECT * FROM Breathe WHERE datetime BETWEEN $starttime AND $endtime ORDER BY datetime;');
    return breathe.toList();
  }

  Future getBeatsRecord(starttime, endtime) async {
    await _checkDatabaseInit();
    var breathe = await database.rawQuery(
        'SELECT value FROM Beat WHERE datetime BETWEEN $starttime AND $endtime ORDER BY datetime;');
    return breathe.toList();
  }

  Future saveTime(start, end) async {
    await _checkDatabaseInit();
    await database.transaction((txn) async {
      int id = await txn.rawInsert(
          'INSERT INTO Sleep(user, starttime, endtime) VALUES("david", $start, $end)');
      print('sleep time inserted: $id');
    });
  }

  void close() {
    if (database != null) database.close();
  }
}