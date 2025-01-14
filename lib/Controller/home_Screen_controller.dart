import 'package:sqflite/sqflite.dart';

class HomeScreenController {
  static late Database items;
  static List<Map> assetlist = [];

  static Future initDb() async {
    items = await openDatabase("assetData.db", version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE Assets (id INTEGER PRIMARY KEY, type TEXT, name TEXT, description TEXT, serialNumber TEXT, availability INTEGER)');
    });
  }

  //to add a new asset

  static Future addAsset(String type, String name, String description,
      String serialNumber, int availability) async {
    await items.rawInsert(
        'INSERT INTO Assets(type, name, description, serialNumber, availability) VALUES(?, ?, ?, ?, ?)',
        [type, name, description, serialNumber, availability]);
    getAllAssets();
  }

  //display detials

  static Future getAllAssets() async {
    assetlist = await items.rawQuery('SELECT * FROM Assets');
    print(assetlist);
  }

  //delete an asset
  static Future deleteAsset(int id) async {
    await items.rawDelete('DELETE FROM Assets WHERE id = ?', [id]);
    getAllAssets();
  }

  //update detials

  static Future updateAssets(String type, String name, String description,
      String serialNumber, int availability, int id) async {
    await items.rawUpdate(
        'UPDATE Assets SET type =?, name =?, description = ?, serialNumber =?, availability =? WHERE id =?',
        [type, name, description, serialNumber, availability, id]);
    getAllAssets();
  }
}
