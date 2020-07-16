import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';


class DbProvider{
  static final _databaseName = "bookmark_database.db";
  static final _databaseVersion = 1;

  DbProvider._privateConstructor();
  static final DbProvider instance = DbProvider._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    try{    
      await db.execute('''
        CREATE TABLE Categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          name TEXT NOT NULL,
          date TEXT NOT NULL
        )
        ''');
    } on Exception catch (_) {
      print('Categories już istnieje');
    }

    try{     
    await db.execute('''
          CREATE TABLE Bookmarks (
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            categoryId INTEGER NOT NULL,
            name TEXT NOT NULL,
            url TEXT NOT NULL,
            date TEXT NOT NULL,
            FOREIGN KEY(categoryId) REFERENCES Categories(id)
          )
          ''');
    }on Exception catch (_) {
      print('Bookmarks już istnieje');
    }
  }
  void flushTable(String table) async {
    Database db = await instance.database;
    try{
    await db.rawQuery('DROP TABLE $table');
    } on Exception catch (_) {
      print('never reached');
    }
  }

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row, String table) async {
    Database db = await instance.database;
    // Insert the row into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same row is inserted twice.
    // In this case, replace any previous data.
    try{
    var output = await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
    return output;
    } on Exception catch (_) {
      _onCreate(_database, _databaseVersion);
    }

  }

  // All of the rows are returned as a list of maps, where each map is 
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    Database db = await instance.database;
    try{
      return await db.query(table);
    } on Exception catch (_) {
      _onCreate(_database, _databaseVersion);
    }
  }

  Future<List<Map<String, dynamic>>> queryNRows(String table, int n) async {
    Database db = await instance.database;
    try{
      return await db.query(table, limit: n);
     } on Exception catch (_) {
      _onCreate(_database, _databaseVersion);
    }
  }

  Future<List<Map<String, dynamic>>> queryRecentRows(String table, int limit_n) async {
    Database db = await instance.database;
    try{
      return await db.rawQuery("SELECT * FROM $table ORDER BY datetime(date) DESC Limit $limit_n");
     } on Exception catch (_) {
      _onCreate(_database, _databaseVersion);
    }
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount(String table) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other 
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row, String table) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is 
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id, String table) async {
    Database db = await instance.database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }



  // Future<void> updateBookmark(Bookmark bookmark, Future<Database> database) async {
  //   // Get a reference to the database.
  //   final db = await database;

  //   // Update the given Dog.
  //   await db.update(
  //     'Bookmarks',
  //     bookmark.toMap(),
  //     // Ensure that the Dog has a matching id.
  //     where: "id = ?",
  //     // Pass the Dog's id as a whereArg to prevent SQL injection.
  //     whereArgs: [bookmark.id],
  //   );
  // }
  // Future<List<Bookmark>> bookmarks(Future<Database> database) async {
  //     // Get a reference to the database.
  //     final Database db = await database;
  //     // Query the table for all The Dogs.
  //     final List<Map<String, dynamic>> maps = await db.query('Bookmarks');

  //     // Convert the List<Map<String, dynamic> into a List<Dog>.
  //     return List.generate(maps.length, (i) {
  //       return Bookmark(
  //         id: maps[i]['id'],
  //         categoryId: maps[i]['categoryId'],
  //         name: maps[i]['name'],
  //         url: maps[i]['url'],
  //         date: maps[i]['date'],
  //       );
  //   });
  // }
  // Future<void> deleteBookmark(int id, Future<Database> database) async {
  //   // Get a reference to the database.
  //   final db = await database;

  //   // Remove the Dog from the Database.
  //   await db.delete(
  //     'Bookmarks',
  //     // Use a `where` clause to delete a specific dog.
  //     where: "id = ?",
  //     // Pass the Dog's id as a whereArg to prevent SQL injection.
  //     whereArgs: [id],
  //   );
  // }
}
