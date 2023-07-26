// Import the necessary packages
import 'package:sqflite/sqflite.dart'; // sqflite package for SQLite in Flutter
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // sqflite_common_ffi for Windows support
import 'package:path_provider/path_provider.dart'; // path_provider to get directory path
import 'dart:io';
import 'dart:async';

// Initialize the FFI loader for sqflite_common_ffi
void sqfliteFfiInit() {
  sqfliteFfiInit();
}

class DatabaseHelper {
  // Singleton instance of DatabaseHelper
  static DatabaseHelper? _databaseHelper;
  // Singleton instance of Database
  static Database? _database;

  // Define the table and column names
  String todoTable = 'todo_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';

  // Named constructor to create instance of DatabaseHelper
  DatabaseHelper._createInstance();

  // Factory constructor to return the singleton instance of DatabaseHelper
  factory DatabaseHelper() {
    // If _databaseHelper is null, initialize it. Otherwise, return the existing instance.
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  // Getter for _database
  Future<Database> get database async {
    // If _database is null, initialize it. Otherwise, return the existing instance.
    _database ??= await initializeDatabase();
    return _database!;
  }

  // Method to initialize the database
  Future<Database> initializeDatabase() async {
    // Get the directory path to store the database
    Directory directory = await getApplicationDocumentsDirectory();
    // Use string interpolation to compose the database path
    String path = '${directory.path}todos.db';

    // Open/create the database at a given path, and create the table if it doesn't exist
    var todosDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todosDatabase;
  }

  // Method to create the table
  void _createDb(Database db, int newVersion) async {
    // Execute a SQL query to create a new table with the specified columns
    await db.execute(
        'CREATE TABLE $todoTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT)');
  }
}
